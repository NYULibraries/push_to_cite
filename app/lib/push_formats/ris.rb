require_relative 'base'
module PushFormats
  class Ris < Base

    def initialize
      @filename = 'export.ris'
      @to_format = 'ris'
      @mimetype = 'application/x-research-info-systems'
      super()
    end

  end
end
