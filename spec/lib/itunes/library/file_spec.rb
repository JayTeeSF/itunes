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
    context "without a mock_path_reader" do
      subject { Itunes::Library::File.new(file_path) }
      it "should return its name" do
        File.should_receive(:basename).with(file_path)
        subject.file_name
      end

      it "should return the default content_type" do
        subject.content_type.should == Itunes::Library::File::DEFAULT_CONTENT_TYPE
      end

      it "should return its path" do
        subject.path.should == file_path
      end

      it "should return its contents" do
        File.should_receive(:open).with(file_path, 'r')
        subject.read
      end
    end

    context "with mock_path_reader" do
      # or use StringIO ...
      let(:file_content) { {file_path => StringIO.new("file contents begin\r\nfile contents end")} }
      let(:mock_path_reader) {
        double("path reader", :open => file_content[file_path], :basename => file_path)
      }
      subject { Itunes::Library::File.new(file_path, :reader => mock_path_reader) }
      its(:file_name) { should == file_path }
      its(:read) { should == file_content[file_path] }
      its(:content_type) { should == Itunes::Library::File::DEFAULT_CONTENT_TYPE }
      its(:path) { should == file_path }
    end
  end
end
