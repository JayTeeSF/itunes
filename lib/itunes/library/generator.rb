module Itunes
  #File.open("./tmp/foo.xml",'w') do |f|
  #  f.puts Itunes::Library::Generator.library
  #end
  #
  # Stress test:
  #File.open("./tmp/foo.xml",'w') do |f|
  #  f.puts Itunes::Library::Generator.library(10_000, 1500, 300)
  #end
  module Library::Generator
    extend self

    def library(num_tracks=1, num_playlists=1, tracks_per_playlist=1)
      track_ids = (1..num_tracks).to_a
      playlist_ids = (1..num_playlists).to_a

      result = header
      result << tracks_wrapper_header
      track_ids.each {|i| result << track(i, "track_#{i}")}
      result << tracks_wrapper_footer

      result << playlists_wrapper_header
      playlist_ids.each do |i|
        result << playlist_tracks_wrapper_header(i, "playlist_#{i}")
        tracks_per_playlist.times { result << playlist_track(track_ids[rand(num_tracks)]) }
        result << playlist_tracks_wrapper_footer
      end
      result << playlists_wrapper_footer

      result << footer
    end

    def header
      result = <<-EOD
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
      "http://www.apple.com/DTDs/PropertyList-1.0.dtd">

      <plist version="1.0">
      <dict>
      <key>Major Version</key><integer>1</integer>
      <key>Minor Version</key><integer>1</integer>
      <key>Application Version</key><string>4.6</string>
      <key>Music Folder</key>
      <string>file://localhost/Users/niel/Music/iTunes/iTunes%20Music/</string>
      <key>Library Persistent ID</key><string>8E84CC790968E27F</string>
      EOD
    end

    def tracks_wrapper_header
      result = <<-EOTS
          <key>Tracks</key>
      <dict>
      EOTS
    end

    def track(track_id, name, options={})
      result = <<-EOT
      <key>#{track_id}</key>
      <dict>
      <key>Track ID</key><integer>#{track_id}</integer>
      <key>Name</key><string>#{name}</string>
      <key>Artist</key><string>#{options[:artist_name] || 'Count Basie & His Orchestra'}</string>
      <key>Composer</key><string>Bernie/Pinkard/Casey</string>
      <key>Album</key><string>#{options[:release_name] || 'Prime Time'}</string>
      <key>Genre</key><string>Jazz</string>
      <key>Kind</key><string>Protected AAC audio file</string>
      <key>Size</key><integer>3771502</integer>
      <key>Total Time</key><integer>219173</integer>
      <key>Disc Number</key><integer>1</integer>
      <key>Disc Count</key><integer>1</integer>
      <key>Track Number</key><integer>3</integer>
      <key>Track Count</key><integer>8</integer>
      <key>Year</key><integer>1977</integer>
      <key>Date Modified</key><date>2004-06-16T18:10:55Z</date>
      <key>Date Added</key><date>2004-06-16T18:08:31Z</date>
      <key>Bit Rate</key><integer>128</integer>
      <key>Sample Rate</key><integer>44100</integer>
      <key>Play Count</key><integer>3</integer>
      <key>Play Date</key><integer>-1119376103</integer>
      <key>Play Date UTC</key><date>2004-08-17T16:39:53Z</date>
      <key>Rating</key><integer>100</integer>
      <key>Artwork Count</key><integer>1</integer>
      <key>File Type</key><integer>1295274016</integer>
      <key>File Creator</key><integer>1752133483</integer>
      <key>Location</key><string>file://localhost/Users/niel/Music/iTunes/iTunes%20Music/Count%20Basie%20&%20His%20Orchestra/Prime%20Time/03%20Sweet%20Georgia%20Brown.m4p</string>
      <key>File Folder Count</key><integer>4</integer>
      <key>Library Folder Count</key><integer>1</integer>
      </dict>
      EOT
    end

    def tracks_wrapper_footer
      results = <<-EOTS
      </dict>
      EOTS
    end

    def playlists_wrapper_header
      result = <<-EOPS
      <key>Playlists</key>
      <array>
      EOPS
    end


    def playlist_tracks_wrapper_header(playlist_id, playlist_title, options={})
      result = <<-EOPTS
      <dict>
      <key>Name</key><string>#{playlist_title}</string>
      <key>Playlist ID</key><integer>#{playlist_id}</integer>
      <key>Playlist Persistent ID</key><string>#{options[:persistent_id] || '88CED99A2F698F3C'}</string>
      <key>All Items</key><true/>
      <key>Playlist Items</key>
      <array>
      EOPTS
    end

    def playlist_track(track_id)
      result = <<-EOPT
      <dict>
      <key>Track ID</key><integer>#{track_id}</integer>
      </dict>
      EOPT
    end

    def playlist_tracks_wrapper_footer
      result = <<-EOPTS
      </array>
      </dict>
      EOPTS
    end

    def playlists_wrapper_footer
      result = <<-EOPS
      </array>
      EOPS
    end

    def footer
      result = <<-EOD
      </dict>
      </plist>
      EOD
    end
  end
end
