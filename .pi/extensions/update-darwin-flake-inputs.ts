/**
 * Darwin Flake Inputs Updater
 *
 * On session start, checks if darwin/flake.lock is stale (> STALE_DAYS days old)
 * and offers to update nixpkgs, nix-darwin, home-manager, and
 * nixpkgs-firefox-darwin, then syncs the new commit hashes back into
 * darwin/flake.nix.
 */

import fs from "node:fs"
import path from "node:path"

import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent"

const STALE_DAYS = 7

const INPUTS = ["nixpkgs", "nix-darwin", "home-manager", "nixpkgs-firefox-darwin"] as const

// Python script: strips commit pins from input URLs in flake.nix
// e.g. "github:nix-community/home-manager/abc123..." -> "github:nix-community/home-manager"
const STRIP_PINS_SCRIPT = String.raw`
import pathlib, re

inputs = ["nixpkgs", "nix-darwin", "home-manager", "nixpkgs-firefox-darwin"]

text = pathlib.Path("flake.nix").read_text()
for name in inputs:
    # Match: name.url = "github:owner/repo/COMMIT_HASH";
    # Replace with: name.url = "github:owner/repo";
    pattern = rf"({re.escape(name)}\.url\s*=\s*\"[^\"]+)/[0-9a-f]{{7,}}(\";)"
    text = re.sub(pattern, r"\1\2", text)

pathlib.Path("flake.nix").write_text(text)
`.trim()

// Python script: reads flake.lock and patches the rev in each input URL
const SYNC_SCRIPT = String.raw`
import json, pathlib, re

lock = json.loads(pathlib.Path("flake.lock").read_text())
inputs = ["nixpkgs", "nix-darwin", "home-manager", "nixpkgs-firefox-darwin"]

# Follow root inputs mapping to get correct node names
root_inputs = lock["nodes"]["root"]["inputs"]

text = pathlib.Path("flake.nix").read_text()
for name in inputs:
    node_name = root_inputs.get(name, name)  # e.g. home-manager -> home-manager_2
    rev = lock["nodes"][node_name]["locked"]["rev"]
    # Match: name.url = "github:owner/repo"; (no commit hash)
    # Replace with: name.url = "github:owner/repo/REV";
    pattern = rf"({re.escape(name)}\.url\s*=\s*\"[^\"]+)(\";)"
    def repl(match, rev=rev):
        url = match.group(1)
        # If URL already ends with a hash, replace it; otherwise append
        if re.search(r'/[0-9a-f]{7,}$', url):
            url = re.sub(r'/[0-9a-f]{7,}$', f'/{rev}', url)
        else:
            url = f'{url}/{rev}'
        return f'{url}{match.group(2)}'
    text, count = re.subn(pattern, repl, text)
    if count != 1:
        raise SystemExit(f"Expected 1 match for {name}, got {count}")

pathlib.Path("flake.nix").write_text(text)
`.trim()

class FlakeValidationError extends Error {
  constructor(public readonly output: string) {
    super("Flake validation failed")
  }
}

const firstLine = (text: string) => {
  for (const line of text.split("\n")) {
    const trimmed = line.trim()
    if (trimmed) return trimmed
  }
}

const getRepoRoot = async (pi: ExtensionAPI, cwd: string) => {
  const result = await pi.exec("git", ["rev-parse", "--show-toplevel"], { cwd })
  if (result.code !== 0) return
  return firstLine(result.stdout)
}

const getLockAgeDays = (lockPath: string): number | undefined => {
  try {
    const lock = JSON.parse(fs.readFileSync(lockPath, "utf8")) as {
      nodes: Record<string, { locked?: { lastModified?: number } }>
    }
    const timestamps = Object.values(lock.nodes)
      .map((n) => n.locked?.lastModified)
      .filter((t): t is number => typeof t === "number")
    if (timestamps.length === 0) return undefined
    const newestSec = Math.max(...timestamps)
    return (Date.now() / 1000 - newestSec) / (60 * 60 * 24)
  } catch {
    return undefined
  }
}

const runUpdate = async (pi: ExtensionAPI, ctx: ExtensionContext, darwinDir: string) => {
  // Step 1: Strip commit pins from flake.nix so nix flake update resolves to latest
  ctx.ui.setStatus("flake-update", "Stripping commit pins from flake.nix…")
  const stripResult = await pi.exec("python3", ["-c", STRIP_PINS_SCRIPT], { cwd: darwinDir })
  if (stripResult.code !== 0 || stripResult.killed) {
    const detail = stripResult.stderr.trim() || stripResult.stdout.trim()
    throw new Error(`Strip pins failed: ${detail}`)
  }

  // Step 2: Update the lock file (nix resolves unpinned URLs to latest default branch)
  ctx.ui.setStatus("flake-update", "Running nix flake update…")
  const updateResult = await pi.exec(
    "nix",
    ["flake", "update", "--refresh", ...INPUTS],
    { cwd: darwinDir },
  )
  if (updateResult.code !== 0 || updateResult.killed) {
    const detail = updateResult.stderr.trim() || updateResult.stdout.trim()
    throw new Error(`nix flake update failed: ${detail}`)
  }

  // Step 3: Write the new commit hashes back into flake.nix
  ctx.ui.setStatus("flake-update", "Syncing revisions into flake.nix…")
  const syncResult = await pi.exec("python3", ["-c", SYNC_SCRIPT], { cwd: darwinDir })
  if (syncResult.code !== 0 || syncResult.killed) {
    const detail = syncResult.stderr.trim() || syncResult.stdout.trim()
    throw new Error(`Revision sync failed: ${detail}`)
  }

  // Step 4: Re-lock so flake.lock's 'original' matches the pinned URLs in flake.nix
  ctx.ui.setStatus("flake-update", "Re-locking to reconcile flake.nix with lock…")
  const relockResult = await pi.exec("nix", ["flake", "lock", "--refresh"], { cwd: darwinDir })
  if (relockResult.code !== 0 || relockResult.killed) {
    const detail = relockResult.stderr.trim() || relockResult.stdout.trim()
    throw new Error(`nix flake lock failed: ${detail}`)
  }
}

