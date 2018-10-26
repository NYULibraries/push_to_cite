require_relative 'base'
module PushFormats
  class Openurl < Base

    def initialize
      @to_format = 'openurl'
      @name = 'OpenURL'
      super()
    end

  end
end
