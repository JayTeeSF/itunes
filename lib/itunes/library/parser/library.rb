module Itunes
  class Library
    module Parser::Library
      def self.included(base)
        base.send(:include, Itunes::Library::Parseable)
        base.extend ClassMethods
        base.send(:attr_accessor, :parser)
      end

      module ClassMethods
        def xpath
          '/plist/dict'
        end
        def parse(itunes_library_parser)
          id_val = next_node_in(itunes_library_parser.xml.xpath(xpath).children, [id_key])
          create(id_val.text, :mode => itunes_library_parser.mode, :parser => itunes_library_parser)
        end

        def id_key
          'Library Persistent ID'
        end
      end

      def playlists
        #l.playlists = Playlist.parse(parser)
        @playlists ||= ::Itunes::Library::Playlist.parse(parser)
      end

      def tracks
        #l.tracks = Track.parse(parser)
        @tracks ||= ::Itunes::Library::Track.parse(parser)
      end

      # include ClassHelpers
      # attr_super_reader :playlists, :tracks

      def initialize(options={})
        #@mode = options.delete(:mode) || Parser::DEFAULT_MODE
        @parser = options.delete(:parser)
        super(options)
      end
    end # Parsers::Library
  end
end
