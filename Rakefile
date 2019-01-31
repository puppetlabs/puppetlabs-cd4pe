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
