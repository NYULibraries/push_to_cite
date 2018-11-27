require 'rest-client'

module CallingSystems
  class Primo

    @@primo_base_url = ENV['PRIMO_BASE_URL'] || "http://bobcatdev.library.nyu.edu"
    @@proxy_url = ENV['PROXY_URL']

    attr_accessor :primo_id, :institution

    def initialize(primo_id, institution)
      RestClient.proxy = @@proxy_url
      @primo_id = primo_id
      @institution = institution
    end

    def get_pnx_json
      @get_pnx_json ||= JSON.parse(get_record.body)
    end

    def openurl
      @openurl ||= get_pnx_json.dig("delivery", "link")&.find {|h| h["displayLabel"] == "lln10" }.dig("linkURL")
    end

    # Reject Arrays & match against primo errors
    def error?
      primo_id.is_a?(Array) || get_pnx_json.to_s.match?(/^{"beacon.+"=>"\d+"}$/)
    end

    def pnx_json_api_endpoint
      @pnx_json_api_endpoint ||= "#{@@primo_base_url}/primo_library/libweb/webservices/rest/v1/pnxs/L/#{primo_id}"
    end

   private

    def get_record
      @get_record ||= RestClient.get(pnx_json_api_endpoint, {params: {inst: institution}})
    end
  end
end
