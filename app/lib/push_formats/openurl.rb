module PushFormats
  class Openurl < Base
    # TODO: For pulling citero_engine out of Eshelf
    def initialize
      @to_format = 'openurl'
      super()
    end
  end
end
