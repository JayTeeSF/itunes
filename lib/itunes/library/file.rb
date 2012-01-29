module Itunes
  extend self


  class Library::File
    DEFAULT_CONTENT_TYPE = "application/xml"
    attr_accessor :content_type, :path, :reader
    attr_writer :file_name
    def initialize(full_path, options={})
      @path = full_path
      raise Library::Invalid unless path
      @reader = options[:reader] || File
      @content_type = options[:content_type] || DEFAULT_CONTENT_TYPE
    end

    def file_name
      @file_name ||= reader.basename(path)
    end

    def read
      reader.open(path, 'r')
    end
  end

end
