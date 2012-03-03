namespace :itunes do

  desc 'extract csv of track from local JtItunes XML'
  task :tracks_csv, [:input_file, :output_file] => [:environment] do |t, args|
    args.with_defaults(:output_file  => nil)
    output_file = args[:output_file]

    input_file = args[:input_file]
    unless input_file && File.exist?(input_file)
      puts "File #{input_file.inspect} does not exist: please enter a valid file"
      exit(1)
    end

    options = {}
    options[:out_doc] = output_file if output_file
    JtItunes::Library::Parser.parse_local(input_file)
  end

  desc 'extract csv of playlists (and tracks) from local JtItunes XML'
  task :playlists_csv, [:input_file, :output_file] => [:environment] do |t, args|
    args.with_defaults(:output_file  => nil)
    output_file = args[:output_file]

    input_file = args[:input_file]
    unless input_file && File.exist?(input_file)
      puts "File #{input_file.inspect} does not exist: please enter a valid file"
      exit(1)
    end

    options = {:mode => :parse_tracks}
    options[:out_doc] = output_file if output_file
    JtItunes::Library::Parser.parse_local(input_file, options)
  end
end
