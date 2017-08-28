require 'rest-client'

module CallingSystems
  class Primo
    class InvalidRecordError < StandardError; end

    @@link_field = "lln10"
    @@primo_base_url = ENV['PRIMO_BASE_URL'] || "http://bobcatdev.library.nyu.edu"

    attr_accessor :local_id, :institution

    def initialize(local_id, institution)
      @local_id = local_id
      @institution = institution
    end

    def get_openurl
      unless get_link_field_link.empty?
        get_link_field_link.first["linkURL"]
      else
        get_default_openurl
      end
    end

   private

    def get_links
      @get_links ||= parsed_body["delivery"]["link"]
    rescue Exception => e
      raise Primo::InvalidRecordError, parsed_body
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
