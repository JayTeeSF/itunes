module Itunes
  class Library::Track
    class << self
      def _attr_symbols
        [:id, :title, :album, :artist, :total_time, :genre, :persistent_id, :location]
      end
      alias :_attributes :_attr_symbols
    end

    include Library::MusicSelection
    alias :name :title
    alias :name= :title=
    include Itunes::Library::Delimitable
    include Itunes::Library::Parseable

    # bgn - parse
    class << self
      def _attr_names
        ["Track ID", "Name", "Album", "Artist", "Total Time", "Genre", "Persistent ID", "Location"]
      end
    end

    class << self
      def xpath
        '/plist/dict/dict/dict'
      end
    end
    # end - parse
  end # Track
end
