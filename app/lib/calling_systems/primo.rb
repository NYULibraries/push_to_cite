require 'rest-client'

module CallingSystems
  class Primo

    @@primo_base_url = ENV['PRIMO_BASE_URL'] || "http://bobcatdev.library.nyu.edu"
    @@proxy_url = ENV['PROXY_URL']

    attr_accessor :local_id, :institution

    def initialize(local_id, institution)
      RestClient.proxy = @@proxy_url
      @local_id = local_id
      @institution = institution
    end

    def get_pnx_json
      @get_pnx_json ||= JSON.parse(get_record.body)
    end

    def openurl
      @openurl ||= get_pnx_json.dig("delivery", "link")&.find {|h| h["displayLabel"] == "lln10" }.dig("linkURL")
    end

    def error?
      get_pnx_json.to_s.match?(/^{"beacon.+"=>"\d+"}$/)
    end

   private

    def get_record
      @get_record ||= RestClient.get("#{@@primo_base_url}/primo_library/libweb/webservices/rest/v1/pnxs/L/#{local_id}", {params: {inst: institution}})
    end
  end
end
