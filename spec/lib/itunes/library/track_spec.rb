require "#{File.dirname(__FILE__)}/../../../../lib/itunes/library.rb"

describe Itunes::Library::Track do
  context "with an '#{Itunes::Library::Track._attributes.first}' argument" do
    it "should instantiate" do
      expect { Itunes::Library::Track.new(Itunes::Library::Track._attributes.first => 101) }.not_to raise_error
    end

    context "with all known attributes" do
      let(:params) { Itunes::Library::Track.attr_map}
      let(:attrs) { params }
      let(:track) { Itunes::Library::Track.new(attrs) }
      let(:extras) { {:foo => :bar} }
      it "should instantiate" do
        expect { Itunes::Library::Track.new(params) }.not_to raise_error
      end

      it "should respond to known attributes" do
        params.each_pair do |param, value|
          got = track.send(param)
          got.should_not be_nil
          got.should == value
        end
      end

      it "should raise NoMethodError for extra/unknown attributes" do
        extras.keys.each do |param|
          expect {track.send(param)}.to raise_error(NoMethodError)
        end
      end

      context "with additional unknown attributes" do
        let(:attrs) { params.merge(extras) }
        it "should instantiate" do
          attrs[extras.keys.first].should == extras.values.first
          expect { Itunes::Library::Track.new(attrs) }.not_to raise_error
        end

        it "should respond to known attributes" do
          params.each_pair do |param, value|
            got = track.send(param)
            got.should_not be_nil
            got.should == value
          end
        end

        it "should raise NoMethodError for extra/unknown attributes" do
          extras.keys.each do |param|
            expect {track.send(param)}.to raise_error(NoMethodError)
          end
        end
      end
      context "from an iTunes file" do
        let(:track_hash) { Itunes::Library::Generator.generate }
      end
    end
  end

  context "without an '#{Itunes::Library::Track._attributes.first}' argument" do
    it "should raise an error" do
      expect { Itunes::Library::Track.new }.to raise_error(Itunes::Library::Invalid)
    end
  end
end
