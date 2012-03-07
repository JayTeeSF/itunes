module JtItunes
  class Library::Track
    include JtItunes::Library::Parser::Track
    include Library::MusicSelection
    alias :preview_url :location
    alias :preview_url= :location=
    alias :name :title
    alias :name= :title=
    include JtItunes::Library::Delimitable
  end # Track
end
