require "#{File.dirname(__FILE__)}/../../../../lib/itunes/library.rb"

describe Itunes::Library::Playlist do
  context "with a '#{Itunes::Library::Playlist::ATTRIBUTES.first}' argument" do
    it "should instantiate" do
      lambda { Itunes::Library::Playlist.new(Itunes::Library::Playlist::ATTRIBUTES.first => 101) }.should_not raise_error
    end
  end
  context "without a '#{Itunes::Library::Playlist::ATTRIBUTES.first}' argument" do
    it "should raise an error" do
      lambda { Itunes::Library::Playlist.new }.should raise_error(Itunes::Library::Invalid)
    end
  end
end
