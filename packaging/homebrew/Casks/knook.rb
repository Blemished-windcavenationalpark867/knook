cask "knook" do
  version "0.1.8"
  sha256 "b08144dfdc1819e912b9ffaeb9b908e17458ae31562eb612ca2d390558f2997b"

  url "https://github.com/preetsuthar17/knook/releases/download/v#{version}/knook-#{version}.dmg"
  name "knook"
  desc "Native macOS menu bar app for screen-break reminders"
  homepage "https://github.com/preetsuthar17/knook"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :ventura"

  app "knook.app"

  caveats do
    <<~EOS
      This preview build is not notarized yet.
      If macOS says knook is damaged on first launch, run:
        xattr -dr com.apple.quarantine /Applications/knook.app
    EOS
  end

  zap trash: [
    "~/Library/Application Support/knook",
    "~/Library/Application Support/nook",
    "~/Library/Application Support/Nook",
    "~/Library/Preferences/io.github.preetsuthar17.knook.plist",
    "~/Library/Saved Application State/io.github.preetsuthar17.knook.savedState",
  ]
end
