require 'json'

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
                                 'files/cdpe-api.jar']

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

  desc 'Build the module package'
  task :module => MODULE_PKG do
    sh 'puppet module build'
  end
end

acceptance_task_defaults = {
  type: 'foss',
  version: PUPPETSERVER_VERSION,
  platform: 'centos7',
  hypervisor: 'docker'
}

def get_docker_image(platform)
  case platform
  when 'centos7'
    'centos:centos7'
  when 'centos6'
    'centos:centos6'
  when 'ubuntu1604'
    'ubuntu:16.04'
  when 'ubuntu1804'
    'ubuntu:18.04'
  else
    raise ArgumentError, "No Docker image defined for platform: #{platform}"
  end
end

def get_hypervisor_args(args)
  case args[:hypervisor]
  when 'docker'
    image = get_docker_image(args[:platform])
    pe_source = "https://s3.amazonaws.com/pe-builds/released/#{args[:version]}"

    # TODO: Consider cleaning this up into something a bit easier to read.
    ['--hosts',
     "#{args[:platform]}-64mdca{hypervisor=docker,image=#{image},docker_cmd=/sbin/init,pe_dir=#{pe_source},pe_ver=#{args[:version]}}"]
  when 'vmpooler'
    pe_source = if args[:version].match(/g[0-9a-f]+$/)
                  # Pre-release build.
                  release_series = args[:version].split('.')[0..1].join('.')
                  "http://enterprise.delivery.puppetlabs.net/#{release_series}/ci-ready"
                else
                  "http://pe-releases.puppetlabs.lan/#{args[:version]}"
                end

    ['--hosts',
     "#{args[:platform]}-64mdca{pe_dir=#{pe_source},pe_ver=#{args[:version]}}",
     '--keyfile', '~/.ssh/id_rsa-acceptance']
  else
    raise ArgumentError, "No beaker-hostgenerator conversions defined for: #{args[:hypervisor]}"
  end
end

namespace :test do
  desc 'Run Clojure integration tests'
  task :integration => PUPPETSERVER_JAR do
    sh 'lein test :integration'
  end

  # TODO: Use rototiller to bring sanity to these Rake arguments.

  desc 'One-shot run of Beaker acceptance tests that cleans up VMs afterwards'
  task :acceptance, [:type, :platform, :version, :hypervisor] => MODULE_PKG do |_, args|
    args.with_defaults(acceptance_task_defaults)

    sh 'beaker', '--debug',
      '--type', args[:type],
      '--pre-suite', 'test/acceptance/pre_suite',
      '--tests', 'test/acceptance/tests',
      *get_hypervisor_args(args)
  end

  namespace :acceptance do
    desc 'Boot and run Beaker pre-suites leaving VMs staged for further tests'
    task :stage, [:type, :platform, :version, :hypervisor] => MODULE_PKG do |_, args|
      args.with_defaults(acceptance_task_defaults)

      sh 'beaker', '--debug',
        '--type', args[:type],
        '--pre-suite', 'test/acceptance/pre_suite',
        '--preserve-hosts=onpass',
        *get_hypervisor_args(args)
    end

    desc 'Run Beaker acceptance tests on staged VMs'
    task :run => MODULE_PKG do |_, args|
      sh 'beaker', '--debug',
        '--options-file', 'test/acceptance/beaker_config.rb',
        # Ensures docker gem is loaded --^
        '--hosts', 'log/latest/hosts_preserved.yml',
        '--tests', 'test/acceptance/tests',
        '--preserve-hosts=always',
        '--no-validate', '--no-configure'
    end

    desc 'Clean up staged VMs'
    task :destroy do
      sh 'beaker', '--debug',
        '--options-file', 'test/acceptance/beaker_config.rb',
        # Ensures docker gem is loaded --^
        '--hosts', 'log/latest/hosts_preserved.yml',
        '--preserve-hosts=never'
    end
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

directory 'files/'

file 'files/cdpe-api.jar' => ['files/', PLUGIN_JAR] do
  cp PLUGIN_JAR, 'files/cdpe-api.jar'
end

file MODULE_PKG => MODULE_PKG_SRCS do
  Rake::Task['build:module'].invoke
end
