module Itunes
  module Library::Delimitable
    DELIMITER = "\t"
    #REQUIRED_CLASS_METHODS = [[:_attributes, :csv_header], [:csv_rows, :csv_row, :attr_map]]
    #REQUIRED_INSTANCE_METHODS = [[:csv_header, :to_csv]]

    module ClassMethods
      def csv_header
        _attributes.join(Itunes::Library::Delimitable::DELIMITER)
      end
    end

    def self.included(base)
      # ugh1: how-to check instance methods, since base.new may raise an ArgumentError
      # ugh2: mix & match class/instance rqts:
      # .csv_header is only needed if #csv_rows is not implemented
      #ensure_compatibility_of(base)
      #ensure_compatibility_of(base.new, :with => REQUIRED_INSTANCE_METHODS)
      base.class_eval do
        extend ClassMethods
      end
    end

    def self.ensure_compatibility_of(base, options={:with => REQUIRED_CLASS_METHODS})
      options[:with].each do |required_methods|
        supported = required_methods.any? {|required_method|
          base.respond_to?(required_method)
        }
        raise NotImplementedError, "#{base} does not support '#{required_methods.join(' or ')}'" unless supported
      end
    end

    def csv_row
      (self.class._attributes.map {|attribute| self.send(self.class.attr_map[attribute]) || ""}.join(DELIMITER))
    end

    def csv_rows
      [csv_row]
    end

    def to_csv
      csv_header + "\n" + csv_rows
    end
  end
end
