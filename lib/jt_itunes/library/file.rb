# require 'stringio'
# input_filename = "/pretend_dir/foo.txt"
# input_file = StringIO.new "contents of '/pretend_dir/foo.txt'"
# lf = Library::File.new(input_filename, :file => input_file)
module JtItunes
  extend self
  class Library::File
    DEFAULT_CONTENT_TYPE = "application/xml"
    attr_accessor :content_type, :path, :file
    attr_writer :file_name
    def initialize(full_path, options={})
      @path = full_path
      raise Library::Invalid unless path
      @file = options.delete(:file)
      @content_type = options[:content_type] || DEFAULT_CONTENT_TYPE
    end

    def file_name
      @file_name ||= File.basename(path)
    end

    def file
      @file ||= File.new(path, 'r')
    end

    def read
      @contents ||= file.read
    end
  end
end
