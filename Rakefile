require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_litmus/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet_blacksmith/rake_tasks' if Bundler.rubygems.find_name('puppet-blacksmith').any?
require 'github_changelog_generator/task' if Bundler.rubygems.find_name('github_changelog_generator').any?
require 'puppet-strings/tasks' if Bundler.rubygems.find_name('puppet-strings').any?
require 'json'
require 'bolt_spec/run'

ignore_paths = ["checkouts/**/*", "dev/**/*", "dev-resources/**/*", "test/**/*", "src/**/*", "vendor/**/*", "spec/fixtures/**/*"]

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

namespace :ci do
  task :create_inventory_file, [:hostname, :platform] do |t, args|
    hostname = args[:hostname] || ENV['CI_HOSTNAME']
    platform = args[:platform] || ENV['CI_PLATFORM']
    # this method comes from https://github.com/puppetlabs/provision/blob/master/lib/task_helper.rb
    # should this method be in core litmus?
    if File.file?('inventory.yaml')
      inventory_hash = inventory_hash_from_inventory_file('inventory.yaml')
    else
      inventory_hash = {
        'groups' => [
          { 'name' => 'docker_nodes', 'nodes' => [] },
          { 'name' => 'ssh_nodes', 'nodes' => [] },
          { 'name' => 'winrm_nodes', 'nodes' => [] }
        ]}
    end

    node = {
      'name' => hostname,
      'config' => {
        'transport' => 'ssh',
        'ssh' => {
          'user' => 'root',
          'password' => 'Qu@lity!',
          'host-key-check' => false
        }
      },
      'facts' => {
        'provisioner' => 'abs',
        'platform' => platform,
      }
    }

    add_node_to_group(inventory_hash, node, 'ssh_nodes')
    puts "writing hash to disk: #{inventory_hash}"
    write_to_inventory_file(inventory_hash, 'inventory.yaml')
  end
end

