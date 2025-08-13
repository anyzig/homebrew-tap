#!/usr/bin/env ruby
#
# Updates the anyzig.rb formula with the latest GitHub release version and checksums
#
require 'json'
require 'digest'
require 'net/http'
require 'tempfile'

FORMULA_PATH = 'Formula/anyzig.rb'

def fetch_latest_release
  uri = URI('https://api.github.com/repos/marler8997/anyzig/releases/latest')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri)
  request['Accept'] = 'application/vnd.github.v3+json'
  request['User-Agent'] = 'anyzig-update'
  response = http.request(request)
  if response.code == '200'
    return JSON.parse(response.body)
  else
    $stderr.puts "  Failed to fetch latest release: #{response.code} #{response.message}"
    exit 1
  end
rescue => e
  $stderr.puts "  Error fetching latest release: #{e.message}"
  exit 1
end

def read_formula_file
  unless File.exist?(FORMULA_PATH)
    $stderr.puts "Error: #{FORMULA_PATH} not found"
    exit 1
  end
  File.read(FORMULA_PATH)
rescue => e
  $stderr.puts "Error reading #{FORMULA_PATH}: #{e.message}"
  exit 1
end

def write_formula_file(content)
  File.write(FORMULA_PATH, content)
rescue => e
  $stderr.puts "Error writing #{FORMULA_PATH}: #{e.message}"
  exit 1
end

def update_formula_content(original_content, new_version, platform_data)
  content = original_content.dup

  # Check and replace the version line
  version_pattern = /^  version ".*"$/
  unless content.match?(version_pattern)
    $stderr.puts "Error: Could not find version line in formula file (expected pattern: '  version \"VERSION\"')"
    exit 1
  end

  content = content.gsub(version_pattern, "  version \"#{new_version}\"")

  # Check for platform sections
  platform_pattern = /^  on_macos do.*?^  end\n\n^  on_linux do.*?^  end/m
  unless content.match?(platform_pattern)
    $stderr.puts "Error: Could not find expected platform sections (on_macos...end and on_linux...end) in formula file"
    exit 1
  end

  # Build the new platform sections
  macos_section = "  on_macos do\n"
  if platform_data["aarch64-macos"]
    macos_section += "    on_arm do\n"
    macos_section += "      url \"#{platform_data["aarch64-macos"][:url]}\"\n"
    macos_section += "      sha256 \"#{platform_data["aarch64-macos"][:sha256]}\"\n"
    macos_section += "    end\n"
  end
  if platform_data["x86_64-macos"]
    macos_section += "    on_intel do\n"
    macos_section += "      url \"#{platform_data["x86_64-macos"][:url]}\"\n"
    macos_section += "      sha256 \"#{platform_data["x86_64-macos"][:sha256]}\"\n"
    macos_section += "    end\n"
  end
  macos_section += "  end"

  linux_section = "  on_linux do\n"
  if platform_data["aarch64-linux"]
    linux_section += "    on_arm do\n"
    linux_section += "      url \"#{platform_data["aarch64-linux"][:url]}\"\n"
    linux_section += "      sha256 \"#{platform_data["aarch64-linux"][:sha256]}\"\n"
    linux_section += "    end\n"
  end
  if platform_data["x86_64-linux"]
    linux_section += "    on_intel do\n"
    linux_section += "      url \"#{platform_data["x86_64-linux"][:url]}\"\n"
    linux_section += "      sha256 \"#{platform_data["x86_64-linux"][:sha256]}\"\n"
    linux_section += "    end\n"
  end
  linux_section += "  end"

  # Replace the entire platform sections
  content = content.gsub(platform_pattern, "#{macos_section}\n\n#{linux_section}")

  # Verify the replacements actually happened
  unless content.include?("version \"#{new_version}\"")
    $stderr.puts "Error: Failed to update version in formula file"
    exit 1
  end

  unless content.include?(platform_data.values.first[:sha256])
    $stderr.puts "Error: Failed to update platform sections in formula file"
    exit 1
  end

  content
end

puts "Fetching latest release..."
release = fetch_latest_release
tag = release['tag_name']
puts "Latest version: #{tag}"

release_file = "github-release-#{tag}.json"
File.write(release_file, JSON.pretty_generate(release))

platforms = ["aarch64-macos", "x86_64-macos", "aarch64-linux", "x86_64-linux"]
platform_assets = {}
release['assets'].each do |asset|
  asset_name = asset['name']
  platforms.each do |platform|
    if asset_name == "anyzig-#{platform}.tar.gz"
      platform_assets[platform] = asset
      break
    end
  end
end

missing_platforms = platforms - platform_assets.keys
if missing_platforms.any?
  $stderr.puts "Error: missing asset for platforms: #{missing_platforms.join(', ')}"
  exit 1
end

# Collect platform data
platform_data = {}
platform_assets.each do |platform, asset|
  digest = asset['digest']
  if digest.nil? || digest.empty?
    $stderr.puts "Error: GitHub release is missing digest for #{platform}"
    exit 1
  end
  if digest.start_with?('sha256:')
    sha256 = digest.sub('sha256:', '')
    platform_data[platform] = {
      url: "https://github.com/marler8997/anyzig/releases/download/#{tag}/anyzig-#{platform}.tar.gz",
      sha256: sha256
    }
  else
    $stderr.puts "Error: Unexpected digest format for #{platform}: #{digest}"
    exit 1
  end
end

puts "Reading current formula..."
original_content = read_formula_file

puts "Updating formula content..."
updated_content = update_formula_content(original_content, tag, platform_data)

puts "Writing updated formula to #{FORMULA_PATH}..."
write_formula_file(updated_content)

File.delete(release_file)

puts "Successfully updated #{FORMULA_PATH} to version #{tag}"
