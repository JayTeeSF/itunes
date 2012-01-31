require 'itunes'
require 'rails'
module Itunes
  class Railtie < Rails::Railtie
    railtie_name :itunes

    rake_tasks do
      load "tasks/itunes.rake"
    end
  end
end
