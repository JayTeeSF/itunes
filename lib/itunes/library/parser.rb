module Itunes
  class Library::Parser

    DEFAULT_MODE = :tracks_only
    FORMAT = "csv"
    EXPECTED_CONTENT_TYPES = ["application/xml", "text/xml"]
    NEW_CONTENT_TYPE = "application/#{FORMAT}"

    attr_accessor :mode
    attr_reader :input_document
    attr_reader :output_path
    attr_writer :library

    def initialize in_doc, options = {}
      @input_document = in_doc
      @output_path = (!!options[:out_doc]) ? options[:out_doc] : in_doc.path(FORMAT.to_sym)
      @mode = options[:mode]
    end

    def self.parse_local(input_filename, options={})
      output_filename = (options[:out_doc] || Rails.root + 'tmp/parsed.csv').to_s
      options[:out_doc] ||= output_filename
      pseudo_doc = Itunes::PseudoDoc.new(input_filename)

      parser = Itunes::Library::Parser.new( pseudo_doc, options )
      parser.library = Itunes::Library.parse( parser )

      File.open(output_filename, 'w') do |f|
        f.puts parser.to_csv
      end
      puts "open #{output_filename}"
    end

    def self.parse doc_obj, options = {}
      return unless EXPECTED_CONTENT_TYPES.include?(options[:content_type] || doc_obj.content_type)
      new(doc_obj, options).parse
    end

    def xml
      Nokogiri::XML(File.open(input_document.path, 'r'))
    end

    # move to CSV module - interface-method
    def to_csv
      library.to_csv
    end

    # move to CSV module - interface-method
    def csv_header
      library.csv_header
    end

    # move to CSV module - interface-method
    def csv_rows
      library.csv_rows
    end

    def library
      @library ||= Library.parse(self)
    end

    def output_dir
      File.dirname(output_path)
    end

    def parse
      # FileUtils.mkdir_p output_dir unless Dir.exists?(output_dir)
      Paperclip::Tempfile.new(File.basename(output_path)).tap do |f|
        f.puts to_csv
      end
    end

  end # Parser
end
