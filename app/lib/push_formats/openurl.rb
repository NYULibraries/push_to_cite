module PushFormats
  class Openurl < Base

    def self.link_resolver_base_url
      ENV['LINK_RESOLVER_BASE_URL'] || "https://getit.library.nyu.edu/resolve?"
    end

    def initialize
      @to_format = 'openurl'
      super()
    end

    # OpenURL should redirect to the OpenURL generated from the CSF
    def redirect_to_data?
      true
    end

  end
end
