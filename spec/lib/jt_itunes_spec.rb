require "#{File.dirname(__FILE__)}/../../lib/jt_itunes.rb"

describe JtItunes do
  context "mixed-into some class" do
    let(:some_klass) {
      it = Class.new
      it.tap { |some_klass| some_klass.send(:include, JtItunes) }
    }

    it "should instantiate" do
      lambda { some_klass.new }.should_not raise_error
    end

  end
end