namespace :test do
  namespace :install do
    namespace :cd4pe do
      task :module, [:image, :version] do |t, args|
        image = args[:image] || ENV['CD4PE_IMAGE']
        version = args[:version] || ENV['CD4PE_VERSION']

        Rake::Task['spec_prep'].invoke
        if File.exists?('inventory.yaml')
          # inventory_hash_from_inventory_file throws error if inventory file doesn't exist
          inventory_hash = inventory_hash_from_inventory_file
          targets = find_targets(inventory_hash, nil)
        else 
          targets = nil
        end

        if targets.nil? or targets.empty?
          Rake::Task['litmus:provision'].invoke('vmpooler', 'centos-7-x86_64')
          inventory_hash = inventory_hash_from_inventory_file
          targets = find_targets(inventory_hash, nil)
          target = targets.first
        else
          target = targets.first
        end

        add_node_to_group(inventory_hash, target, 'cd4pe')

        cd4pe_image = image.nil? ? "" : "cd4pe_image => '#{image}',"
        cd4pe_version = version.nil? ? "" : "cd4pe_version => '#{version}',"

        Rake::Task['litmus:install_agent'].invoke('puppet6')
        puts "installing cd4pe module"
        Rake::Task['litmus:install_module'].invoke
        include BoltSpec::Run
        config_data = { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') }
        manifest = <<-MANIFEST
          include docker
          docker::run { 'cd4pe_postgres':
            image                 => 'postgres:9.6',
            net                   => 'cd4pe',
            ports                 => ["5432:5432"],
            volumes               => ['cd4pe-postgres:/var/lib/postgresql/data'],
            env                   => ['POSTGRES_PASSWORD=puppetlabs'],
            health_check_interval => 10,
          }

          class { "cd4pe":
            #{cd4pe_image}
            #{cd4pe_version}
            manage_database => false,
            db_host         => 'cd4pe_postgres',
            db_name         => 'postgres',
            db_pass         => Sensitive('puppetlabs'),
            db_port         => 5432,
            db_provider     => 'postgres',
            db_user         => 'postgres',
            db_prefix       => 'test',
            analytics       => false,
          }
        MANIFEST
        ret = apply_manifest(manifest, target, execute:true, config: config_data, inventory: inventory_hash)
        puts ret
      end
    end
  end

end

namespace :test_environment do
  desc "Provision nodes for a CD4PE test environment"
  task :provision do
    Rake::Task['spec_prep'].invoke
    Rake::Task['litmus:provision'].invoke('vmpooler', 'centos-7-x86_64')
    Rake::Task['litmus:provision'].reenable
    Rake::Task['litmus:provision'].invoke('vmpooler', 'centos-7-x86_64')
  end

	desc "Set up a test environment for CD4PE"
	task :setup, [:environment_type, :pe_version, :pe_source_provider, :cd4pe_install_type, :cd4pe_image, :cd4pe_version] => :provision do |t, args|
    # Provision some test nodes and perform installation/configuration of PE & CD4PE
    include BoltSpec::Run
    inventory_hash = inventory_hash_from_inventory_file
    config_data = { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') }
    args.with_defaults(
      :environment_type => 'acceptance',
      :pe_version => '2019.1.0',
      :pe_source_provider => 's3',
      :cd4pe_install_type => 'installer_task',
      :cd4pe_image => 'pcr-internal.puppet.net/pipelines/pfi',
      :cd4pe_version => 'latest',
    )
    params = {
      'environment_type' => args[:environment_type],
      'pe_version' => args[:pe_version],
      'pe_source_provider' => args[:pe_source_provider],
      'cd4pe_install_type' => args[:cd4pe_install_type],
      'cd4pe_image' => args[:cd4pe_image],
      'cd4pe_version' => args[:cd4pe_version],
    }
    result = run_plan('cd4pe_test_tasks::setup_test_environment',
      params,
      config: config_data,
      inventory: inventory_hash,
      )
    puts result
  end

	desc "Run the CD4PE acceptance tests"
	task :test do
	  # Run tests
	end

	desc "Teardown the CD4PE acceptance test hosts"
	task :teardown do
    # Teardown the test environment
    inventory_hash = inventory_hash_from_inventory_file
    targets = find_targets(inventory_hash, nil)
    targets.each  { |t|
      Rake::Task['litmus:tear_down'].invoke(t)
      Rake::Task['litmus:tear_down'].reenable
     }
  end
end

namespace :test do
  desc "Provision nodes for a CD4PE test environment"
  task :provision do
    Rake::Task['spec_prep'].invoke
    Rake::Task['litmus:provision'].invoke('vmpooler', 'centos-7-x86_64')
    Rake::Task['litmus:provision'].reenable
    Rake::Task['litmus:provision'].invoke('vmpooler', 'centos-7-x86_64')
  end
  namespace :install do
    task :pe do
      inventory_hash = inventory_hash_from_inventory_file
      puts inventory_hash
    end
    namespace :cd4pe do
      task :oneclick do
      end

      task :module do
        Rake::Task['spec_prep'].invoke

        if File.exists?('inventory.yaml')
          # inventory_hash_from_inventory_file throws error if inventory file doesn't exist
          inventory_hash = inventory_hash_from_inventory_file
          targets = find_targets(inventory_hash, nil)
        else
          targets = nil
        end

        if targets.nil? or targets.empty?
          Rake::Task['litmus:provision'].invoke('vmpooler', 'centos-7-x86_64')
          inventory_hash = inventory_hash_from_inventory_file
          targets = find_targets(inventory_hash, nil)
          target = targets.first
        else
          target = targets.first
        end

        add_node_to_group(inventory_hash, target, 'cd4pe')


        Rake::Task['litmus:install_agent'].invoke('puppet6')
        puts "installing cd4pe module"
        Rake::Task['litmus:install_module'].invoke
        include BoltSpec::Run
        config_data = { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') }
        manifest = <<-MANIFEST
          include docker
          docker::run { 'cd4pe_postgres':
            image                 => 'postgres:9.6',
            net                   => 'cd4pe',
            ports                 => ["5432:5432"],
            volumes               => ['cd4pe-postgres:/var/lib/postgresql/data'],
            env                   => ['POSTGRES_PASSWORD=puppetlabs'],
            health_check_interval => 10,
          }

          class { "cd4pe":
            manage_database => false,
            db_host         => 'cd4pe_postgres',
            db_name         => 'postgres',
            db_pass         => Sensitive('puppetlabs'),
            db_port         => 5432,
            db_provider     => 'postgres',
            db_user         => 'postgres',
            db_prefix       => 'test',
          }
        MANIFEST
        ret = apply_manifest(manifest, target, execute:true, config: config_data, inventory: inventory_hash)
        puts ret
      end
    end
  end

end
