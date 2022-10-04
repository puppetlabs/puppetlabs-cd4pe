# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
- No unreleased changes

## [v3.2.5](https://github.com/puppetlabs/puppetlabs-cd4pe/tree/v3.2.5)
### Fixed
- Fixed an issue where the add_repo task would fail if pipelines_as_code_branch was unset

## [v3.2.4](https://github.com/puppetlabs/puppetlabs-cd4pe/tree/v3.2.4)
### Fixed
- Fixed issue when errors received logging in to the CD4PE host would be swallowed by a catch-all exception.

## [v3.2.3](https://github.com/puppetlabs/puppetlabs-cd4pe/tree/v3.2.3)
### Fixed
- Update default web_ui_endpoint handling in tasks to account for /cd4pe prefix in url.

## [3.2.2](https://github.com/puppetlabs/puppetlabs-cd4pe/tree/3.2.2)
### Fixed
- Prevent enforcement of SSL on connections to non-SSL endpoints

## [3.2.1](https://github.com/puppetlabs/puppetlabs-cd4pe/tree/3.2.1)
### Fixed
- Correct name of promote_repo_to_stage task and add commit_sha parameter

## [3.2.0](https://github.com/puppetlabs/puppetlabs-cd4pe/tree/3.2.0)
### Added
- Added promote_repo_to_stage task

## [3.1.0](https://github.com/puppetlabs/puppetlabs-cd4pe/tree/3.1.0)
### Fixed
- Updated cd4pe_client to account for path changes in CD4PE 4.5.0

## [3.0.2](https://github.com/puppetlabs/puppetlabs-cd4pe/tree/3.0.2)
### Fixed
- Updated the module's supported OS list to include el 8

## [3.0.1](https://github.com/puppetlabs/puppetlabs-cd4pe/tree/3.0.1)
### Changed
- Updated the bolt tasks to properly account for https endpoints

## [3.0.0](https://github.com/puppetlabs/puppetlabs-cd4pe/tree/3.0.0)
### Changed
- Removed all docker installation and database management code. This module will not install CD4PE >= 4.0.0.
- Changed the `cd4pe::impact_analysis::legacy::whitelisted_certnames` parameter to `allowed_certnames`. If you are using PE 2017.3.0 to 2019.1.0, update the parameter name wherever it is in use. If you are using PE 2019.2.0 and newer, remove the parameter because it is no longer required. 

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
