module PushFormats
  class Endnote < Base

    def initialize
      @action = "http://www.myendnoteweb.com/?func=directExport&partnerName=Primo&dataIdentifier=1&dataRequestUrl="
      @name = "EndNote"
      @id = "endnote"
      @push_to_external = true
      @redirect = true
      @to_format = 'ris'
      super()
    end

  end
end
