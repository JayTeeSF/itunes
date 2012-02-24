require "#{File.dirname(__FILE__)}/../../lib/class_helpers.rb"

describe ClassHelpers do
  context "mixed-into some class" do
    let(:some_module) {
      it = Module.new
      it.tap do |_some_module|
        _some_module.module_eval do
          def foo
            'module-bar'
          end
        end
      end
    }
    let(:some_klass) {
      it = Class.new
      it.tap { |_some_klass| _some_klass.send(:include, ClassHelpers) }
    }

    it "should instantiate" do
      lambda { some_klass.new }.should_not raise_error
    end

    context "given an attr" do
      let(:expected_value) { "class-bar" }
      let(:attr) { :foo }

      before :each do
        some_klass.class_eval do
          attr_super_reader :foo
          def initialize
            @foo = "class-bar"
          end
        end
      end

      it "should return the class's attr" do
        some_klass.new.foo.should == expected_value
      end
      context "given a module with attr" do
        let(:expected_value) { "module-bar" }
        before :each do
          some_klass.send(:include, some_module)
        end
        it "should return the module's attr" do
          some_klass.new.foo.should == expected_value
        end
      end

    end

  end
end
