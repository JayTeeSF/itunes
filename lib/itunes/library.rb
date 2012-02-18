module Itunes
  class Library
    class Invalid < Exception; end

    XPATH  = '/plist/dict'
    def self.parse(itunes_library_parser)
      key = nil
      id_attr = itunes_library_parser.xml.xpath(XPATH).children.detect do |attribute|
        if attribute.name == KEY && attribute.text == id_key
          key = id_key
          false
        elsif key
          key = nil
          true
        end
      end
      create(id_attr.text, :mode => itunes_library_parser.mode, :parser => itunes_library_parser)
    end

    def self.id_key
      'Library Persistent ID'
    end

    # TODO: (re-)move this method
    # Library::File.generate, maybe...
    def self.generate(options={})
      Generator.generate(options)
    end

    def playlists
      @playlists ||= Playlist.parse(parser)
    end

    def tracks
      @tracks ||= Track.parse(parser)
    end

    # NOTE - Parsing (314) playlists added 195 seconds to an otherwise sub-second library-parse (of 5517-track)
    def ignore_playlists?
      mode == Parser::DEFAULT_MODE
    end

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

    def self._attributes
     []
    end

    %w{delimitable file generator music_selection parser playlist track}.each do |_file|
      require("#{::File.dirname(__FILE__) + '/library'}/#{_file}.rb")
    end
    include MusicSelection
    include Itunes::Library::Delimitable

    attr_reader :id
    attr_writer :playlists, :tracks
    attr_accessor :mode, :parser

    def initialize(id_string, options={})
      @id = id_string
      @mode = options[:mode] || Parser::DEFAULT_MODE
      @parser = options[:parser]
      super
    end
  end # Library
end
