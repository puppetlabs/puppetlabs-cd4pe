# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

No unreleased changes.

## [3.0.1](https://github.com/puppetlabs/puppetlabs-cd4pe/tree/3.0.1)
### Changed
- Updated the bolt tasks to properly account for https endpoints

## [3.0.0](https://github.com/puppetlabs/puppetlabs-cd4pe/tree/3.0.0)
### Changed
- Removed all docker installation and database management code. This module will not install CD4PE >= 4.0.0.

## [2.0.1](https://github.com/puppetlabs/puppetlabs-cd4pe/tree/2.0.1)
### Changed
- Added missing resolvable_hostname and web_ui_endpoint parameters from task metadata
### Added
- Adds a new parameter to the 'cd4pe' class to enable configuration of the new query service port
- Add a new paramter to the 'discover_pe_credentials' task to enable configuration of the RBAC token lifetime

## [2.0.0](https://github.com/puppetlabs/puppetlabs-cd4pe/tree/2.0.0)
### Changed
- default value of `$cd4pe_version` param in init.pp from 'latest'(2.x) to '3.x'
### Removed
- puppetlabs-pipelines module dependency
### Added
- OS family checking during installation
### Fixed
- syntax error in postgres.pp
