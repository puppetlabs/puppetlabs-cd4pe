require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_litmus/rake_tasks' if Bundler.rubygems.find_name('puppet_litmus').any?
require 'puppet_litmus/inventory_manipulation' if Bundler.rubygems.find_name('puppet_litmus').any?
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet_blacksmith/rake_tasks' if Bundler.rubygems.find_name('puppet-blacksmith').any?
require 'github_changelog_generator/task' if Bundler.rubygems.find_name('github_changelog_generator').any?
require 'puppet-strings/tasks' if Bundler.rubygems.find_name('puppet-strings').any?
require 'json'
require 'bolt_spec/run' if Bundler.rubygems.find_name('bolt_spec/run').any?

ignore_paths = ["checkouts/**/*", "dev/**/*", "dev-resources/**/*", "test/**/*", "src/**/*", "vendor/**/*", "spec/**/*"]

PuppetSyntax.exclude_paths = ignore_paths

PuppetLint::RakeTask.new :lint do |config|
  # Pattern of files to ignore
  config.ignore_paths = ignore_paths
  config.pattern = "manifests/**/*.pp"
end

def changelog_user
  return unless Rake.application.top_level_tasks.include? "changelog"
  returnVal = nil || JSON.load(File.read('metadata.json'))['author']
  raise "unable to find the changelog_user in .sync.yml, or the author in metadata.json" if returnVal.nil?
  puts "GitHubChangelogGenerator user:#{returnVal}"
  returnVal
end

def changelog_project
  return unless Rake.application.top_level_tasks.include? "changelog"
  returnVal = nil || JSON.load(File.read('metadata.json'))['name']
  raise "unable to find the changelog_project in .sync.yml or the name in metadata.json" if returnVal.nil?
  puts "GitHubChangelogGenerator project:#{returnVal}"
  returnVal
end

def changelog_future_release
  return unless Rake.application.top_level_tasks.include? "changelog"
  returnVal = JSON.load(File.read('metadata.json'))['version']
  raise "unable to find the future_release (version) in metadata.json" if returnVal.nil?
  puts "GitHubChangelogGenerator future_release:#{returnVal}"
  returnVal
end

PuppetLint.configuration.send('disable_relative')

if Bundler.rubygems.find_name('github_changelog_generator').any?
  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    raise "Set CHANGELOG_GITHUB_TOKEN environment variable eg 'export CHANGELOG_GITHUB_TOKEN=valid_token_here'" if Rake.application.top_level_tasks.include? "changelog" and ENV['CHANGELOG_GITHUB_TOKEN'].nil?
    config.user = "#{changelog_user}"
    config.project = "#{changelog_project}"
    config.future_release = "#{changelog_future_release}"
    config.exclude_labels = ['maintenance']
    config.header = "# Change log\n\nAll notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org)."
    config.add_pr_wo_labels = true
    config.issues = false
    config.merge_prefix = "### UNCATEGORIZED PRS; GO LABEL THEM"
    config.configure_sections = {
      "Changed" => {
        "prefix" => "### Changed",
        "labels" => ["backwards-incompatible"],
      },
      "Added" => {
        "prefix" => "### Added",
        "labels" => ["feature", "enhancement"],
      },
      "Fixed" => {
        "prefix" => "### Fixed",
        "labels" => ["bugfix"],
      },
    }
  end
else
  desc 'Generate a Changelog from GitHub'
  task :changelog do
    raise <<EOM
The changelog tasks depends on unreleased features of the github_changelog_generator gem.
Please manually add it to your .sync.yml for now, and run `pdk update`:
---
Gemfile:
  optional:
    ':development':
      - gem: 'github_changelog_generator'
        git: 'https://github.com/skywinder/github-changelog-generator'
        ref: '20ee04ba1234e9e83eb2ffb5056e23d641c7a018'
        condition: "Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.2.2')"
EOM
  end
end

PROJECT_ROOT = File.dirname(__FILE__)
Dir.chdir(PROJECT_ROOT) # Ensure all paths expand relative to this Rakefile.

MODULE_METADATA = JSON.parse(File.read('metadata.json'))

