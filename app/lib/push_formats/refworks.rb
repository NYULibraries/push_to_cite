module PushFormats
  class Refworks < Base

    def initialize
      @action = 'http://www.refworks.com/express/ExpressImport.asp?vendor=Primo&filter=RefWorks%20Tagged%20Format&encoding=65001&url='
      @element_name = 'ImportData'
      @push_to_external = true
      @redirect = true
      @to_format = 'refworks_tagged'
      super()
    end

  end
end
