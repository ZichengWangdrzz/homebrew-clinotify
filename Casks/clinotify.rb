cask "clinotify" do
  version "0.1.0"
  sha256 "27d7b23b7390b747033b3b8af95fce9cb0feea4271550fd7c08be928fd84a587"

  url "https://github.com/ZichengWangdrzz/clinotify/releases/download/v0.1.0/CLINotify.dmg"
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
  uninstall launchctl: "app.clinotify.helper",
            quit:      "app.clinotify.helper",
            delete:    "~/Library/LaunchAgents/app.clinotify.helper.plist"

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
