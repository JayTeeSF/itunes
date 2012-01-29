require 'object_cache'
module Itunes
  class Library::Playlist
    include ObjectCache

    XPATH  = '/plist/dict/array/dict'
    # <key>Name</key><string>Library</string>
    # <key>Playlist ID</key><integer>13414</integer>
    # <key>Playlist Persistent ID</key><string>D86410305F758D44</string>
    # <key>Parent Persistent ID</key><string>18335EC8291502A6</string>
    #
    # TRACK_ID_XPATH  = '/plist/dict/array/dict/array/dict'
    TRACK_ID_XPATH  = '../array/dict'
    #	<key>Playlist Items</key>
    #	<array>
    #		<dict>
    #			<key>Track ID</key><integer>3096</integer>
    #		</dict>
    #	....
    #	</array>

    def self.track_ids_key
      'Playlist Items'
    end

    ATTRIBUTES = ["Playlist ID", "Name", "Playlist Persistent ID", "Parent Persistent ID"]
    ATTR_SYMBOLS =  [:id, :name, :persistent_id, :parent_persistent_id]
    ATTR_MAP = Hash[ATTRIBUTES.zip(ATTR_SYMBOLS)]

    attr_accessor *ATTR_SYMBOLS
    attr_reader :track_ids
    def self.csv_header
      Playlist::ATTRIBUTES.join(Itunes::Library::SEPARATOR) + Itunes::Library::SEPARATOR + Track.csv_header
    end

    def self.create attributes = {}
      new(attributes)
    end

    def initialize(options={})
      @track_ids = options[:track_ids] || []

      ATTR_MAP.each_pair do |attr, method|
        send("#{method}=", options[attr]) if options[attr]
      end
      raise Library::Invalid, "missing ID" unless id
      self.class.cache[id] = self
    end

    def self.parse(itunes_library_parser)
      itunes_library_parser.xml.xpath(XPATH).map do |playlist_entry|
        key = nil
        playlist_hash = {}
        playlist_entry.children.each do |attribute|
          if attribute.name == 'key' && ([Playlist.track_ids_key] + Playlist::ATTRIBUTES).include?(attribute.text)
            key = attribute.text
          elsif key && key == Playlist.track_ids_key
            # parse track_ids from the current attribute:
            track_id_key = nil
            attribute.xpath(TRACK_ID_XPATH).children.each do |track_id_attribute|
              if track_id_attribute.name == 'key' && track_id_attribute.text == 'Track ID'
                track_id_key = true #track_id_attribute.text
              elsif track_id_key
                playlist_hash[:track_ids] ||= []
                playlist_hash[:track_ids] << track_id_attribute.text
                track_id_key = nil
              end
            end
          elsif key
            playlist_hash[key] = attribute.text
            key = nil
          end
        end
        create playlist_hash
      end
    end # parse

    def <<(track_id)
      @track_ids << track_id
    end
    alias :push :<<

    def tracks
      @tracks ||= Track.lookup_all(track_ids.uniq)
    end

    def csv_rows
      return "" unless tracks.present?
      tracks.collect do |t|
        (Playlist::ATTRIBUTES.map {|attribute| self.send(ATTR_MAP[attribute]) || ""}).join(Itunes::Library::SEPARATOR) + Itunes::Library::SEPARATOR + t.csv_row
      end.join("\n")
    end
  end # Playlist
end
