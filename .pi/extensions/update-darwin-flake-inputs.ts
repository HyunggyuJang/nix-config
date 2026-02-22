/**
 * Darwin Flake Inputs Updater
 *
 * On session start, checks if darwin/flake.lock is stale (> STALE_DAYS days old)
 * and offers to update nixpkgs, nix-darwin, home-manager, and
 * nixpkgs-firefox-darwin. Exact revisions are recorded in flake.lock; flake.nix
 * only declares source URLs without commit pins.
 */

import fs from "node:fs"
import path from "node:path"

import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent"

const STALE_DAYS = 7

const INPUTS = ["nixpkgs", "nix-darwin", "home-manager", "nixpkgs-firefox-darwin"] as const

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
  ctx.ui.setStatus("flake-update", "Running nix flake update…")
  const result = await pi.exec(
    "nix",
    ["flake", "update", "--refresh", ...INPUTS],
    { cwd: darwinDir },
  )
  if (result.code !== 0 || result.killed) {
    throw new Error(`nix flake update failed: ${result.stderr.trim() || result.stdout.trim()}`)
  }
}

const validateFlake = async (pi: ExtensionAPI, ctx: ExtensionContext, darwinDir: string) => {
  ctx.ui.setStatus("flake-update", "Validating with darwin-rebuild build…")
  const result = await pi.exec(
    "darwin-rebuild",
    ["build", "--flake", ".", "--no-update-lock-file"],
    { cwd: darwinDir },
  )
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
    `then commit and push darwin/flake.lock to origin.`,
  )
  if (!confirmed) return

  try {
    await runUpdate(pi, ctx, darwinDir)
    await validateFlake(pi, ctx, darwinDir)

    const diffResult = await pi.exec(
      "git", ["diff", "darwin/flake.lock"],
      { cwd: repoRoot },
    )
    const diff = diffResult.stdout.trim()

    ctx.ui.setStatus("flake-update", "Committing…")
    await pi.exec("git", ["add", "darwin/flake.lock"], { cwd: repoRoot })
    const commitResult = await pi.exec(
      "git", ["commit", "-m", "Update darwin flake inputs"],
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
