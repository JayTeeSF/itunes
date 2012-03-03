module JtItunes
  require 'class_helpers'
  require 'jt_itunes/railtie' if defined?(Rails)
end

Dir.glob("#{File.dirname(__FILE__) + '/jt_itunes'}/*.rb").reject{|f| f[/railtie.rb$/]}.each {|f| require(f)}
