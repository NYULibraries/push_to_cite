module PushFormats
  class Base
    attr_accessor :name, :id, :action, :method, :enctype, :element_name,
                  :filename, :to_format, :mimetype

    def initialize
      @name ||= 'Service'
      @id ||= @name.downcase
      @action ||= ''
      @method ||= 'POST'
      @enctype ||= 'application/x-www-form-urlencoded'
      @element_name ||= 'data'
      @filename ||= 'export'
      @to_format ||= ''
      @mimetype ||= 'text/plain'
    end

    def to_sym
      self.class.name.split('::').last.downcase.to_sym
    end
    
    # Redirect this service to an external citation manager
    def redirect_to_external?
      false
    end

    # Post the data to an external citation manager
    def post_form_to_external?
      false
    end

    # Redirecting this service to the data in the object
    def redirect_to_data?
      false
    end

    def download?
      !redirect_to_data? && !post_form_to_external? && !redirect_to_external?
    end
  end
end
