module PushFormats
  class Openurl < Base

    def self.link_resolver_base_url
      ENV['LINK_RESOLVER_BASE_URL'] || "https://getit.library.nyu.edu/resolve?"
    end

    def initialize
      @to_format = 'openurl'
      super()
    end

    def redirect_to_data?
      true
    end

  end
end
