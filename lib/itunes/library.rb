module Itunes
  class Library
    class Invalid < Exception; end
    SEPARATOR = "\t"
    attr_reader :id
    attr_accessor :playlists, :tracks, :mode, :parser

    XPATH  = '/plist/dict'
    def self.id_key
      'Library Persistent ID'
    end

    def self.generate(options={})
      Generator.generate(options)
    end

    def self.parse(itunes_library_parser)
      key = nil
      id_attr = itunes_library_parser.xml.xpath(XPATH).children.detect do |attribute|
        if attribute.name == 'key' && attribute.text == id_key
          key = id_key
          false
        elsif key
          key = nil
          true
        end
      end
      new(id_attr.text, :mode => itunes_library_parser.mode, :parser => itunes_library_parser)
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

    def to_csv
      csv_header + "\n" + csv_rows
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

    def initialize(id_string, options={})
      @mode = options[:mode] || Parser::DEFAULT_MODE
      @id = id_string
      @parser = options[:parser]
    end
  end # Library
end
Dir.glob("#{File.dirname(__FILE__) + '/library'}/*.rb").each {|f| require(f)}
