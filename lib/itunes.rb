module Itunes
  require 'class_helpers'
  require 'itunes/railtie' if defined?(Rails)
end

Dir.glob("#{File.dirname(__FILE__) + '/itunes'}/*.rb").reject{|f| f[/railtie.rb$/]}.each {|f| require(f)}
