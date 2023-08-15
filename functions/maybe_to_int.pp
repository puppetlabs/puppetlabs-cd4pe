# If the value is undef, returns undef, otherwise attempts to cast to an int.
function cd4pe::maybe_to_int(Any $value) {
  $int_or_undef = $value ? {
    undef   => undef,
    default => Integer($value),
  }
}
