module JtItunes
  class Library
    class Invalid < Exception; end

    def generate(options={})
      Generator.generate(options.merge({:library => self}))
    end

    def playlist_ids
      playlists.map(&:id)
    end

    def track_ids
      tracks.map(&:id)
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
    include JtItunes::Library::Delimitable
    include ClassHelpers
    include JtItunes::Library::Parser::Library

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
    attr_accessor :mode
    attr_writer :playlists, :tracks
    attr_super_reader :playlists, :tracks

    def initialize(id_string, options={})
      @id = id_string
      @mode = options.delete(:mode) || Parser::DEFAULT_MODE
      super(options)
    end
  end # Library
end
