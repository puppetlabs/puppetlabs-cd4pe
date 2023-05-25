# @summary Supported CD4PE runtimes. For further information on supported runtimes, visit
# https://www.puppet.com/docs/continuous-delivery/latest/cd_user_guide.html
type Cd4pe::Runtime = Enum['docker', 'podman']
