module Itunes
  class Library::Track

    # bgn - parse
    class << self
      def _attr_names
        ["Track ID", "Name", "Album", "Artist", "Total Time", "Genre", "Persistent ID", "Location"]
      end
    end
    # end - parse

    class << self
      def _attr_symbols
        [:id, :name, :album, :artist, :total_time, :genre, :persistent_id, :location]
      end
      alias :_attributes :_attr_symbols
    end

    include Library::MusicSelection
    include Itunes::Library::Delimitable

    # bgn - parse
    XPATH  = '/plist/dict/dict/dict'
    class << self
      def parse(itunes_library_parser)
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
          create extract_params(
            track_attributes, {
            :for_keys => track_attributes.keys,
            :as => itunes_names_to_symbols
          })
        end.compact
      end
    end
    # end - parse

  end # Track
end
