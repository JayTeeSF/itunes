require "#{File.dirname(__FILE__)}/../../../../lib/itunes/library.rb"

describe Itunes::Library::Track do
  context "with a '#{Itunes::Library::Track::ATTRIBUTES.first}' argument" do
    it "should instantiate" do
      lambda { Itunes::Library::Track.new(Itunes::Library::Track::ATTRIBUTES.first => 101) }.should_not raise_error
    end
  end
  context "without a '#{Itunes::Library::Track::ATTRIBUTES.first}' argument" do
    it "should raise an error" do
      lambda { Itunes::Library::Track.new }.should raise_error(Itunes::Library::Invalid)
    end
  end
end
