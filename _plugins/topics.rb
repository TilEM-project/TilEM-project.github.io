require 'net/http'
require 'json'
require 'prmd'
require 'prmd/core/renderer'

module Topics
  class Generator < Jekyll::Generator
    def generate(site)
      site.data["topics"] ||= Hash.new()
      cache = Jekyll::Cache.new("Topics")
      renderer = Prmd::Renderer.new(template: Prmd::Template.load("schema.erb", Prmd::Template.template_dirname))
      site.config["topics"].each do |topics|
        site.data["topics"][topics['repo']] ||= Hash.new()
        response = Net::HTTP.get_response(URI("https://api.github.com/repos/#{topics['owner']}/#{topics['repo']}/contents?ref=json"))
        raise "Failed to get version for #{topics['owner']}/#{topics['repo']}!" unless response.is_a?(Net::HTTPSuccess)
        versions = JSON.parse(response.body)
        shortest = versions.reduce(versions[0]['name']) { |shortest, version| shortest.length > version['name'].length ? version['name'] : shortest }
        name = shortest.chomp(".json")
        versions.each do |version|
          version_number = version["name"].chomp(".json").delete_prefix(name).delete_prefix("_")
          if version_number == ""
            version_number = "latest"
          end
          site.data["topics"][topics['repo']][version_number] = cache.getset("#{topics['owner']}/#{topics['repo']}:#{version_number}") do
            response = Net::HTTP.get_response(URI(version['download_url']))
            raise "Failed to get messages for #{topics['owner']}/#{topics['repo']} version #{version_number}!" unless response.is_a?(Net::HTTPSuccess)
            message_definitions = JSON.parse(response.body)
            message_definitions.to_h do |topic, data|
              schema = Prmd::Schema.new(data['schema'])
              schema['properties'].keys.map do |key|
                schema['properties'][key]['title'] ||= ""
              end
              [topic, renderer.render(schema, template: Prmd::Template.template_dirname)]
            end
          end
        end
      end
    end
  end
end
