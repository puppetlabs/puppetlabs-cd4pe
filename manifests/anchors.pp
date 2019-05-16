# @summary
#   Defines dependency ordering anchors used by other CD4PE classes. These
#   anchors allow relative ordering to be established between classes which
#   may or may not all be present in a configuration. The ordering is defined
#   against the anchors, which WILL always be present when any of the classes
#   that use them are applied.
#
class cd4pe::anchors {

  # Anchor to indicate that service installation is finished. Intended to be
  # used with before/require.
  anchor { 'cd4pe-service-install': }

  # Anchor to pass through refresh events to the service definition. Intended
  # to be used with notify/subscribe.
  anchor { 'cd4pe-service-refresh': }

}
