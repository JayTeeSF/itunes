module Itunes
  class Library::Playlist
    class << self
      def _attr_symbols
        [:id, :title, :persistent_id, :parent_persistent_id]
      end
      alias :_attributes :_attr_symbols

      def csv_header
        super + Itunes::Library::DELIMITER + Track.csv_header
      end
    end
    include Library::MusicSelection
    alias :name :title
    alias :name= :title=

      attr_reader :track_ids
    def initialize(options={})
      clear_track_cache
      @track_ids = options[:track_ids_key] || []
      super
    end

    def <<(track_or_track_id)
      if track_or_track_id.is_a?(Track)
        @tracks << track_or_track_id
      else
        clear_track_cache
        @track_ids << track_or_track_id
      end
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
    include Itunes::Library::Parseable

    # bgn - parse
    class << self
      def xpath
        '/plist/dict/array/dict'
      end

      def sub_id_xpath
        '../array/dict'
      end

      def sub_id_attr
        'Track ID'
      end

      def symbol_overrides
        {Library::Playlist.track_ids_key => :track_ids_key }
      end

      def _attr_names
        ["Playlist ID", "Name", "Playlist Persistent ID", "Parent Persistent ID"]
      end

      def track_ids_key
        'Playlist Items'
      end
      alias :sub_ids_key :track_ids_key

      def key_node_attrs(node)
        super << [sub_ids_key] + _attr_names
      end
    end
    # end - parse
  end # Playlist
end
