#!/usr/bin/env bash
# update.sh — Automatically update Gemini CLI to the latest upstream release
# using Claude Code in non-interactive mode.
#
# Prerequisites:
#   - claude CLI installed and on PATH
#   - One-time acceptance of --dangerously-skip-permissions
#     (run: claude --dangerously-skip-permissions  and then /exit)
#
# Usage:
#   ./update.sh            # run the update
#   ./update.sh --dry-run  # print the command without executing

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PROMPT='Update gemini-cli-nix to the latest upstream release. Follow these steps:

1. Check the latest release using: curl -s https://api.github.com/repos/google-gemini/gemini-cli/releases/latest | jq -r '.tag_name' (do NOT use gh, it may not be authenticated)
2. Compare with the current version in `package.nix` — if already up to date, stop
3. Update `package.nix`: set the new `version`, fetch the new source `hash`, and rebuild twice to get the correct `npmDepsHash`
4. Verify the build works by running `./result/bin/gemini --version`
5. Scan all tracked files for passwords, tokens, API keys, private keys, or any sensitive/personal information — abort if anything is found
6. Commit with message: "Update Gemini CLI to v<VERSION>"
7. Push to origin/main'

if [[ "${1:-}" == "--dry-run" ]]; then
    echo "Would run:"
    echo "  cd $SCRIPT_DIR"
    echo "  claude -p <prompt> --dangerously-skip-permissions"
    exit 0
fi

cd "$SCRIPT_DIR"
claude -p "$PROMPT" --dangerously-skip-permissions
