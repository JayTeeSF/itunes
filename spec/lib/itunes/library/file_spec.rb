require "#{File.dirname(__FILE__)}/../../../../lib/itunes/library.rb"
require 'stringio'

describe Itunes::Library::File do
  let(:file_path) { "/tmp/foo" }
  context "without arguments" do
    it "should raise an exception" do
      lambda { Itunes::Library::File.new }.should raise_error(ArgumentError)
    end
  end

  context "with an invalid argument" do
    it "should raise an exception" do
      lambda { Itunes::Library::File.new(nil) }.should raise_error(Itunes::Library::Invalid)
    end
  end

  context "with a valid argument" do
    context "without a mock file" do
      let(:lib_file) { Itunes::Library::File.new(file_path) }
      it "should return its name" do
        File.should_receive(:basename).with(file_path)
        lib_file.file_name
      end

      it "should return the default content_type" do
        lib_file.content_type.should == Itunes::Library::File::DEFAULT_CONTENT_TYPE
      end

      it "should return its path" do
        lib_file.path.should == file_path
      end

      it "should return its contents" do
        file_double = double('file')
        file_double.should_receive(:read).and_return("content")
        File.should_receive(:new).with(file_path, 'r').and_return(file_double)
        lib_file.read.should == "content"
      end
    end

    context "with mock file" do
      let(:str_file) { StringIO.new("file contents begin\r\nfile contents end") }
      let(:lib_file) { Itunes::Library::File.new(file_path, :file => str_file) }
      it "should return its name" do
        lib_file.file_name.should == File.basename(file_path)
      end
      it "should return its contents" do
        expected = str_file.read
        str_file.rewind
        lib_file.read.should == expected
      end
      it "should return the default content type" do
        lib_file.content_type.should == Itunes::Library::File::DEFAULT_CONTENT_TYPE
      end
      it "should return its path" do
        lib_file.path.should == file_path
      end
    end
  end
end
