module Itunes
  class Library::Track

    XPATH  = '/plist/dict/dict/dict'
    def self.parse(itunes_library_parser)
      itunes_library_parser.xml.xpath(XPATH).map do |track_entry|
        key = nil
        track_attributes = track_entry.children.reduce({}) do |track_hash, attribute|
          if new_known_key? attribute
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

    def self._attr_names
      ["Track ID", "Name", "Album", "Artist", "Total Time", "Genre", "Persistent ID", "Location"]
    end

    def self._attr_symbols
      [:id, :name, :album, :artist, :total_time, :genre, :persistent_id, :location]
    end
    def self._attributes
      _attr_symbols
    end
    include Library::MusicSelection
    include Itunes::Library::Delimitable
  end # Track
end
