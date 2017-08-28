require_relative "csf_helpers"
class PnxJson
  def initialize(json)
    @json = json
    @hash = {}
  end

  def to_csf
    add_item_type
    parse_and_add_creators
    parse_and_add_publisher
    add_pages
    add_isbn
    add_issn
    add_eissn
    add_all_other_fields
    add_imported_from
    csf = Citero::CsfHelpers.hash_to_csf(@hash)
    Citero::CsfHelpers.csf_to_string(csf)
  end

  private

  def item_type_conversion_hash
    @item_type_conversion_hash ||= {
      "audio"   =>    "audioRecording",
      "video"   =>    "videoRecording",
      "article" =>    "journalArticle",
      "books"   =>    "book",
    }
  end

  def item_type_conversion_array
    @item_type_conversion_array ||= [
      "book",
      "report",
      "webpage",
      "journal",
      "map",
      "thesis"
    ]
  end

  def qualified_method_names
    @qualified_method_names ||= {
      "title" => "title",
      "publicationDate" => "publicationDate",
      "journalTitle" => "journalTitle",
      "date" => "date",
      "language" => "languageId",
      "edition" => "edition",
      "tags" => "tags",
      "callNumber" => "callNumber",
      "pnxRecordId" => "pnxRecordId",
      "description" => "description",
      "notes" => "notes"
    }
  end

  def get_item_type(raw_item_type)
    raw_item_type.downcase!
    return raw_item_type if item_type_conversion_array.include?(raw_item_type)
    return item_type_conversion_hash[raw_item_type] if item_type_conversion_hash.include?(raw_item_type)
    return 'document'
  end

  def add_item_type
    type =  @json["type"] || @json["@TYPE"] || 'document'
    @hash["itemType"] = get_item_type(type)
  end


  def parse_and_add_creators
    contributors = []

    creators = @json["creator"]
    creators = @json["contributor"] if @json["creator"].empty?
    contributors = @json["contributor"] unless @json["creator"].empty?

    creators = @json["addau"] if (@json["creator"].empty? && @json["contributor"].empty?)

    add_creators(creators, "author")
    add_creators(contributors, "contributor")
  end

  def add_creators(creators,creator_type)
    if (creators && !creators.empty?)
      creators.each do |name|
        @hash[creator_type] = [@hash[creator_type], name.strip].flatten.compact
      end
    end
  end

  def parse_and_add_publisher
    return if @json["publisher"].empty?
    @json["publisher"].each do |json_pub|
      if json_pub.include? " : "
        pub_place, publisher = json_pub.split(" : ",2).map(&:strip)
        add_publisher_and_place(publisher, pub_place)
      else
        add_publisher_and_place(json_pub)
      end
    end
  end

  def add_publisher_and_place(publisher = nil, place = nil)
    @hash['publisher'] = publisher if publisher
    @hash['place'] = place if place
  end

  def add_pages
    return unless @json["pages"]
    raw_pages = @json["pages"].gsub(/[\(\)\[\]]/, "").gsub(/\D/, " ").strip()
    @hash['numPages'] = raw_pages.split(" ").first unless raw_pages.empty?
  end

  def add_isbn
    isbn = [@json['isbn'], @json['isbn10'], @json['isbn13']].flatten.compact.uniq
    @hash['isbn']  = [@hash['isbn'], isbn].flatten.compact unless isbn.empty?
  end

  def add_eissn
    eissn = @json['eissn'] || []
    @hash['eissn']  = [@hash['eissn'], eissn].flatten.compact unless eissn.empty?
  end

  def add_issn
    issn = @json['issn'] || []
    puts issn
    @hash['issn']  = [@hash['issn'], issn].flatten.compact unless issn.empty?
  end

  def add_all_other_fields
    qualified_method_names.each do |standard_form, method_name|
      @hash[standard_form] = @json[method_name] unless [@json[method_name]].compact.empty?
    end
  end

  def add_imported_from
    @hash['importedFrom'] = "PNX_JSON"
  end
end
