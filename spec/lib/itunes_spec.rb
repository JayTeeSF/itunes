require "#{File.dirname(__FILE__)}/../../lib/itunes.rb"

describe Itunes do
  context "mixed-into some class" do
    let(:some_klass) {
      it = Class.new
      it.tap { |some_klass| some_klass.send(:include, Itunes) }
    }

    it "should instantiate" do
      lambda { some_klass.new }.should_not raise_error
    end

  end
end
