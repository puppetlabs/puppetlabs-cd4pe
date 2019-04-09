require 'puppet/network/http_pool'
require 'json'

#=================
# This is a copy paste of
# https://github.com/puppetlabs/classifier/blob/2019.0.x/puppet/lib/puppet/indirector/node/classifier.rb
# with modifications to override trusted_facts to use the ones from PDB instead
# of looking up the one coming from the requesting node since we won't have
# that information for CD4PE
# ===============
class Puppet::Node::HieraNodeAdapter < Puppet::Pops::Adaptable::Adapter
  attr_accessor :hiera_data
end

#=================
# This is a copy paste of
# https://github.com/puppetlabs/classifier/blob/2019.0.x/puppet/lib/puppet/indirector/node/classifier.rb
# with modifications to override trusted_facts to use the ones from PDB instead
# of looking up the one coming from the requesting node since we won't have
# that information for CD4PE
# ===============
class Puppet::Node::Cdpe < Puppet::Indirector::Code
  AgentSpecifiedEnvironment = 'agent-specified'.freeze
  ClassificationConflict = 'classification-conflict'.freeze
  KEY_HIERA_DATA = 'config_data'.freeze

  def self.load_config
    config_path = File.join(Puppet[:confdir], 'classifier.yaml')

    config = nil
    if File.exist?(config_path)
      config = YAML.load_file(config_path)
    else
      Puppet.warning("Classifier config file '#{config_path}' does not exist, using defaults")
      config = {}
    end

    if config.respond_to?(:to_ary)
      config.map do |service|
        merge_defaults(service)
      end
    else
      service = merge_defaults(config)
      [service]
    end
  end

  def adapt_node_with_hiera_data(node, hiera_data)
    hiera_data ||= {}
    flattened_hiera_data = {}
    hiera_data.each do |scope, kv|
      kv.each do |k, v|
        flattened_hiera_data["#{scope}::#{k}"] = v
      end
    end

    Puppet::Node::HieraNodeAdapter.adapt(node).hiera_data = flattened_hiera_data
    node
  end

  def find(request)
    name = request.key
    facts = if request.options[:facts].is_a?(Puppet::Node::Facts)
              request.options[:facts]
            else
              Puppet::Node::Facts.indirection.find(name, environment: request.environment)
            end

    fact_values = if facts.nil?
                    {}
                  else
                    facts.sanitize
                    facts.to_data_hash['values']
                  end

    ## REMOVED TO USE PDB FACTS
    # trusted_data = Puppet.lookup(:trusted_information) do
    # This block contains a default implementation for trusted
    # information. It should only get invoked if the node is local
    # (e.g. running puppet apply)
    #   temp_node = Puppet::Node.new(name)
    #   temp_node.parameters['clientcert'] = Puppet[:certname]
    #   Puppet::Context::TrustedInformation.local(temp_node)
    # end

    trusted_data_values = if fact_values['trusted'].nil?
                            {}
                          else
                            fact_values['trusted']
                          end

    facts_for_request = { 'fact' => fact_values,
                          'trusted' => trusted_data_values }

    if request.options.include?(:transaction_uuid)
      facts_for_request['transaction_uuid'] = request.options[:transaction_uuid]
    end

    requested_environment = request.options[:configured_environment] || request.environment

    services.each do |service|
      result = retrieve_classification(name, facts_for_request, requested_environment, service)
      if result.is_a? Puppet::Node
        # Puppet 5.0 and later supports sending facts along with #fact_merge, to
        # avoid extra indirection calls
        if result.method(:fact_merge).arity.zero?
          result.fact_merge
        else
          result.fact_merge(facts)
        end
        return result
      elsif result.respond_to?(:[]) && result['kind'] == ClassificationConflict
        # got a classification conflict
        msg = result['msg']
        Puppet.err(msg)
        raise Puppet::Error, msg
      end
    end

    # got neither a valid classification nor a classification conflict, so all the services are
    # unreachable or having unforeseen problems
    msg = "Classification of #{name} failed due to a Node Manager service error.
    Please check /var/log/puppetlabs/console-services/console-services.log on the node(s) running the Node Manager service for more details."
    Puppet.err(msg)
    raise Puppet::Error, msg
  end

  private

  def new_connection(service)
    Puppet::Network::HttpPool.http_instance(service[:server], service[:port])
  end

  # Attempt to retrieve classification from the NC service. Returns a
  # Puppet::Node object with the retrieved classification if successfully
  # retrieved, the parsed conflict error response in the case of a
  # classification conflict, otherwise nil if the case of a connection error,
  # timeout, or non-conflict 5xx response.
  def retrieve_classification(node_name, node_facts, requested_environment, service)
    begin
      connection = new_connection(service)
      request_path = "#{normalize_prefix(service[:prefix])}/v1/classified/nodes/#{node_name}"

      response = connection.post(request_path,
                                 node_facts.to_json,
                                 { 'Content-Type' => 'application/json' },
                                 metric_id: [:classifier, :nodes])
    rescue SocketError => e
      Puppet.warning("Could not connect to the Node Manager service at #{service_url(service)}: #{e.inspect}")
      return nil
    end

    result = JSON.parse(response.body)

    unless response.is_a? Net::HTTPSuccess
      if result['kind'] == ClassificationConflict
        explanation = result['msg'].sub(' See the `details` key for all conflicts.', '')
        msg = "Classification of #{node_name} failed due to a classification conflict: #{explanation}"
        return result.merge('msg' => msg)
      else
        Puppet.warning("Received an unexpected error response from the Node Manager service at #{service_url(service)}: #{response.code} #{response.msg}")
        return nil
      end
    end

    result['classes'] = Hash[result['classes'].sort]
    is_agent_specified = (result['environment'] == AgentSpecifiedEnvironment)
    result.delete('environment') if is_agent_specified
    hiera_data = result.delete(KEY_HIERA_DATA)

    node = Puppet::Node.from_data_hash(result)
    adapt_node_with_hiera_data(node, hiera_data)
    node.environment = requested_environment if is_agent_specified

    node
  end

  def config
    @config ||= Puppet::Node::Cdpe.load_config
  end

  def services
    config
  end

  def service_url(service)
    "https://#{service[:server]}:#{service[:port]}#{service[:prefix]}"
  end

  def normalize_prefix(prefix)
    prefix.chomp('/')
  end

  # rubocop:disable Lint/IneffectiveAccessModifier
  def self.merge_defaults(service)
    {
      server: service['server'] || 'classifier',
      port: service['port'] || 1262,
      prefix: service['prefix'] || '',
    }
  end
end
