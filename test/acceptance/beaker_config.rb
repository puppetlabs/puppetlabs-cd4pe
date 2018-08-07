# This file should be loaded via Beaker's `--options-file` switch to ensure
# the Docker gem is pre-loaded so that hosts_preserved.yml files containing
# Docker objects can be parsed.
require 'docker'

# Beaker expects evaluating this file to produce a hash.
Hash.new
