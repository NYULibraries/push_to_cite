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
      @get_openurl ||= parsed_body["delivery"]["link"].select {|el| el["displayLabel"] == @@link_field}.first["linkURL"]
    end

   private

    def parsed_body
      @parsed_body ||= JSON.parse(get_record.body)
    end

    def get_record
      @get_record ||= RestClient.get("#{@@primo_base_url}/primo_library/libweb/webservices/rest/v1/pnxs/L/#{local_id}", {params: {inst: institution}})
    end
  end
end
