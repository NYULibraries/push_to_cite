require_relative 'base'
module PushFormats
  class Bibtex < Base

    def initialize
      @filename = 'export.bib'
      @to_format = 'bibtex'
      @mimetype = 'application/x-bibtex'
      @name = 'BibTeX'
      super()
    end

  end
end
