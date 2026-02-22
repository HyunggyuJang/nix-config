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

// Python one-shot script: reads flake.lock and patches the rev in each input URL
const SYNC_SCRIPT = String.raw`
import json, pathlib, re

lock = json.loads(pathlib.Path("flake.lock").read_text())
inputs = ["nixpkgs", "nix-darwin", "home-manager", "nixpkgs-firefox-darwin"]

text = pathlib.Path("flake.nix").read_text()
for name in inputs:
    rev = lock["nodes"][name]["locked"]["rev"]
    pattern = rf"({re.escape(name)}\.url\s*=\s*\"[^\"]+/)([0-9a-f]{{7,}})(\";)"
    def repl(match, rev=rev):
        return f"{match.group(1)}{rev}{match.group(3)}"
    text, count = re.subn(pattern, repl, text)
    if count != 1:
        raise SystemExit(f"Expected 1 match for {name}, got {count}")

pathlib.Path("flake.nix").write_text(text)
`.trim()

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
  ctx.ui.setStatus("flake-update", "Running nix flake update…")

  const updateResult = await pi.exec(
    "nix",
    [
      "flake", "update",
      "--override-input", "nixpkgs",                    "github:NixOS/nixpkgs",
      "--override-input", "nix-darwin",                 "github:nix-darwin/nix-darwin",
      "--override-input", "home-manager",               "github:nix-community/home-manager",
      "--override-input", "nixpkgs-firefox-darwin",     "github:bandithedoge/nixpkgs-firefox-darwin",
      ...INPUTS,
    ],
    { cwd: darwinDir },
  )

  if (updateResult.code !== 0 || updateResult.killed) {
    const detail = updateResult.stderr.trim() || updateResult.stdout.trim()
    throw new Error(`nix flake update failed: ${detail}`)
  }

  ctx.ui.setStatus("flake-update", "Syncing revisions into flake.nix…")

  const syncResult = await pi.exec("python3", ["-c", SYNC_SCRIPT], { cwd: darwinDir })
  if (syncResult.code !== 0 || syncResult.killed) {
    const detail = syncResult.stderr.trim() || syncResult.stdout.trim()
    throw new Error(`Revision sync failed: ${detail}`)
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
    const message = error instanceof Error ? error.message : String(error)
    ctx.ui.notify(`Flake update failed: ${message}`, "error")
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
