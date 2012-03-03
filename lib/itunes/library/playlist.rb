module Itunes
  class Library::Playlist
    include Library::Parser::Playlist
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
      if track_or_track_id.is_a?(Library::Track)
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
      @tracks ||= Library::Track.lookup_all(track_ids.uniq)
    end

    def csv_rows
      return "" unless tracks.present?
      tracks.collect do |t|
        csv_row.join(Itunes::Library::DELIMITER) + Itunes::Library::DELIMITER + t.csv_row
      end.join("\n")
    end
    include Itunes::Library::Delimitable
  end # Playlist
end
