require 'object_cache'
module Itunes
  module Library::MusicSelection
    module ClassMethods
      def attr_map
        Hash[_attributes.zip(_attr_symbols)]
      end

      # bgn utility method(s)
      # e.g. (Array.to_hash)
      def identity_map(keys=[])
        Hash[keys.zip(keys)]
      end

      def extract_params(from, options={:for_keys => [], :to => {}, :as => {}})
        for_keys = options[:for_keys] || []
        as = identity_map(for_keys).merge(options[:as] || {})
        for_keys.reduce(to) {|memo, key| memo[as[key]] = from[key]; memo}
      end
      # end utility method(s)

      def create attrs = {}
        new(attrs).tap do |obj|
          obj.save
        end
      end

      # bgn parse
      KEY = 'key'
      def new_known_key? attribute, attribute_list=_attr_names
        new_key?(attribute) && known_attribute?(attribute, attribute_list)
      end

      def new_key? attribute
        KEY == attribute.name
      end

      def known_attribute? attribute, attribute_list=_attr_names
        attribute_list.include?(attribute.text)
      end
      # end parse
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

    def save
      self.class.cache[id] = self
    end
  end # MusicSelection
end
