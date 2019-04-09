require 'puppet/node'
require 'puppet/resource/catalog'
require 'puppet/indirector/code'
require 'puppet/util/profiler'
require 'yaml'

# This code is a lift directly from https://github.com/puppetlabs/puppetlabs-catalog_preview
# Until https://tickets.puppetlabs.com/browse/PUP-9055 has been completed.
class Puppet::Resource::Catalog::CdpeCompiler < Puppet::Indirector::Code
  desc 'Compiles a catalog for a node.'

  include Puppet::Util

  attr_accessor :code

  def extract_facts_from_request(request)
    return unless text_facts = request.options[:facts]
    unless format = request.options[:facts_format]
      raise ArgumentError, "Facts but no fact format provided for #{request.key}"
    end

    Puppet::Util::Profiler.profile('Found facts', [:compiler, :find_facts]) do
      # If the facts were encoded as yaml, then the param reconstitution system
      # in Network::HTTP::Handler will automagically deserialize the value.
      facts = if text_facts.is_a?(Puppet::Node::Facts)
                text_facts
              else
                # We unescape here because the corresponding code in Puppet::Configurer::FactHandler escapes
                Puppet::Node::Facts.convert_from(format, CGI.unescape(text_facts))
              end

      unless facts.name == request.key
        raise Puppet::Error, "Catalog for #{request.key.inspect} was requested with fact definition for the wrong node (#{facts.name.inspect})."
      end

      options = {
        environment: request.environment,
        transaction_uuid: request.options[:transaction_uuid],
      }

      Puppet::Node::Facts.indirection.save(facts, nil, options)
    end
  end

  # The find request should
  # - change logging to json output (as directed by baseline-log option)
  # - compile in the baseline (reqular) environment given by the node/infrastructure
  # - change logging to json output (as directed by preview-log option)
  # - compile in the preview environment as directed by options
  # - return a hash containing the baseline and preview catalogs
  #
  # Compile a node's catalog.
  def find(request)
    extract_facts_from_request(request)
    node = sanitize_node(node_from_request(request))
    compile(node, request.options)
  end

  # This method is copied from a Puppet::Parser::Compiler in Puppet 4.4.0
  def sanitize_node(node)
    # Resurrect "trusted information" that comes from node/fact terminus.
    # The current way this is done in puppet db (currently the only one)
    # is to store the node parameter 'trusted' as a hash of the trusted information.
    #
    # Thus here there are two main cases:
    # 1. This terminus was used in a real agent call (only meaningful if someone curls the request as it would
    #  fail since the result is a hash of two catalogs).
    # 2  It is a command line call with a given node that use a terminus that:
    # 2.1 does not include a 'trusted' fact - use local from node trusted information
    # 2.2 has a 'trusted' fact - this in turn could be
    # 2.2.1 puppet db having stored trusted node data as a fact (not a great design)
    # 2.2.2 some other terminus having stored a fact called "trusted" (most likely that would have failed earlier, but could
    #       be spoofed).
    #
    # For the reasons above, the resurection of trusted node data with authenticated => true is only performed
    # if user is running as root, else it is resurrected as unauthenticated.
    trusted_param = node.parameters['trusted']
    if trusted_param
      # Blows up if it is a parameter as it will be set as $trusted by the compiler as if it was a variable
      node.parameters.delete('trusted')
      unless trusted_param.is_a?(Hash) && ['authenticated', 'certname', 'extensions'].all? { |key| trusted_param.key?(key) }
        # trusted is some kind of garbage, do not resurrect
        trusted_param = nil
      end
    else
      # trusted may be boolean false if set as a fact by someone
      trusted_param = nil
    end

    # The options for node.trusted_data in priority order are:
    # 1) node came with trusted_data so use that
    # 2) else if there is :trusted_information in the puppet context
    # 3) else if the node provided a 'trusted' parameter (parsed out above)
    # 4) last, fallback to local node trusted information
    #
    # Note that trusted_data should be a hash, but (2) and (4) are not
    # hashes, so we to_h at the end
    unless node.trusted_data
      trusted = Puppet.lookup(:trusted_information) do
        trusted_param || Puppet::Context::TrustedInformation.local(node)
      end

      # Ruby 1.9.3 can't apply to_h to a hash, so check first
      node.trusted_data = trusted.is_a?(Hash) ? trusted : trusted.to_h
    end

    node
  end

  # filter-out a catalog to remove exported resources
  def filter(catalog)
    return catalog.filter { |r| r.virtual? } if catalog.respond_to?(:filter)
    catalog
  end

  def initialize
    Puppet::Util::Profiler.profile('Setup server facts for compiling', [:cdpe_compiler, :init_server_facts]) do
      set_server_facts
    end
  end

  # Is our compiler part of a network, or are we just local?
  def networked?
    Puppet.run_mode.master?
  end

  private

  # Add any extra data necessary to the node.
  def add_node_data(node)
    # Merge in our server-side facts, so they can be used during compilation.
    node.add_server_facts(@server_facts)
  end

  # Compile baseline and preview catalogs
  #
  def compile(node, options)
    preview_catalog = nil
    @logs = []
    preview_dest = Puppet::Test::LogCollector.new(@logs)

    begin
      # Preview compilation
      #
      Puppet::Util::Log.close_all
      Puppet::Util::Log.newdestination(preview_dest)
      Puppet::Util::Log.with_destination(preview_dest) do
        env = options[:preview_environment]
        if env.nil?
          # Loose the cached environment
          node.environment = node.environment.name
        else
          node.environment = env
          node.parameters['environment'] = node.environment.name
        end

        # Add any external data to the node.
        add_node_data(node)

        Puppet::Util::Profiler.profile(node.name, [:cdpe_compiler, :compile_preview, node.environment, node.name]) do
          # Switch the node's environment (it finds and instantiates the Environment)

          # override environment with specified env for preview
          overrides = { current_environment: node.environment }

          Puppet.override(overrides, 'puppet-preview-compile') do
            begin
              preview_catalog = Puppet::Parser::Compiler.compile(node)
              if node.facts.nil? || node.facts.values.nil? || node.facts.values['osfamily'].nil?
                # Node does not have a valid factset.
                error_msg = "Facts seems to be missing. No 'osfamily' fact found for node '#{node.name}'"
                raise Puppet::Error, error_msg
              end
            rescue StandardError => e
              raise Puppet::Error, "Error while compiling the preview catalog: #{e}"
            end
          end
        end
      end
    rescue Puppet::Error => detail
      Puppet.err(detail.to_s) if networked?
      raise
    ensure
      Puppet::Util::Log.newdestination(:console)
      Puppet::Util::Log.close(preview_dest)
      options[:back_channel][:logs] = @logs
    end

    preview_catalog
  end

  # Turn our host name into a node object.
  def find_node(name, environment, transaction_uuid)
    Puppet::Util::Profiler.profile('Found node information', [:cdpe_compiler, :find_node]) do
      node = nil
      begin
        node = Puppet::Node.indirection.find(name,
                                             environment: environment,
                                             transaction_uuid: transaction_uuid)
      rescue => detail
        message = "Failed when searching for node #{name}: #{detail}"
        Puppet.log_exception(detail, message)
        raise Puppet::Error, message, detail.backtrace
      end

      node
    end
  end

  # Extract the node from the request, or use the request
  # to find the node.
  def node_from_request(request)
    if node = request.options[:use_node]
      if request.remote?
        raise Puppet::Error, 'Invalid option use_node for a remote request'
      else
        return node
      end
    end

    # We rely on our authorization system to determine whether the connected
    # node is allowed to compile the catalog's node referenced by key.
    # By default the REST authorization system makes sure only the connected node
    # can compile its catalog.
    # This allows for instance monitoring systems or puppet-load to check several
    # node's catalog with only one certificate and a modification to auth.conf
    # If no key is provided we can only compile the currently connected node.
    name = request.key || request.node
    if node = find_node(name, request.environment, request.options[:transaction_uuid])
      return node
    end

    raise ArgumentError, "Could not find node '#{name}'; cannot compile"
  end

  # Initialize our server fact hash; we add these to each client, and they
  # won't change while we're running, so it's safe to cache the values.
  def set_server_facts
    @server_facts = {}

    # Add our server version to the fact list
    @server_facts['serverversion'] = Puppet.version.to_s

    # And then add the server name and IP
    { 'servername' => 'fqdn',
      'serverip' => 'ipaddress' }.each do |var, fact|
      if value = Facter.value(fact)
        @server_facts[var] = value
      else
        Puppet.warning "Could not retrieve fact #{fact}"
      end
    end

    if @server_facts['servername'].nil?
      host = Facter.value(:hostname)
      @server_facts['servername'] = if domain = Facter.value(:domain)
                                      [host, domain].join('.')
                                    else
                                      host
                                    end
    end
  end
end
