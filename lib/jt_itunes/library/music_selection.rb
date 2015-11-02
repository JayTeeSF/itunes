require 'object_cache'
module JtItunes
  module Library::MusicSelection
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
    end

    def self.included(base)
      base.class_eval do
        include ::ObjectCache
        cache :in => :memory # DEFAULT
        extend ClassMethods
        attr_accessor *(base._attributes)
      end
    end

    def translated(attr)
      attr
    end

    def initialize(options={})
      tr_options = options.keys.reduce({}) {|memo, key| memo[translated(key)] = options[key]; memo }
      self.class.attr_map.each_pair do |attr, method|
        attr = translated(attr)
        send("#{method}=", tr_options[attr.to_s] || tr_options[attr.to_sym]) if tr_options[attr.to_s] || tr_options[attr.to_sym]
      end
      raise Library::Invalid, "missing ID" unless id
    end
  end # MusicSelection
end
