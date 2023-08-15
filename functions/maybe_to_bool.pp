function cd4pe::maybe_to_bool(Any $value) {
  $bool_or_undef = $value ? {
    undef   => undef,
    default => Boolean($value),
  }
}
