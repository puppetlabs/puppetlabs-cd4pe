## Release puppetlabs-cd4pe
1. Create a branch off `main` using the following convention:
```shell
git checkout -b 3.1.0-release
```
2. On the new branch, update CHANGELOG.md with any changes in this release and metadata.json with the new version number.
3. Commit these changes
4. Tag the new branch with the new version number
```shell
git tag -a 3.1.0 -m "3.1.0"
```
5. Push your changes to origin for PR review and merge
```shell
git push origin 3.1.0-release --follow-tags
```   
6. Run `pdk build` in the root of the module to get the new tarball
7. Log into https://forge.puppet.com as 'puppetlabs' and publish the new module version (credentials in CD4PE 1Password vault)