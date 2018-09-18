module PushFormats
  class Refworks < Base

    def initialize
      @to_format = 'refworks_tagged'
      @element = 'ImportData'
      super()
    end

  end
end
