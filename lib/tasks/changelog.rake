namespace :generate do
  desc "Generate a changelog from the latest git tag to HEAD"
  task :changelog => :environment do
    require 'open3'

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
      ## Changelog
      ### From #{latest_tag} to HEAD
  
      #{changelog}

    CHANGELOG
  
    File.open("CHANGELOG.md", "a") do |file|
      file.puts changelog_content
    end
  
    puts "Changelog generated and saved to CHANGELOG.md"
  end
end
  