**Introduction**

This tooling configures object storage, can enable SSL, creates a default user and workspace, and can set up a VCS for a freshly provisioned CD4PE VMs. It also creates the root account and sets a trial license.

Use of the `configTestVm.sh` script requires nothing but Docker. Your `~/.ssh/id_rsa` SSH key will be used to clone dependencies from private GitHub repositories.

**Environmental setup**

This was developed and tested using Ruby 2.4.1 (because thats what we use in Jenkins). Use any Ruby environment tool (rbenv, rvm) to use that or a higher version, and perform a `bundle install --path .vendor`.

**Invoking**

    ./configTestVm.sh

To specify the repo and version of the image to install, set the same environment vars as the build system, `CD4PE_IMAGE` and `CD4PE_VERSION`; the image repo defaults to `artifactory.delivery.puppetlabs.net/cd4pe-dev` and the currently supported database is `postgres`.

No arguments are required. By default, it will create a VM using the Artifactory object-store, not enable SSL and create a default user & workspace. To modify this behaviour, use the following switches (default values):

    -o|--object-store disk|artifactory      specify the object-store (artifactory)
    -s|--ssl                                configure SSL (not configured)
    -b|--base <base>                        specify base name of workspace, email & username (otto)
    -v|--vcs-provider <vcs>                 specify the VCS provider (none)

For `--base <base>`, the default names are `<base>@example.com`, `<base>_ws` and `<base>` (email, workspace, username).

For `--vcs-provider <vcs>`, supported providers include Gitlab (gitlab), GitHub Enterprise (GHE) and Bitbucker Server (bbs).

**Caveats & implementation notes**

This script will create local `inventory.yaml` and `params.json` files, and remove any existing ones. The `../inventory.yaml` file is left for further bolt runs; the `params.json` file contains sensitive information and is removed upon a successful run.

This uses the dev version of the puppetlabs-cd4pe module; in other words, it runs what you are currently working on.

BOLT 2.x is required.
