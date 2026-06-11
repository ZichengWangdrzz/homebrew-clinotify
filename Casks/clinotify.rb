cask "clinotify" do
  version "0.1.3"
  sha256 "06249078ec16b18e309d45ea10a65b24aec20be886b9ab39786f81b760743807"

  url "https://github.com/ZichengWangdrzz/clinotify/releases/download/v0.1.3/CLINotify.dmg"
  name "CLINotify"
  desc "Menu bar alerts for Claude Code and Codex CLI sessions"
  homepage "https://github.com/ZichengWangdrzz/clinotify"

  depends_on macos: :ventura

  app "CLINotify.app"
  # Put the bundled CLI on Homebrew's PATH so users can run "clinotify install" right after install.
  binary "#{appdir}/CLINotify.app/Contents/MacOS/clinotify"

  # Stop the running menu-bar daemon during an upgrade/uninstall (launchctl boot-out before quit, per
  # cask conventions) so launchd does not thrash relaunching the briefly-missing binary while the app
  # is swapped. Do NOT remove the autostart LaunchAgent plist here: this stanza ALSO runs on every
  # upgrade, and deleting the plist each upgrade is exactly what made users lose their "autostart on"
  # setting. The plist is a user artifact (written by "clinotify autostart on") — it is removed only on
  # full removal (zap, below) or by "clinotify uninstall" (see caveats). Leaving it = autostart survives
  # upgrades.
  uninstall launchctl: "app.clinotify.helper",
            quit:      "app.clinotify.helper"

  # After an install/upgrade, relaunch the menu-bar app IF the user had autostart enabled (its plist is
  # present), so an upgrade does not leave them with no running daemon until the next login. Non-fatal.
  # (No backticks or dollar signs here: this heredoc is unquoted so they would execute; #{...} is fine.)
  postflight do
    agent_plist = "#{Dir.home}/Library/LaunchAgents/app.clinotify.helper.plist"
    if File.exist?(agent_plist)
      system_command "/usr/bin/open", args: ["-g", "#{appdir}/CLINotify.app"], must_succeed: false
    end
  end

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
