class Anyzig < Formula
  desc "A universal zig executable that runs any version of zig"
  homepage "https://github.com/marler8997/anyzig"
  version "v2025_08_03"
  # Placeholder URL - actual binary is downloaded in install method based on architecture
  url "https://github.com/marler8997/anyzig/archive/refs/tags/#{version}.tar.gz"
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

    binary_url = "https://github.com/marler8997/anyzig/releases/download/#{version}/anyzig-#{arch}-macos.tar.gz"
    binary_archive = buildpath/"anyzig-binary.tar.gz"

    system "curl", "--fail", "--location", "--output", binary_archive, binary_url
    system "tar", "--extract", "--file", binary_archive, "--directory", buildpath

    bin.install buildpath/"zig"
  end

  test do
    system bin/"zig", "any", "version"
  end
end
