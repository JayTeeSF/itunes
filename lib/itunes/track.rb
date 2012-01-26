module Itunes
  class Track
    XPATH  = '/plist/dict/dict/dict'
    include ObjectCache
    class Invalid < Exception; end
    ATTRIBUTES = ["Track ID", "Name", "Album", "Artist", "Total Time", "Genre", "Persistent ID", "Location"]
    ATTR_SYMBOLS =  [:id, :name, :album, :artist, :genre, :persistent_id, :total_time, :location]
    ATTR_MAP = Hash[ATTRIBUTES.zip(ATTR_SYMBOLS)]

    attr_accessor *ATTR_SYMBOLS
    def self.csv_header
      Track::ATTRIBUTES.join(Itunes::SEPARATOR)
    end

    def self.create attributes = {}
      new(attributes)
    end

    def self.parse(parser)
      parser.xml.xpath(XPATH).map do |track_entry|
        key = nil
        track_attributes = track_entry.children.reduce({}) do |track_hash, attribute|
          if attribute.name == 'key' && Track::ATTRIBUTES.include?(attribute.text)
            key = attribute.text
          elsif key
            track_hash[key] = attribute.text
            key = nil
          end
          track_hash
        end
        create track_attributes
      end.compact
    end # parse

    def initialize(options={})
      ATTR_MAP.each_pair do |attr, method|
        send("#{method}=", options[attr]) if options[attr]
      end
      raise Invalid, "missing ID" unless id
      self.class.cache[id] = self
    end

    def csv_row
      Track::ATTRIBUTES.map {|attribute| self.send(ATTR_MAP[attribute]) || ""}.join(Itunes::SEPARATOR)
    end
  end # Track
end
