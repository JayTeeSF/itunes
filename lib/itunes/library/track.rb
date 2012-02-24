module Itunes
  class Library::Track
    include Itunes::Library::Parser::Track
    include Library::MusicSelection
    alias :name :title
    alias :name= :title=
    include Itunes::Library::Delimitable
  end # Track
end
