module Itunes
  #File.open("./tmp/foo.xml",'w') do |f|
  #  f.puts Itunes::Library::Generator.generate
  #  f.puts Itunes::Library::Generator.generate(:username => "my_home_dir")
  #  OR
  #  f.puts Itunes::Library::Generator.generate(:music_dir => "./tmp/")
  #end
  #
  # Stress test:
  #File.open("./tmp/foo.xml",'w') do |f|
  #  f.puts Itunes::Library::Generator.generate(:num_tracks => 10_000, :num_playlists => 1500, :tracks_per_playlist => 300)
  #end
  module Library::Generator
    extend self

    def generate(options={})
      library = options[:library]
      num_tracks = library ? library.tracks.count : options[:num_tracks] || 1
      num_playlists = library ? library.playlists.count : options[:num_playlists] || 1
      tracks_per_playlist = options[:tracks_per_playlist] || 1

      track_ids = library ? library.track_ids : (1..num_tracks).to_a
      playlist_ids =  library ? library.playlist_ids : (1..num_playlists).to_a

      username = options[:username] || default_username
      users_music_dir = options[:music_dir] || music_dir(username)
      result = header(html_safe(users_music_dir))
      result << tracks_wrapper_header
      if library
        track_ids.each do |i|
          the_track = Library::Track.lookup(i.to_s)
          result << track(i, the_track.title, :music_dir => users_music_dir, :release_name => the_track.album, :artist_name => the_track.artist, :genre => the_track.genre)
        end
      else
        track_ids.each {|i| result << track(i, "track_#{i}", :music_dir => users_music_dir)}
      end
      result << tracks_wrapper_footer

      result << playlists_wrapper_header
      playlist_ids.each do |i|
        if library
          playlist = Library::Playlist.lookup(i.to_s)
          result << playlist_tracks_wrapper_header(i, playlist.title, :persistent_id => playlist.persistent_id)
          playlist.track_ids.each {|ti| result << playlist_track(ti) }
        else
          result << playlist_tracks_wrapper_header(i, "playlist_#{i}")
          tracks_per_playlist.times { result << playlist_track(track_ids[rand(num_tracks)]) }
        end
        result << playlist_tracks_wrapper_footer
      end
      result << playlists_wrapper_footer

      result << footer
    end

    def default_username
      'your_home_directory'
    end

    def music_dir(username=default_username)
      "file://localhost/Users/#{username}/Music/iTunes/iTunes Music/"
    end

    def header(html_safe_music_dir)
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
      <string>#{html_safe_music_dir}</string>
      <key>Library Persistent ID</key><string>8E84CC790968E27F</string>
      EOD
    end

    def tracks_wrapper_header
      result = <<-EOTS
          <key>Tracks</key>
      <dict>
      EOTS
    end

    def html_safe(str)
      str.gsub(/\s+/,'%20')
    end

    def default_track_extension
      '.m4p'
    end

    def music_file(name, extension=default_track_extension)
      html_safe(name) + extension
    end

    def default_release_name
      'Prime Time'
    end

    def default_artist_name
      'Count Basie and His Orchestra'
    end

    def track(track_id, name, options={})
      release_name = options[:release_name] || default_release_name
      artist_name = options[:artist_name] || default_artist_name
      html_safe_artist_name = html_safe artist_name
      html_safe_release_name = html_safe release_name
      track_extension = options[:track_extension] || default_track_extension
      track_file = music_file(name, track_extension)
      genre = options[:genre] || 'Jazz'
      _music_dir = html_safe(options[:music_dir] || music_dir)

      result = <<-EOT
      <key>#{track_id}</key>
      <dict>
      <key>Track ID</key><integer>#{track_id}</integer>
      <key>Name</key><string>#{name}</string>
      <key>Artist</key><string>#{artist_name}</string>
      <key>Composer</key><string>Bernie/Pinkard/Casey</string>
      <key>Album</key><string>#{release_name}</string>
      <key>Genre</key><string>#{genre}</string>
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
      <key>Location</key><string>#{_music_dir}#{html_safe_artist_name}/#{html_safe_release_name}/#{track_file}</string>
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
      persistent_id = options[:persistent_id] || '88CED99A2F698F3C'
      result = <<-EOPTS
      <dict>
      <key>Name</key><string>#{playlist_title}</string>
      <key>Playlist ID</key><integer>#{playlist_id}</integer>
      <key>Playlist Persistent ID</key><string>#{persistent_id}</string>
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
