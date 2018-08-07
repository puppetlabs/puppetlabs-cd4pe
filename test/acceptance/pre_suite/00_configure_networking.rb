# Docker will add the short hostname assigned to a container to /etc/hosts
# which prevents it from having a FQDN despite the best efforts of
# the hack_etc_hosts helper. Puppet farily well looses its mind if a FQDN isn't
# used as certificates start mis-matching accross the board.
#
# This pre-suite scrubs the /etc/hosts file.
test_name 'Ensure Docker networking is sane' do
  extend Beaker::HostPrebuiltSteps
  confine :to, :hypervisor => 'docker'

  step 'Sanitize /etc/hosts' do
    hosts.each do |host|
      # This is required to scrub out any malformed lines that got added by
      # docker that will prevent a FQDN from showing up. The cp business is
      # also required to handle the Docker COW filesystem.
      on(host, 'cp /etc/hosts ~/hosts')
      on(host, "sed -i '/#{host.name}/d' ~/hosts")
      on(host, 'cp -f ~/hosts /etc/hosts')
    end

    hack_etc_hosts(hosts, {})
  end
end

test_name 'Add alias for puppet hostname' do
  extend Beaker::HostPrebuiltSteps
  step 'Add puppet to /etc/hosts' do
    hosts.each do |host|
      set_etc_hosts(host, "#{master['vm_ip']}\tpuppet\n")
    end
  end
end
