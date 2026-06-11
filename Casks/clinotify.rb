cask "clinotify" do
  version "0.1.2"
  sha256 "e4c70cd32fb46cd7e4abb24e75c030d414d0838cfefa612ec46245c240852519"

  url "https://github.com/ZichengWangdrzz/clinotify/releases/download/v0.1.2/CLINotify.dmg"
  name "CLINotify"
  desc "Menu bar alerts for Claude Code and Codex CLI sessions"
  homepage "https://github.com/ZichengWangdrzz/clinotify"

  depends_on macos: :ventura

  app "CLINotify.app"
  # Put the bundled CLI on Homebrew's PATH so users can run "clinotify install" right after install.
  binary "#{appdir}/CLINotify.app/Contents/MacOS/clinotify"

  # Stop the running menu-bar daemon AND tear down the autostart LaunchAgent (label == bundle id,
  # written by "clinotify autostart on" with KeepAlive) BEFORE Homebrew deletes the app — otherwise
  # launchd keeps relaunching the now-missing binary. (launchctl before quit per cask conventions.)
  # Use trash: not delete: for the plist. It lives in the user's own home and needs no root, but
  # Homebrew's delete: always shells out to sudo rm -- which would prompt for a password on EVERY
  # upgrade/uninstall (and fails outright in a non-interactive shell). trash: runs as the user.
  # (No backticks/dollar signs in these comments: this heredoc is unquoted, so they would execute.)
  uninstall launchctl: "app.clinotify.helper",
            quit:      "app.clinotify.helper",
            trash:     "~/Library/LaunchAgents/app.clinotify.helper.plist"

  # Deep clean (alphabetized per cask conventions). Globs cover both production (CLINotify) and any
  # dev (CLINotify-Dev) state a developer build may have left, plus the autostart plist for --zap.
  zap trash: [
    "~/Library/Application Support/CLINotify*",
    "~/Library/LaunchAgents/app.clinotify.helper.plist",
    "~/Library/Preferences/app.clinotify.helper*.plist",
  ]

  caveats <<~CAVEATS
    Before "brew uninstall --cask clinotify", run:
        clinotify uninstall
    That strips the Claude Code / Codex hooks CLINotify added to
    ~/.claude/settings.json and ~/.codex/config.toml and removes the
    ~/.local/bin/clinotify symlink. Homebrew cannot edit those files,
    so skipping it leaves dangling hooks that error on every session event.
  CAVEATS
end
