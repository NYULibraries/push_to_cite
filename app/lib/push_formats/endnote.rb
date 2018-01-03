module PushFormats
  class Endnote < Base

    def initialize
      @action = "http://www.myendnoteweb.com/?func=directExport&partnerName=Primo&dataIdentifier=1&dataRequestUrl="
      @name = "EndNote"
      @id = "endnote"
      super(name, id, action, nil, nil, nil)
    end
  end
end
