function cd4pe::test_connection(TargetSpec $nodes){
  get_targets($nodes).each |$node| {
    if !wait_until_available($node, wait_time => 15, _catch_errors => true).first.ok {
      fail("Could not connect to ${node.name}")
    }
  }
}