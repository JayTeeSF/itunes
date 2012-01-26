module Itunes
  class Library

    attr_reader :id
    attr_accessor :playlists, :tracks, :mode

    XPATH  = '/plist/dict'
    def self.id_key
      'Library Persistent ID'
    end

    def self.parse(parser)
      key = nil
      id_attr = parser.xml.xpath(XPATH).children.detect do |attribute|
        if attribute.name == 'key' && attribute.text == id_key
          key = id_key
          false
        elsif key
          key = nil
          true
        end
      end

      new(id_attr.text, :mode => parser.mode).tap do |library|
        library.tracks = Track.parse(parser)
        unless library.ignore_playlists?
          library.playlists = Playlist.parse(parser)
        end
      end
    end

    # NOTE - Parsing (314) playlists added 195 seconds to an otherwise sub-second library-parse (of 5517-track)
    def ignore_playlists?
      mode == Parser::DEFAULT_MODE
    end
    def csv_header
      ignore_playlists? ?  Track.csv_header : Playlist.csv_header
    end

    def to_csv
      csv_header + "\n" + csv_rows
    end

    def csv_rows
      if ignore_playlists?
        return "" unless tracks.present?
        tracks.map(&:csv_row).join("\n")
      else
        return "" unless playlists.present?
        playlists.map(&:csv_rows).join("\n")
      end
    end

    def initialize(id_string, options={})
      @mode = options[:mode] || Parser::DEFAULT_MODE
      @id = id_string
      @playlists = []
      @tracks = []
    end
  end # Library
end
