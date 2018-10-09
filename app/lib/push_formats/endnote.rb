module PushFormats
  class Endnote < Base

    def initialize
      @action = "http://www.myendnoteweb.com/?func=directExport&partnerName=Primo&dataIdentifier=1&dataRequestUrl="
      @name = "EndNote"
      @id = "endnote"
      @to_format = 'ris'
      super()
    end

    def redirect_to_external?
      true
    end

  end
end
