module PushFormats
  class Bibtex < Base

    def initialize
      @filename = 'export.bib'
      @to_format = 'bibtex'
      @mimetype = 'application/x-bibtex'
      super()
    end

  end
end
