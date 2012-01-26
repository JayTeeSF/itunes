 # input_filename = Rails.root + 'features/iTunes Sample.xml'
 # Itunes::Library::Parser.parse_local(input_filename)

module Itunes
  SEPARATOR = "\t"
end
Dir.glob("#{File.dirname(__FILE__) + '/itunes'}/*.rb").each {|f| require(f)}
