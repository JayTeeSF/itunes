require 'jt_itunes'
require 'rails'
module JtItunes
  class Railtie < Rails::Railtie
    railtie_name :jt_itunes

    rake_tasks do
      load "tasks/jt_itunes.rake"
    end
  end
end
