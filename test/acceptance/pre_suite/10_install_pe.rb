require 'beaker-pe'

test_name 'Install PE' do
  confine :to, :type => 'pe'

  step 'Install PE prereqs' do
    if master[:hypervisor] == 'docker'
      # TODO: Prereq for CentOS 7. Map out additonal PE master platforms:
      #  - CentOS 6
      #  - Ubuntu 16.04
      #  - Ubuntu 14.04
      #  - Sles 12
      #  - SLES 11
      hosts.each do |h|
        install_package(h, 'cronie')
      end
    end
  end

  step 'Install Puppet Enterprise' do
    answers = {'puppet_enterprise::puppet_master_host': '%{::trusted.certname}',
               'pe_install::puppet_master_dnsaltnames': ['%{::trusted.certname}',
                                                         "#{master.hostname}",
                                                         'puppet'],
               'puppet_enterprise::master::puppetserver::jruby_max_active_instances': 1,
               'puppet_enterprise::profile::master::java_args': {'Xmx': '384m',
                                                                 'Xms': '128m'},
               'puppet_enterprise::profile::puppetdb::java_args': {'Xmx': '128m',
                                                                   'Xms': '64m'},
               'puppet_enterprise::profile::console::java_args': {'Xmx': '96m',
                                                                  'Xms': '64m'},
               'puppet_enterprise::profile::orchestrator::java_args': {'Xmx': '64m',
                                                                       'Xms': '64m'}}
    install_pe_on(hosts, answers: answers)
    create_remote_file(master, '/etc/puppetlabs/puppet/autosign.conf', "*\n")
    on(master, 'chown pe-puppet /etc/puppetlabs/puppet/autosign.conf')
  end
end