# Set to a tagged version or other git ref.
PUPPETSERVER_VERSION = if ENV.has_key?('PUPPETSERVER_VERSION')
                         ENV['PUPPETSERVER_VERSION']
                       else
                         ENV['PUPPETSERVER_VERSION'] = '5.3.4'
                         ENV['PUPPETSERVER_VERSION']
                       end
PUPPETSERVER_SUBMODULE = File.join('checkouts', 'puppetserver')
PUPPETSERVER_PROJECT = File.join(PUPPETSERVER_SUBMODULE, 'project.clj')
# FIXME: Figure out a way to actually find the Jarfile for the currently
# checked out server version. However, this might require invoking lein
# every time rake is invoked --- which is expensive.
PUPPETSERVER_JAR = File.join(PUPPETSERVER_SUBMODULE, 'target')

PLUGIN_JAR = File.join('target', 'cdpe-api.jar')
PLUGIN_JAR_AOT = File.join('target', 'cdpe-api-aot.jar')
PLUGIN_JAR_SRCS = Rake::FileList['project.clj',
                                 'src/**/*.clj',
                                 'src/**/*.rb',
                                 PUPPETSERVER_JAR]

MODULE_PKG = "pkg/#{MODULE_METADATA['name']}-#{MODULE_METADATA['version']}.tar.gz"
MODULE_PKG_SRCS = Rake::FileList['metadata.json',
                                 'CHANGELOG.md',
                                 'LICENSE',
                                 'README.md',
                                 'manifests/**/*.pp',
                                 'lib/**/*.rb',
                                 'files/cdpe-api.jar',
                                 'files/cdpe-api-aot.jar']

namespace :puppetserver do
  desc "Ensure Puppet Server submodule is at ref: #{PUPPETSERVER_VERSION}"
  task :update => PUPPETSERVER_PROJECT do
    Dir.chdir(PUPPETSERVER_SUBMODULE) do
      # TODO: Raise useful error message if either of these commits does
      #       not exist in the repo.
      current_ref = `git rev-parse HEAD^{commit}`.chomp
      target_ref = `git rev-parse #{PUPPETSERVER_VERSION}^{commit}`.chomp

      if current_ref != target_ref
        # Clear target directory to force a JAR rebuild.
        sh 'rm -rf target'
        sh "git reset --hard #{PUPPETSERVER_VERSION}"
        sh 'git submodule update --init --recursive'
      end
    end
  end

  desc "Build Puppet Server's JAR and install it to the local mvn repo"
  task :install => 'puppetserver:update' do
    Dir.chdir(PUPPETSERVER_SUBMODULE) do
      sh 'lein install'
    end
  end
end

namespace :build do
  desc 'Build the plugin JAR'
  task :jar do
    sh 'lein with-profile +puppet-module jar'
  end

  desc 'Build the plugin JAR'
  task :jar_aot do
    sh 'lein with-profile +puppet-module-aot jar'
  end

  desc 'Build the module package'
  task :module => MODULE_PKG do
    sh 'pdk build --force'
  end
end

# Rules for ensuring files exist and are up to date.

file PUPPETSERVER_PROJECT do
  sh 'git submodule update --init --recursive'
end

directory PUPPETSERVER_JAR => PUPPETSERVER_PROJECT do
  Rake::Task['puppetserver:install'].invoke
end

file PLUGIN_JAR => PLUGIN_JAR_SRCS do
  Rake::Task['build:jar'].invoke
end

file PLUGIN_JAR_AOT => PLUGIN_JAR_SRCS do
  Rake::Task['build:jar_aot'].invoke
end

directory 'files/'

file 'files/cdpe-api.jar' => ['files/', PLUGIN_JAR] do
  cp PLUGIN_JAR, 'files/cdpe-api.jar'
end

file 'files/cdpe-api-aot.jar' => ['files/', PLUGIN_JAR_AOT] do
  cp PLUGIN_JAR_AOT, 'files/cdpe-api-aot.jar'
end

file MODULE_PKG => MODULE_PKG_SRCS do
  Rake::Task['build:module'].invoke
end

