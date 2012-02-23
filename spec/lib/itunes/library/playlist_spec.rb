require "#{File.dirname(__FILE__)}/../../../../lib/itunes/library.rb"

describe Itunes::Library::Playlist do
  context "with an '#{Itunes::Library::Playlist._attributes.first}' argument" do
    it "should instantiate" do
      lambda { Itunes::Library::Playlist.new(Itunes::Library::Playlist._attributes.first => 101) }.should_not raise_error
    end

    context "with all known attributes" do
      let(:params) { Itunes::Library::Playlist.attr_map}
      let(:attrs) { params }
      let(:playlist) { Itunes::Library::Playlist.new(attrs) }
      let(:extras) { {:foo => :bar} }

      it "should instantiate" do
        expect { Itunes::Library::Playlist.new(params) }.not_to raise_error
      end

      it "should respond to known attributes" do
        params.each_pair do |param, value|
          got = playlist.send(param)
          got.should_not be_nil
          got.should == value
        end
      end

      it "should raise NoMethodError for extra/unknown attributes" do
        extras.keys.each do |param|
          expect {playlist.send(param)}.to raise_error(NoMethodError)
        end
      end

      context "with additional unknown attributes" do
        let(:attrs) { params.merge(extras) }
        it "should instantiate" do
          attrs[extras.keys.first].should == extras.values.first
          expect { Itunes::Library::Playlist.new(attrs) }.not_to raise_error
        end

        it "should respond to known attributes" do
          params.each_pair do |param, value|
            got = playlist.send(param)
            got.should_not be_nil
            got.should == value
          end
        end

        it "should raise NoMethodError for extra/unknown attributes" do
          extras.keys.each do |param|
            expect {playlist.send(param)}.to raise_error(NoMethodError)
          end
        end
      end

      #FIXME: extract iTunes specifics from the notion of a (general) Playlist model
      context "from an iTunes file" do
        let(:itunes_data) { Itunes::Library::Generator.generate }
        let(:xml_parser) do
          require 'nokogiri'
          mock().tap do |m|
            m.should_receive(:xml).and_return(Nokogiri::XML(itunes_data))
          end
        end
        it "should return the generated playlist" do
          parsed_playlists = Itunes::Library::Playlist.parse(xml_parser)
          parsed_playlists.size.should == 1
          parsed_playlists.first.id.should == "1"
          parsed_playlists.first.name.should == "playlist_1"
        end
      end
    end
  end

  context "without an '#{Itunes::Library::Playlist._attributes.first}' argument" do
    it "should raise an error" do
      lambda { Itunes::Library::Playlist.new }.should raise_error(Itunes::Library::Invalid)
    end
  end
end
