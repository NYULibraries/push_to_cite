class ExportCitations
  class InvalidUriError < StandardError; end

  @@export_citations_url = ENV['EXPORT_CITATIONS_URL'] || "http://web1.bobst.nyu.edu/export_citations/export_citations"
  attr_accessor :data, :cite_to

  def self.export_citations_url
    @@export_citations_url
  end

  def initialize(data, cite_to)
    @data = data
    @cite_to = cite_to
  end

  def redirect_link
    @redirect_link ||= "#{@@export_citations_url}?to_format=#{cite_to}&#{clean_query_string}"
  end

 private

  def query_hash
    @query_hash ||= URI.parse(data).query
  rescue StandardError => e
    raise InvalidUriError, e
  end

  def clean_query_hash
    @clean_query_hash ||= CGI.parse(query_hash).delete_if {|key,value| value.join.to_s.empty? }
  rescue StandardError => e
    raise InvalidUriError, e
  end

  def clean_query_string
    @clean_query_string ||= URI.encode_www_form(clean_query_hash)
  end

end
