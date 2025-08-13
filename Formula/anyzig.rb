class Anyzig < Formula
  desc "Universal zig executable that runs any version of zig"
  homepage "https://github.com/marler8997/anyzig"
  url "https://github.com/marler8997/anyzig/archive/refs/tags/v2025_08_03.tar.gz"
  sha256 "2600445976486c41944bbc73fc0f91d2bf91a5f5c4e56e394767722da934249b"
  license "MIT"

  conflicts_with "zig", because: "both install the `zig` executable"

  # Don't update this unless this version cannot bootstrap the new version.
  resource "bootstrap" do
    checksums = {
      "aarch64-macos" => "527014b744a14650a144a242935173be457e3528b5d3af45f20ae408793e490c",
      "x86_64-macos"  => "497f3b96fa0b255e2e9a531d65b3054df37ef1133cdf994b02518762ca471506",
      "aarch64-linux" => "7fded6dd84d130b11edd71bf86681565c01149ef5815fed714859098a058e2ce",
      "x86_64-linux"  => "f7075b19e7c1df12844bb4f4fb78c187a8da2aacd44cd6eaa75364c94b9f0083",
    }

    version "v2025_08_03"

    on_macos do
      on_arm do
        url "https://github.com/marler8997/anyzig/releases/download/#{version}/anyzig-aarch64-macos.tar.gz"
        sha256 checksums["aarch64-macos"]
      end
      on_intel do
        url "https://github.com/marler8997/anyzig/releases/download/#{version}/anyzig-x86_64-macos.tar.gz"
        sha256 checksums["x86_64-macos"]
      end
    end

    on_linux do
      on_arm do
        url "https://github.com/marler8997/anyzig/releases/download/#{version}/anyzig-aarch64-linux.tar.gz"
        sha256 checksums["aarch64-linux"]
      end
      on_intel do
        url "https://github.com/marler8997/anyzig/releases/download/#{version}/anyzig-x86_64-linux.tar.gz"
        sha256 checksums["x86_64-linux"]
      end
    end
  end

  def install
    resource("bootstrap").stage do |r|
      bootstrap_dir = r.staging.tmpdir
      bootstrap_zig = bootstrap_dir/"zig"
      system bootstrap_zig, "build", "-Doptimize=ReleaseSafe"
      bin.install "zig-out/bin/zig" => "zig"
    end
  end

  test do
    output = shell_output("#{bin}/zig any version")
    assert_match "v2025_08_03", output.strip
  end
end
