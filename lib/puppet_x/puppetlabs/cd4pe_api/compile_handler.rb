require 'puppet_x/puppetlabs/cd4pe_api'
require 'puppet/indirector/catalog/cdpe_compiler'
require 'puppet/node'
require 'puppet/resource/catalog'
require 'pp'

# Provides a rest api handler for custom cdpe compiler
class PuppetX::Puppetlabs::CD4PEApi::CompileHandler
  def call(request, response)
    # Get all the current indirector configs to restore at the end
    terminus = Puppet[:catalog_terminus]
    t_class =  Puppet::Resource::Catalog.indirection.terminus_class
    node_cache = Puppet::Resource::Catalog.indirection.cache_class
    content = Puppet::FileServing::Content.indirection.terminus_class
    metadata = Puppet::FileServing::Metadata.indirection.terminus_class
    file = Puppet::FileBucket::File.indirection.terminus_class
    fact_term = Puppet::Node::Facts.indirection.terminus_class
    reports = Puppet[:report]
    node_terminus = Puppet::Node.indirection.terminus_class

    # Ensure that the baseline and preview catalogs are not stored via the
    # catalog indirection (may go to puppet-db)
    # # TODO: Is there a better way to disable the cache ?
    Puppet::Node::Facts.indirection.cache_class = false

    setup_terminuses
    setup_node_cache

    ret = {
      catalog: nil,
      logs: [],
    }

    begin
      Puppet[:catalog_terminus] = :cdpe_compiler
      Puppet[:report] = false
      Puppet::Node.indirection.terminus_class = :cdpe
      Puppet::Resource::Catalog.indirection.terminus_class = :cdpe_compiler
      node = request[:params][:rest]
      environment = request[:params][:environment]
      options = {
        preview_environment: environment,
        back_channel: { logs: [] },
      }

      catalog = Puppet::Resource::Catalog.indirection.find(node, options)
      unless catalog.nil?
        ret[:catalog] = catalog.to_data_hash
      end
    rescue
      ret[:catalog] = nil
    ensure
      Puppet[:catalog_terminus] = terminus
      Puppet::Node.indirection.terminus_class = node_terminus
      Puppet::Resource::Catalog.indirection.cache_class = node_cache
      Puppet::FileServing::Content.indirection.terminus_class = content
      Puppet::FileServing::Metadata.indirection.terminus_class = metadata
      Puppet::FileBucket::File.indirection.terminus_class = file
      Puppet::Resource::Catalog.indirection.terminus_class = t_class
      Puppet::Node::Facts.indirection.terminus_class = fact_term
      Puppet[:report] = reports
    end

    options[:back_channel][:logs].each do |log|
      begin
        ret[:logs] << log.to_data_hash
      rescue
        ret[:logs] << log
      end
    end

    response.respond_with(200, 'application/json', ret.to_json)
  end

  def setup_terminuses
    require 'puppet/file_serving/content'
    require 'puppet/file_serving/metadata'

    Puppet::FileServing::Content.indirection.terminus_class = :file_server
    Puppet::FileServing::Metadata.indirection.terminus_class = :file_server
    Puppet::Resource::Catalog.indirection.cache_class = false

    Puppet::FileBucket::File.indirection.terminus_class = :file
    Puppet::Node::Facts.indirection.terminus_class = :puppetdb
  end

  # Sets up a special node cache "write only yaml" that collects and stores node data in yaml
  # but never finds or reads anything (this since a real cache causes stale data to be served
  # in circumstances when the cache can not be cleared).
  # @see puppet issue 16753
  # @see Puppet::Node::WriteOnlyYaml
  # @return [void]
  def setup_node_cache
    Puppet::Node.indirection.cache_class = Puppet[:node_cache_terminus]
  end
end
