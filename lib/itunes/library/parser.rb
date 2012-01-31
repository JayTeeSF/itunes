# input_filename = Rails.root + 'features/iTunes Sample.xml'
# Itunes::Library::Parser.parse_local(input_filename)
module Itunes
  class Library::Parser

    DEFAULT_MODE = :tracks_only
    OUTPUT_FORMAT = "csv"
    EXPECTED_CONTENT_TYPES = ["application/xml", "text/xml"]
    NEW_CONTENT_TYPE = "application/#{OUTPUT_FORMAT}"

    attr_accessor :mode
    attr_reader :input_document
    attr_reader :output_path, :file_class #, :file_util_class
    attr_writer :library

    def initialize in_doc, options = {}
      @input_document = in_doc
      @output_path = (!!options[:out_doc]) ? options[:out_doc] : in_doc.path(OUTPUT_FORMAT.to_sym)
      @mode = options[:mode]
      @file_class = options[:file_class] || File
      #@file_util_class = options[:file_util_class] || FileUtils
      @skip_paperclip = options.has_key?(:skip_paperclip) ? options[:skip_paperclip] : !self.class.defined_constants?('Paperclip::Tempfile')
    end

    def self.parse_local(input_filename, options={})
      output_filename = (options[:out_doc] || tmp_dir(options) + '/parsed.csv').to_s
      options[:out_doc] ||= output_filename
      file_wrapper_class = options.delete(:file_wrapper_class) || Library::File
      library_file_obj = file_wrapper_class.new(input_filename)
      options[:skip_paperclip] = true unless options.has_key?(:skip_paperclip)

      parse library_file_obj, options
      puts "open #{output_filename}"
    end

    def self.parse library_file_obj, options = {}
      return unless EXPECTED_CONTENT_TYPES.include?(options[:content_type] || library_file_obj.content_type)
      new(library_file_obj, options).parse
    end

    def temp_file
      if skip_paperclip?
        file_class.open(output_path, 'w')
      else
        Paperclip::Tempfile.new(file_class.basename(output_path))
      end
    end

    def parse
      temp_file.tap do |f|
        f.puts to_csv
      end
    end

    def library
      @library ||= Library.parse(self)
    end

    def output_dir
      file_class.dirname(output_path)
    end

    def xml(parsing_cmd=default_parsing_cmd)
      parsing_cmd.call(input_document.read)
    end

    def default_parsing_cmd
      @default_parsing_cmd ||=
        begin
          require 'nokogiri'
          lambda {|arg| Nokogiri::XML(arg) }
        end
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

    def skip_paperclip?
      @skip_paperclip
    end

    def self.tmp_dir(options={})
      (options[:tmp_dir] || root_dir(options) + '/tmp').tap do |tmp_dir|
        verify_or_mkdir(tmp_dir)
      end
    end

    def self.verify_or_mkdir(dir)
      File.exists?(dir) || FileUtils.mkdir_p(dir)
    end

    def self.root_dir(options={})
      options[:root_dir] || defined_constants?('Rails') ? Rails.root.to_s : '.'
    end


    # Itunes::Library::Parser.defined_constants?('Object')
    # => true
    # Itunes::Library::Parser.defined_constants?('Object::Itunes')
    # => true
    # Itunes::Library::Parser.defined_constants?('Foo::Bar')
    # => false
    # Itunes::Library::Parser.defined_constants?('Object::Foo::Bar::Baz')
    # [ previously: BOOM! ]
    # => false
    def self.defined_constants?(constant_string)
      constant_string = constant_string.dup
      separator = '::'
      current_constant = nil
      bogus_starting_pattern = "Object#{separator}"
      while constant_string.start_with?(bogus_starting_pattern)
        constant_string.sub!(bogus_starting_pattern, '')
      end

      constant_string.split(separator).all? do |constant_segment|
        if current_constant
          current_constant << "#{separator}#{constant_segment}"
        else
          current_constant = constant_segment
        end
        Object.const_defined?(current_constant)
      end
    end
  end # Parser
end
