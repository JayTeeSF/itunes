module ClassHelpers
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def attr_super_reader *attr_or_attrs
      attr_or_attrs.each do |attr|
        define_method(attr) { defined?(super) ? super() : instance_variable_get("@#{attr}")}
      end
    end
  end
end
