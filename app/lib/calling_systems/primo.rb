require 'rest-client'

module CallingSystems
  class Primo

    @@primo_base_url = ENV['PRIMO_BASE_URL'] || "http://bobcatdev.library.nyu.edu"
    @@proxy_url = ENV['PROXY_URL']

    WHITELISTED_ATTRS = [:addau, :institution, :subject, :oclcnum].freeze

    attr_accessor :primo_id, :institution

    def initialize(primo_id, institution)
      RestClient.proxy = @@proxy_url
      @primo_id = primo_id
      @institution = institution
    end

    def get_pnx_json
      @get_pnx_json ||= JSON.parse(get_record.body)
    end
    
    def links
      @links ||= whitelisted_links.to_h
    end

    def whitelisted_attributes(attrs = {})
      WHITELISTED_ATTRS.each do |attr|
        attrs[attr] = get_pnx_json.dig(attr.to_s)
      end
      attrs.reject {|k, v| v.nil? }
    end

    def openurl
      @openurl ||= links["lln10"]
    end

    def locations
      # This is messy, looking for locations with trailing spaces "Check Availability: NYU Bobst  Main Collection  (DS119.7 .S381877 2013 )    "
      @locations ||= get_pnx_json.dig("delivery", "link")&.filter {|h| h.dig("displayLabel")&.match(/^Check Availability:(.+)?\s+$/) }&.map {|l| l.dig("displayLabel")&.gsub(/^Check Availability:/,'')&.strip }
    end

    # Reject Arrays & match against primo errors
    def error?
      primo_id.is_a?(Array) || get_pnx_json.to_s.match?(/^{"beacon.+"=>"\d+"}$/)
    end

    def pnx_json_api_endpoint
      @pnx_json_api_endpoint ||= "#{@@primo_base_url}/primo_library/libweb/webservices/rest/v1/pnxs/L/#{primo_id}"
    end

   private

    def whitelisted_links
     @whitelisted_links ||= get_pnx_json.dig("delivery", "link")&.filter {|h| h.dig("displayLabel")&.match(/^(lln(\d)+|linktoholdings)/) }&.map {|l| [l.dig("displayLabel"), l.dig("linkURL")] }
    end

    def get_record
      @get_record ||= RestClient.get(pnx_json_api_endpoint, {params: {inst: institution}})
    end
  end
end
