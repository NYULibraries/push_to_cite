require 'rest-client'

module CallingSystems
  class Primo
    @@link_field = "lln10"
    @@primo_base_url = "http://bobcatdev.library.nyu.edu"

    attr_accessor :local_id, :institution

    def initialize(local_id, institution)
      @local_id = local_id
      @institution = institution
    end

    def get_openurl
      get_link_field_link.first["linkURL"] unless get_link_field_link.first.nil?
      get_default_openurl
    end

   private

    def get_links
      @get_links ||= parsed_body["delivery"]["link"]
    end

    def get_link_field_link
      @get_openurl ||= get_links.select {|el| el["displayLabel"] == @@link_field}
    end

    def get_default_openurl
      @get_default_openurl ||= get_links.select {|el| el["displayLabel"] == "openurl"}.first["linkURL"]
    end

    def parsed_body
      @parsed_body ||= JSON.parse(get_record.body)
    end

    def get_record
      @get_record ||= RestClient.get("#{@@primo_base_url}/primo_library/libweb/webservices/rest/v1/pnxs/L/#{local_id}", {params: {inst: institution}})
    end
  end
end
