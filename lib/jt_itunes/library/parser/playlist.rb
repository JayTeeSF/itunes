module JtItunes
  class Library
    module Parser::Playlist
      def self.included(base)
        base.send(:include, JtItunes::Library::Parseable)
        base.extend ClassMethods
      end

      module ClassMethods
        def _attr_symbols
          [:id, :title, :persistent_id, :parent_persistent_id]
        end
        alias :_attributes :_attr_symbols

        def csv_header
          super + JtItunes::Library::DELIMITER + JtItunes::Library::Track.csv_header
        end

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
          {JtItunes::Library::Playlist.track_ids_key => :track_ids_key }
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
    end # Parser::Playlist
  end
end
