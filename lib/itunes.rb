module Itunes
end

Dir.glob("#{File.dirname(__FILE__) + '/itunes'}/*.rb").each {|f| require(f)}
