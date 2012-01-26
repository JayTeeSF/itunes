module Itunes
  extend self

  class PseudoDoc
    attr_accessor :content_type, :file_name, :path
    def initialize(full_path)
      @path = full_path
      @file_name = File.basename(@path)
      @content_type = "application/xml"
    end
  end

end
