class Anyzig < Formula
  desc "Universal zig executable that runs any version of zig"
  homepage "https://github.com/marler8997/anyzig"
  version "2025.08.13"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/marler8997/anyzig/releases/download/v2025_08_13/anyzig-aarch64-macos.tar.gz"
      sha256 "562b57571873ab9a609cc1f4e09c603a878a9218bcd6ccbda085b6cd69e57b74"
    end
    on_intel do
      url "https://github.com/marler8997/anyzig/releases/download/v2025_08_13/anyzig-x86_64-macos.tar.gz"
      sha256 "2d157b80eb0b28ec995232282d6049ddb30e02e206505e9cb8bb9fac01a04571"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/marler8997/anyzig/releases/download/v2025_08_13/anyzig-aarch64-linux.tar.gz"
      sha256 "d732ce1ef4bb2479bc1e64429c3cdc3779953ca34e3cc0848effc546301c04de"
    end
    on_intel do
      url "https://github.com/marler8997/anyzig/releases/download/v2025_08_13/anyzig-x86_64-linux.tar.gz"
      sha256 "49cac16c4621dd52a80e9d94ff190f7320db3bb74959ef207f47fb694bf3b546"
    end
  end

  conflicts_with "zig", because: "both install the `zig` executable"

  def install
    bin.install "zig"
  end

  test do
    output = shell_output("#{bin}/zig any version")
    assert_match version.to_s, output.strip
  end
end
