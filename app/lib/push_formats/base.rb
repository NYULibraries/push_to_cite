module PushFormats
  class Base
    attr_accessor :name, :id, :action, :method, :enctype, :element_name

    def initialize(name, id, action, method, enctype, element_name)
      @name = name || "Service"
      @id = id || "service"
      @action = action || ""
      @method = method || "POST"
      @enctype = enctype || "application/x-www-form-urlencoded"
      @element_name = element_name || "data"
    end
  end
end
