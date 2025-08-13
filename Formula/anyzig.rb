class Anyzig < Formula
  desc "A universal zig executable that runs any version of zig"
  homepage "https://github.com/marler8997/anyzig"
  license "MIT"

  version "v2025_08_03"

  on_macos do
    on_arm do
      url "https://github.com/marler8997/anyzig/releases/download/v2025_08_03/anyzig-aarch64-macos.tar.gz"
      sha256 "527014b744a14650a144a242935173be457e3528b5d3af45f20ae408793e490c"
    end
    on_intel do
      url "https://github.com/marler8997/anyzig/releases/download/v2025_08_03/anyzig-x86_64-macos.tar.gz"
      sha256 "497f3b96fa0b255e2e9a531d65b3054df37ef1133cdf994b02518762ca471506"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/marler8997/anyzig/releases/download/v2025_08_03/anyzig-aarch64-linux.tar.gz"
      sha256 "7fded6dd84d130b11edd71bf86681565c01149ef5815fed714859098a058e2ce"
    end
    on_intel do
      url "https://github.com/marler8997/anyzig/releases/download/v2025_08_03/anyzig-x86_64-linux.tar.gz"
      sha256 "f7075b19e7c1df12844bb4f4fb78c187a8da2aacd44cd6eaa75364c94b9f0083"
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
