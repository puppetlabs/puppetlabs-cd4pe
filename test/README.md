**Introduction**

This tooling configures object storage, can enable SSL, and creates a default user and workspace for freshly provisioned CD4PE VMs. It also creates the root account and sets a trial license.

Use of this script requires local installation of the 1Password `op` utility, here: https://support.1password.com/command-line-getting-started/, and full docs are here: https://support.1password.com/command-line/

**Environmental setup**

This was developed and tested using Ruby 2.4.1 (because thats what we use in Jenkins). Use any Ruby environment tool (rbenv, rvm) to use that or a higher version, and perform a `bundle install --path .vendor`.

**Invoking**

    ./configTestVm.sh

To specify the repo and version of the image to install, set the same environment vars as the build system, `CD4PE_IMAGE` and `CD4PE_VERSION`; the image repo defaults to `artifactory.delivery.puppetlabs.net/cd4pe-dev` and the currently supported database is `postgres`.

No arguments are required. By default, it will create a VM using the disk object-store, not enable SSL and create a default user & workspace. To modify this behaviour, use the following switches (default values):

    -o|--object-store disk|artifactory|s3   specify the object-store (disk)
    -s|--ssl                                configure SSL (not configured)
    -p|--no-po-check                        disable the 1Password op tool sanity check (enabled)
    -b|--base <base>                        specify base name of workspace, email & username (otto)

For `--no-po-check`, the `op` tool uses a 30 minute token, and occasionally gets confused when checking token status; this short-circuits the check, but a valid token is still required for the tool itself to work. You can create the following Bash alias to make it simpler to re-up the token:

    alias optoken='eval $(op signin puppet)'

For `--base <base>`, the default names are `<base>@example.com`, `<base>_ws` and `<base>` (email, workspace, username).

**Caveats & implementation notes**

This script will create local `inventory.yaml` and `params.json` files in the `.../puppetlabs-cd4pe/test` directory, and remove any existing ones. The `inventory.yaml` file is left for further bolt runs; the `params.json` file contains sensitive information and is removed upon a successful run.

In order to get a current version of the puppetlabs-cd4pe module, it pulls from the `master` branch in Github. This can be overidden by pointing the environment variable `DEV_BRANCH` to the desired branch name.

BOLT 2.x is required.