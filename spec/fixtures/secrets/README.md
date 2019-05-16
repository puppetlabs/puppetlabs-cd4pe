# Secrets for CD4PE acceptance & scale testing

Before running the CD4PE test environment setup tasks you will need to add the relevant private keys to this secrets directory. These keys will be uploaded to the test hosts.

1. Add the private key found in the CD4PE 1Password vault under the title `CD4PE Acceptance Test Control Repo Deploy Key` and place in this secrets directory with the name `cd4pe-acceptance-control-repo`. This key is the deploy key used for the acceptance test control repo.
2. Add the private key found in the CD4PE 1Password vault under the title `CD4PE Acceptance Test Module Deploy Key
` and place in this secrets directory with the name `cd4pe-acceptance-module`.