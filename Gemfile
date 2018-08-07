source ENV['GEM_SOURCE'] || 'https://rubygems.org'

gem 'rake',    '~> 12.3'

group :acceptance do
  gem 'beaker',                                                     '~> 3.37'
  gem 'beaker-docker',                                              '~> 0.3.3'
  gem 'beaker-puppet',                                              '~> 0.17'
  gem 'beaker-pe',                                                  '~> 1.41'
  gem 'beaker-hostgenerator',                                       '~> 1.1'

  # Used for the Puppet Module Tool
  gem 'puppet',                                                     '~> 5.5'
end

eval_gemfile "#{__FILE__}.local" if File.exists? "#{__FILE__}.local"
