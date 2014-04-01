###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/no_db.rb'
require_relative '../../test/assertions/regexp_parse_assertions.rb'
require_relative '../../app/models/regexp_match.rb'
module GenericFiles
include NoDB
extend NoDB::ClassMethods
module ClassMethods
include NoDB::ClassMethods
# use for filenaming
def table_name?
	self.class.name.tableize
end #model_name?
def raw_acquisitions #acquisition=next
	all_files=Dir[input_file_names]
	all_files.map do |filename|
		IO.read(filename)
	end.flatten # map no arrays by filename
end #raw_acquisitions
#return Array of class
def all_initialize
	parse.map do |hash|
#		model_class?.new(parse(hash), [String, Fixnum, String, String])
		new(hash, [String, Fixnum, String, String])
	end #map
end #all_initialize
def dump_sql_to_file(filename="#{Data_source_directory}/#{self.name}_#{Default_tax_year}.sql")
		IO.binwrite(filename, dump.join(''))
end #dump_sql_to_file
end #ClassMethods
extend ClassMethods
module Constants
Symbol_pattern='^ ?([-A-Za-z0-9?]+)'
Symbol_regexp=/#{Symbol_pattern}/
end #Constants
module Assertions
include Minitest::Assertions
module ClassMethods
include Minitest::Assertions
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions
		assert_instance_of(Hash, self.attributes)
		assert_respond_to(self.attributes, :values)
		assert_constant_instance_respond_to(:NoDB, :insert_sql)
		assert_include(self.class.included_modules, NoDB)
#		assert_include(NoDB.methods, :insert_sql)
		assert_instance_of(Array, attributes.values)
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
end #Examples
end #GenericFiles

module GenericJsons
include GenericFiles
module ClassMethods
include GenericFiles::ClassMethods
#return Array of Hash
def coarse_filter
	raw_acquisitions.map do |r|
		parse(r)
	end.flatten #json reshaping
end #coarse_filter
def coarse_rejections
	[]
end #coarse_rejections
def fine_rejections
	[]
end #fine_rejections
end #ClassMethods
extend ClassMethods
module Constants
end #Constants
module Assertions
include Minitest::Assertions
module ClassMethods
include Minitest::Assertions
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
def assert_json_string(acquisition)
	assert_not_nil(acquisition)
	assert_instance_of(String, acquisition)
	json=JSON[acquisition]
	assert_instance_of(Hash, json)
end #assert_json_string
end #ClassMethods
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
end #Examples
end #GenericJson

