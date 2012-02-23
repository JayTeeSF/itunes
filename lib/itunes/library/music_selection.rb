require 'object_cache'
module Itunes
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
        include ObjectCache
        # add new 'object_cache method':
        #   cache :in => [:memory, :db]
        # for example, for fast in-memory caching w/ subsequent backup to db
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

    # TODO: update cache_object gem
    # enable it to call active_record or mongo
    # or some file-writer
    def save_in_memory(_id, _obj)
      #warn "saving in memory"
      self.class.cache[_id] = _obj
    end

    # replace location w/ an instance var (see new 'object_cache method' above)
    def save(_id=id, _obj=self, location=:in_memory)
      method_name = "save_#{location}"
      send(method_name, _id, _obj)
    end

    def save_to_file(_id, _obj)
      unless output_file || File.exists(output_file)
        raise RuntimeError, "Unable to save_to_file: Output File not specified or invalid"
      end
      raise NotImplementedError, "Unable to save_to_file"
    end

    def save_to_db(_id, _obj)
      unless db_obj || db_obj.respond_to?(:save)
        raise RuntimeError, "Unable to save_to_db: db_obj not specified or invalid"
      end
      raise NotImplementedError, "Unable to save_to_db"
    end
  end # MusicSelection
end
