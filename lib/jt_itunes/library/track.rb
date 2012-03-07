module JtItunes
  class Library::Track
    include JtItunes::Library::Parser::Track
    include Library::MusicSelection
    alias :preview_url :location
    alias :preview_url= :location=
    alias :name :title
    alias :name= :title=
    include JtItunes::Library::Delimitable

    def translated(attr)
      case attr.to_sym
      when :name
        :title
      when :preview_url
        :location
      else
        attr.to_sym
      end
    end
  end # Track
end
