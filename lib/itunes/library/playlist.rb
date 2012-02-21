module Itunes
  class Library::Playlist
    class << self
      def _attr_symbols
        [:id, :name, :persistent_id, :parent_persistent_id]
      end
      alias :_attributes :_attr_symbols

      def csv_header
        super + Itunes::Library::DELIMITER + Track.csv_header
      end
    end
    include Library::MusicSelection

    attr_reader :track_ids
    def initialize(options={})
      clear_track_cache
      @track_ids = options[:track_ids_key] || []
      super
    end

    def <<(track_id)
      clear_track_cache
      @track_ids << track_id
    end
    alias :push :<<

    def clear_track_cache
      @tracks = nil
    end
    private :clear_track_cache

    def tracks
      @tracks ||= Track.lookup_all(track_ids.uniq)
    end

    def csv_rows
      return "" unless tracks.present?
      tracks.collect do |t|
        csv_row.join(Itunes::Library::DELIMITER) + Itunes::Library::DELIMITER + t.csv_row
      end.join("\n")
    end
    include Itunes::Library::Delimitable

    # bgn - parse
    XPATH  = '/plist/dict/array/dict'
    # <key>Name</key><string>Library</string>
    # <key>Playlist ID</key><integer>13414</integer>
    # <key>Playlist Persistent ID</key><string>D86410305F758D44</string>
    # <key>Parent Persistent ID</key><string>18335EC8291502A6</string>
    #
    # TRACK_ID_XPATH  = '/plist/dict/array/dict/array/dict'
    TRACK_ID_XPATH  = '../array/dict'
    TRACK_ID_ATTR  = 'Track ID'
    # <key>Playlist Items</key>
    # <array>
    #  <dict>
    #   <key>Track ID</key><integer>3096</integer>
    #  </dict>
    # ....
    # </array>
    class << self
      def _attr_names
        ["Playlist ID", "Name", "Playlist Persistent ID", "Parent Persistent ID"]
      end

      def track_ids_key
        'Playlist Items'
      end

      def parse(itunes_library_parser)
        itunes_library_parser.xml.xpath(XPATH).map do |playlist_entry|
          key = nil
          playlist_hash = {}
          playlist_entry.children.each do |attribute|
            if new_known_key?(attribute, [track_ids_key] + _attr_names)
              key = attribute.text
            elsif key
              if key == track_ids_key
                playlist_hash[track_ids_key] ||= []
                playlist_hash[track_ids_key] |= extract_track_ids_from(attribute)
                # not sure if we should clear key, at this point, i.e. key = nil
              else
                playlist_hash[key] = attribute.text
                key = nil
              end
            end
          end
          create extract_params(
            playlist_hash, {
            :for_keys => playlist_hash.keys,
            :as => itunes_names_to_symbols.merge({Library::Playlist.track_ids_key => :track_ids_key})
          })
        end
      end

      def extract_track_ids_from(attribute)
        track_id_key = nil
        attribute.xpath(TRACK_ID_XPATH).children.reduce([]) do |memo, track_id_attribute|
          if new_key?(track_id_attribute) && TRACK_ID_ATTR == track_id_attribute.text
            track_id_key = true
          elsif track_id_key
            memo << track_id_attribute.text
            track_id_key = nil
          end
          memo
        end
      end
    end
    # end - parse
  end # Playlist
end
