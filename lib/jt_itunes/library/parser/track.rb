module JtItunes
  class Library
    module Parser::Track
      def self.included(base)
        base.send(:include, JtItunes::Library::Parseable)
        base.extend ClassMethods
      end

      module ClassMethods
        def _attr_symbols
          [:id, :title, :album, :artist, :total_time, :genre, :persistent_id, :location]
        end
        alias :_attributes :_attr_symbols

        def _attr_names
          ["Track ID", "Name", "Album", "Artist", "Total Time", "Genre", "Persistent ID", "Location"]
        end

        def xpath
          '/plist/dict/dict/dict'
        end
      end
    end # Parser::Track
  end
end
