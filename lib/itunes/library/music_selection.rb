require 'object_cache'
module Itunes
  module Library::MusicSelection
    KEY = 'key' # parse
    module ClassMethods
      def attr_map
        identity_map(_attributes)
      end

      # bgn utility method(s)
      # e.g. (Array.to_hash)
      def identity_map(keys=[])
        Hash[keys.zip(keys)]
      end

      def extract_params(from, options={:for_keys => [], :to => {}, :as => {}})
        for_keys = options[:for_keys] || []
        to = options[:to] || {}
        as = identity_map(for_keys).merge(options[:as] || {})
        for_keys.reduce(to) {|memo, key| memo[as[key]] = from[key]; memo}
      end
      # end utility method(s)

      def create *args
        new(*args).tap do |obj|
          obj.save
        end
      end

      # bgn - parse
      def itunes_names_to_symbols
        Hash[_attr_names.zip(_attr_symbols)]
      end

      def new_known_key? attribute, attribute_list=_attr_names
        new_key?(attribute) && known_attribute?(attribute, attribute_list)
      end

      def new_key? attribute
        KEY == attribute.name
      end

      def known_attribute? attribute, attribute_list=_attr_names
        attribute_list.include?(attribute.text)
      end
      # end - parse
    end

    def self.included(base)
      base.class_eval do
        include ObjectCache
        extend ClassMethods
        attr_accessor *(base._attributes)
      end
    end

    def initialize(options={})
      self.class.attr_map.each_pair do |attr, method|
        send("#{method}=", options[attr]) if options[attr]
      end
      raise Library::Invalid, "missing ID" unless id
    end

    def save_in_memory
      warn "saving in memory"
      self.class.cache[id] = self
    end

    # TODO: update cache_object gem
    # enable it to call active_record or mongo
    # or some file-writer
    def save(location=:in_memory)
      method_name = "save_#{location}"
      send(method_name)
    end

    def save_to_file
      unless output_file || File.exists(output_file)
        raise RuntimeError, "Unable to save_to_file: Output File not specified or invalid"
      end
      raise NotImplementedError, "Unable to save_to_file"
    end

    def save_to_db
      unless db_obj || db_obj.respond_to?(:save)
        raise RuntimeError, "Unable to save_to_db: db_obj not specified or invalid"
      end
      raise NotImplementedError, "Unable to save_to_db"
    end
  end # MusicSelection
end
