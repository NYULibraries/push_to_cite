require_relative 'base'
module PushFormats
  class Refworks < Base

    def initialize
      @action = 'https://www.refworks.com/express/ExpressImport.asp?vendor=Primo&filter=RefWorks%20Tagged%20Format&encoding=65001&url='
      @element_name = 'ImportData'
      @to_format = 'refworks_tagged'
      @name = 'RefWorks'
      super()
    end

    # Refworks has to post to the action
    def post_form_to_external?
      true
    end

  end
end
