module PushFormats
  class Base
    attr_accessor :name, :id, :action, :method, :enctype, :element_name,
                  :push_to_external, :redirect, :filename, :to_format, :mimetype

    def initialize
      @name ||= 'Service'
      @id ||= @name.downcase
      @action ||= ''
      @method ||= 'POST'
      @enctype ||= 'application/x-www-form-urlencoded'
      @element_name ||= 'data'
      @push_to_external ||= false
      @redirect ||= false
      @filename ||= 'export'
      @to_format ||= ''
      @mimetype ||= 'text/plain'
    end
  end
end
