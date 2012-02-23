module Itunes
  class Library
    class Invalid < Exception; end

    def self.xpath
      '/plist/dict'
    end
    def self.parse(itunes_library_parser)
      id_val = next_node_in(itunes_library_parser.xml.xpath(xpath).children, [id_key])
      create(id_val.text, :mode => itunes_library_parser.mode, :parser => itunes_library_parser)
    end

    def self.id_key
      'Library Persistent ID'
    end

    def generate(options={})
      Generator.generate(options.merge({:library => self}))
    end

    def playlist_ids
      playlists.map(&:id)
    end

    def playlists
      @playlists ||= Playlist.parse(parser)
    end

    def track_ids
      tracks.map(&:id)
    end

    def tracks
      @tracks ||= Track.parse(parser)
    end

    # NOTE - Parsing (314) playlists added 195 seconds to an otherwise sub-second library-parse (of 5517-track)
    def ignore_playlists?
      mode == Parser::DEFAULT_MODE
    end

    def self._attr_names
     []
    end
    def self._attributes
     []
    end

    %w{parseable delimitable file generator music_selection parser playlist track}.each do |_file|
      require("#{::File.dirname(__FILE__) + '/library'}/#{_file}.rb")
    end
    include MusicSelection
    include Itunes::Library::Delimitable
    include Itunes::Library::Parseable

    def csv_header
      ignore_playlists? ?  Track.csv_header : Playlist.csv_header
    end

    def csv_rows
      if ignore_playlists?
        return "" if tracks.empty?
        tracks.map(&:csv_row).join("\n")
      else
        return "" if playlists.empty?
        playlists.map(&:csv_rows).join("\n")
      end
    end

    attr_reader :id
    attr_writer :playlists, :tracks
    attr_accessor :mode, :parser

    def initialize(id_string, options={})
      @id = id_string
      @mode = options.delete(:mode) || Parser::DEFAULT_MODE
      @parser = options.delete(:parser)
      super(options)
    end
  end # Library
end
