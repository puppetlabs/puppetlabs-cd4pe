# A shorthand for providing a default value if the given one is undef
function cd4pe::default_for_value(Any $value, NotUndef $default) {
  $resolved = $value ? {
    undef => $default,
    default => $value
  }
}
