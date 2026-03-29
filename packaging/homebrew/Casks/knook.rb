cask "knook" do
  version "0.1.6"
  sha256 "be334d0df1403d94a5258f0c4bb1a6fe12112af2fb1515924e2d1b7e32e20ce2"

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