const validateFlake = async (pi: ExtensionAPI, ctx: ExtensionContext, darwinDir: string) => {
  // `darwin-rebuild build` builds the full system closure for the current host
  // without activating it (no root needed), catching the same errors dswitch would.
  ctx.ui.setStatus("flake-update", "darwin-rebuild build (dry-run for dswitch)…")
  const result = await pi.exec("darwin-rebuild", ["build", "--flake", ".", "--no-update-lock-file"], { cwd: darwinDir })
  if (result.code !== 0 && !result.killed) {
    throw new FlakeValidationError(result.stderr.trim() || result.stdout.trim())
  }
}

const run = async (pi: ExtensionAPI, ctx: ExtensionContext) => {
  const repoRoot = await getRepoRoot(pi, ctx.cwd)
  if (!repoRoot) return

  const darwinDir = path.join(repoRoot, "darwin")
  const lockPath = path.join(darwinDir, "flake.lock")
  if (!fs.existsSync(lockPath)) return

  const ageDays = getLockAgeDays(lockPath)
  if (ageDays === undefined || ageDays < STALE_DAYS) return

  const days = Math.floor(ageDays)
  const confirmed = await ctx.ui.confirm(
    "Update flake inputs?",
    `darwin/flake.lock is ${days} day${days !== 1 ? "s" : ""} old.\n` +
    `This will refresh nixpkgs, nix-darwin, home-manager, and nixpkgs-firefox-darwin,\n` +
    `sync the new commit hashes into darwin/flake.nix, then commit and push to origin.`,
  )
  if (!confirmed) return

  try {
    await runUpdate(pi, ctx, darwinDir)
    await validateFlake(pi, ctx, darwinDir)

    const diffResult = await pi.exec(
      "git",
      ["diff", "darwin/flake.nix", "darwin/flake.lock"],
      { cwd: repoRoot },
    )
    const diff = diffResult.stdout.trim()

    ctx.ui.setStatus("flake-update", "Committing…")
    const addResult = await pi.exec(
      "git",
      ["add", "darwin/flake.nix", "darwin/flake.lock"],
      { cwd: repoRoot },
    )
    if (addResult.code !== 0 || addResult.killed) {
      throw new Error(`git add failed: ${addResult.stderr.trim() || addResult.stdout.trim()}`)
    }

    const commitResult = await pi.exec(
      "git",
      ["commit", "-m", "Update darwin flake inputs"],
      { cwd: repoRoot },
    )
    if (commitResult.code !== 0 || commitResult.killed) {
      throw new Error(`git commit failed: ${commitResult.stderr.trim() || commitResult.stdout.trim()}`)
    }

    ctx.ui.setStatus("flake-update", "Pushing…")
    const pushResult = await pi.exec("git", ["push"], { cwd: repoRoot })
    if (pushResult.code !== 0 || pushResult.killed) {
      throw new Error(`git push failed: ${pushResult.stderr.trim() || pushResult.stdout.trim()}`)
    }

    ctx.ui.notify("Flake inputs updated, committed, and pushed.", "info")

    if (diff) {
      pi.sendMessage(
        {
          customType: "flake-update",
          content: `darwin flake inputs updated.\n\n\`\`\`diff\n${diff}\n\`\`\``,
          display: true,
          details: { diff },
        },
        { deliverAs: "nextTurn" },
      )
    }
  } catch (error) {
    if (error instanceof FlakeValidationError) {
      ctx.ui.notify("Flake validation failed — handing off to agent to fix.", "warning")
      pi.sendMessage(
        {
          customType: "flake-validation-error",
          content:
            `darwin flake inputs were updated but \`darwin-rebuild build\` failed.\n` +
            `Please investigate the error, fix the configuration, then commit and push.\n\n` +
            `\`\`\`\n${error.output}\n\`\`\``,
          display: true,
          details: { output: error.output },
        },
        { deliverAs: "nextTurn" },
      )
    } else {
      const message = error instanceof Error ? error.message : String(error)
      ctx.ui.notify(`Flake update failed: ${message}`, "error")
    }
  } finally {
    ctx.ui.setStatus("flake-update", undefined)
  }
}

const defer = (pi: ExtensionAPI, ctx: ExtensionContext) => {
  setTimeout(() => {
    void run(pi, ctx).catch((error) => {
      const message = error instanceof Error ? error.message : String(error)
      ctx.ui.notify(`Flake update check failed: ${message}`, "error")
    })
  }, 0)
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    if (!ctx.hasUI) return

    defer(pi, ctx)
  })
}
