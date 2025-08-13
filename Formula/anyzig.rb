class Anyzig < Formula
  desc "A universal zig executable that runs any version of zig"
  homepage "https://github.com/marler8997/anyzig"
  version "v2025_08_03"
  url "https://github.com/marler8997/anyzig/archive/refs/tags/#{version}.tar.gz"
  sha256 "2600445976486c41944bbc73fc0f91d2bf91a5f5c4e56e394767722da934249b"
  license "MIT"

  conflicts_with "zig", because: "both install the `zig` executable"

  def install
    if build.from_source?
      install_from_source
    else
      install_prebuilt_binary
    end
  end

  private

  def anyzig_arch
    case Hardware::CPU.arch
    when :arm64
      "aarch64"
    else
      Hardware::CPU.arch.to_s
    end
  end

  def prebuilt_url
    "https://github.com/marler8997/anyzig/releases/download/#{version}/anyzig-#{anyzig_arch}-macos.tar.gz"
  end

  def fetch_prebuilt_zig
    archive = buildpath/"anyzig-prebuilt.tar.gz"
    system "curl", "--fail", "--location", "--output", archive, prebuilt_url
    system "tar", "--extract", "--file", archive, "--directory", buildpath
    buildpath/"zig"
  end

  def install_from_source
    prebuilt_zig = fetch_prebuilt_zig

    args = []
    args << "-Dcpu=#{cpu}" if build.bottle?
    system prebuilt_zig, "build", *args, *std_zig_args
  end

  def install_prebuilt_binary
    prebuilt_zig = fetch_prebuilt_zig
    bin.install prebuilt_zig
  end

  test do
    system bin/"zig", "--help"
  end
end
