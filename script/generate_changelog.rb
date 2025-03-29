require "open3"

latest_tag = `git describe --tags --abbrev=0`.strip

if latest_tag.empty?
  puts "No tags found in the repository. Please create a tag to start generating changelogs."
  exit 1
end

changelog, status = Open3.capture2("git log #{latest_tag}..HEAD --pretty=format:'- %s (%h) by %an'")

unless status.success?
  puts "Error fetching changelog: #{changelog}"
  exit 1
end

if changelog.strip.empty?
  puts "No new commits found since the latest tag (#{latest_tag})."
  exit 0
end

changelog_content = <<~CHANGELOG
  ### From #{latest_tag} to HEAD

  #{changelog}

  Please see our [releases](https://github.com/devxiongmao/truckin-along/releases/) page for previous changelogs per version.

CHANGELOG

File.open("CHANGELOG.md", "w") do |file|
  file.puts changelog_content
end

puts "Changelog generated and saved to CHANGELOG.md"