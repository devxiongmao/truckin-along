# frozen_string_literal: true

require 'open3'

class AutoVersionBumper
  VERSION_FILE = 'VERSION'

  def self.bump_version
    current_version = current_version_from_file || '0.0.0'
    next_version = calculate_next_version(current_version)

    if next_version
      update_version_file(next_version)
      puts "Version bumped to: #{next_version}"
    else
      puts 'No changes detected; version remains the same.'
    end
  end

  def self.current_version_from_file
    return unless File.exist?(VERSION_FILE)

    File.read(VERSION_FILE).strip
  end

  def self.calculate_next_version(current_version)
    commits = commits_since_last_version(current_version)
    return nil if commits.empty?

    major, minor, patch = current_version.split('.').map(&:to_i)

    if commits.any? { |msg| msg.match?(/(?:\b|\()?(breaking|major)(?:\b|\))?/i) }
      major += 1
      minor = 0
      patch = 0
    elsif commits.any? { |msg| msg.match?(/(?:\b|\()?(feature|minor)(?:\b|\))?/i) }
      minor += 1
      patch = 0
    else
      patch += 1
    end

    "#{major}.#{minor}.#{patch}"
  end

  def self.commits_since_last_version(current_version)
    tag = "v#{current_version}"
    command = "git log #{tag}..HEAD --pretty=format:%s"
    output, status = Open3.capture2(command)

    return [] unless status.success?

    output.split("\n")
  end

  def self.update_version_file(version)
    File.write(VERSION_FILE, version)
    puts "Updated #{VERSION_FILE} with version: #{version}"
  end
end

AutoVersionBumper.bump_version
