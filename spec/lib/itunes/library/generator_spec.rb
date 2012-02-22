require "#{File.dirname(__FILE__)}/../../../../lib/itunes/library.rb"
require 'stringio'

describe Itunes::Library::Generator do
  context "without arguments" do
    let(:single_track_in_single_playlist_file) {
      "#{File.dirname(__FILE__)}/../../../fixtures/single_track_in_single_playlist.xml"
    }
    let(:single_track_in_single_playlist) {
      File.read( single_track_in_single_playlist_file )
    }
    it "should return a single track in a single playlist" do
      Itunes::Library::Generator.generate.should == single_track_in_single_playlist
    end
    it "should be idempotent" do
      lparser = Itunes::Library::Parser.local_parser(single_track_in_single_playlist_file)
      Itunes::Library::Generator.generate.should == lparser.library.generate
    end
  end

  context "with a few :num_tracks and a few :num_playlists" do
    subject {Itunes::Library::Generator.generate(:num_tracks => 3, :num_playlists => 3)}
    it { should include("playlist_1") }
    it { should include("playlist_2") }
    it { should include("playlist_3") }
    it { should_not include("playlist_4") }
    it { should include("track_1") }
    it { should include("track_2") }
    it { should include("track_3") }
    it { should_not include("track_4") }
  end

  context "with a few :num_tracks and no playlists" do
    subject {Itunes::Library::Generator.generate(:num_tracks => 3, :num_playlists => 0)}
    it { should_not include("playlist_1") }
    it { should include("track_1") }
    it { should include("track_2") }
    it { should include("track_3") }
    it { should_not include("track_4") }
  end

  context "with a few :num_tracks and the default playlist" do
    subject {Itunes::Library::Generator.generate(:num_tracks => 3)}
    it { should include("playlist_1") }
    it { should_not include("playlist_2") }
    it { should include("track_1") }
    it { should include("track_2") }
    it { should include("track_3") }
    it { should_not include("track_4") }
  end
end
