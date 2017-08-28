require 'rest-client'

module CallingSystems
  class Primo

    @@primo_base_url = ENV['PRIMO_BASE_URL'] || "http://bobcatdev.library.nyu.edu"

    attr_accessor :local_id, :institution

    def initialize(local_id, institution)
      @local_id = local_id
      @institution = institution
    end

    def get_pnx_json
      @get_pnx_json ||= JSON.parse(get_record.body)
    end

   private

    def get_record
      @get_record ||= RestClient.get("#{@@primo_base_url}/primo_library/libweb/webservices/rest/v1/pnxs/L/#{local_id}", {params: {inst: institution}})
    end
  end
end
