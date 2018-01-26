module PushFormats
  class Base
    attr_accessor :name, :id, :action, :method, :enctype, :element_name, :push_to_external, :redirect, :filename, :to_format, :mimetype

    def initialize(name = "Service", id = "service", action = "", method = "POST", enctype = "application/x-www-form-urlencoded", element_name = "data", push_to_external = false, redirect = false, filename = 'export', to_format = '', mimetype = 'text/plain')
      @name ||= name
      @id ||= id
      @action ||= action
      @method ||= method
      @enctype ||= enctype
      @element_name ||= element_name
      @push_to_external ||= push_to_external
      @redirect ||= redirect
      @filename ||= filename
      @to_format ||= to_format
      @mimetype ||= mimetype
    end
  end
end
