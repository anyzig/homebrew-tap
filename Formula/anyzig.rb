class Anyzig < Formula
  desc "A universal zig executable that runs any version of zig."
  homepage "https://github.com/marler8997/anyzig"

  @@version = "v2025_08_03"

  url "https://github.com/marler8997/anyzig/archive/refs/tags/#{@@version}.tar.gz"
  sha256 "2600445976486c41944bbc73fc0f91d2bf91a5f5c4e56e394767722da934249b"
  license "MIT"

  conflicts_with "zig", because: "both install the `zig` executable"

  def install
    arch = case Hardware::CPU.arch
        when :arm64
            "aarch64"
        else
            Hardware::CPU.arch.to_s
        end

    bootstrap_url = "https://github.com/marler8997/anyzig/releases/download/#{@@version}/anyzig-#{arch}-macos.tar.gz"

    system "curl", "-L", "-o", buildpath/"anyzig.tar.gz", bootstrap_url
    system "tar", "-xf", buildpath/"anyzig.tar.gz", "-C", buildpath
    bootstrap_zig = buildpath/"zig"

    args = []
    args << "-Dcpu=#{cpu}" if build.bottle?
    system bootstrap_zig, "build", *args, *std_zig_args
  end

  test do
    system "#{bin}/zig", "--help"
  end
end
