###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative 'default_test_case.rb'
require_relative '../../app/models/open_tax_form_filler.rb'
class GenericJsonsTest < DefaultTestCase2
#include DefaultTests2
include 
def test_raw_acquisitions  #acquisition=next
	all_files=Dir[OpenTaxFormFiller::Definitions::Input_filenames]
	all=all_files.map do |filename|
		acquisition=IO.read(filename)
		OpenTaxFormFiller::Definitions.assert_json_string(acquisition)
		acquisition
	end.flatten # map no arrays by filename
	raw_acquisitions=OpenTaxFormFiller::Definitions.raw_acquisitions
	assert_instance_of(Array, raw_acquisitions, raw_acquisitions.inspect)
	assert_equal(9, OpenTaxFormFiller::Definitions.raw_acquisitions.size, raw_acquisitions.inspect)
end #raw_acquisitions
def test_coarse_filter
	assert_not_empty(OpenTaxFormFiller::Definitions.coarse_filter.compact, OpenTaxFormFiller::Definitions.coarse_filter.inspect)
	assert_operator(867, :==, OpenTaxFormFiller::Definitions.coarse_filter.size, OpenTaxFormFiller::Definitions.coarse_filter.inspect)
	assert_equal([:form, :year, :line, :type], OpenTaxFormFiller::Definitions.coarse_filter[0].keys, OpenTaxFormFiller::Definitions.coarse_filter.inspect)
	types=OpenTaxFormFiller::Definitions.coarse_filter.map do |otff|
		otff[:type]
	end.uniq #map
	assert_equal(["Amount", "Choice", "Text", "Number", "Integer", "Percent"], types)
end #coarse_filter
def test_coarse_rejections
	OpenTaxFormFiller::Definitions.coarse_rejections.each do |acquisition|
		puts acquisition if Type_regexp.match(acquisition) 
		puts acquisition if Description_regexp.match(acquisition)
	end #select
	assert_operator(0, :==, OpenTaxFormFiller::Definitions.coarse_rejections.size, OpenTaxFormFiller::Definitions.coarse_rejections.inspect)
end #coarse_rejections
def test_all_initialize
	assert_operator(867, :==, OpenTaxFormFiller::Definitions.all.size, OpenTaxFormFiller::Definitions.fine_rejections.inspect)
	OpenTaxFormFiller::Definitions.all.each do |ots|
		assert_instance_of(OpenTaxFormFiller::Definitions, ots)
		assert_instance_of(Hash, ots.attributes)
		assert_respond_to(ots.attributes, :values)
#		assert_scope_path(:DefaultAssertions, :ClassMethods)
#		assert_constant_instance_respond_to(:NoDB, :insert_sql)
		assert_include(ots.class.included_modules, NoDB)
#		assert_include(NoDB.methods, :insert_sql)
		assert_includes(OpenTaxFormFiller::Definitions.methods, :insert_sql)
#		explain_assert_respond_to(OpenTaxFormFiller::Definitions, :insert_sql)
		assert_respond_to(OpenTaxFormFiller::Definitions, :insert_sql)
		assert_instance_of(Array, ots.attributes.values)
#		ots.assert_pre_conditions
		values=ots.insert_sql
	end #each
end #all_initialize
def test_fine_rejections
	OpenTaxFormFiller::Definitions.fine_rejections.each do |r|
	end #each
end #fine_rejections
def test_assert_json_string
	OpenTaxFormFiller::Definitions::assert_json_string(OpenTaxFormFiller::Definitions::Simple_acquisition)

end #assert_json_string
end #GenericJson
class DefinitionsTest < DefaultTestCase2
include OpenTaxFormFiller::Definitions::Constants
include OpenTaxFormFiller::Definitions::Examples
include OpenTaxFormFiller
def test_CLASS_constants
	
	assert(File.exists?(Open_tax_filler_directory), Dir["#{Open_tax_filler_directory}/*"].inspect)
	assert_not_empty(Dir[Input_filenames])
	assert(File.exists?(Data_source_directory), Dir["#{Data_source_directory}/*"].inspect)
	OpenTaxFormFiller::Definitions.assert_post_conditions

end #Constants
include DefaultTests2
def model_class?
	OpenTaxFormFiller::Definitions
end #model_name?
def test_Definitions_parse
	
	hash={:year => Default_tax_year, :form => 'f1040', 'fields'=> {'L1' => "Amount"}}
	assert_instance_of(Hash, hash)
	acquisition=JSON[hash]
	puts acquisition.inspect
	assert_not_nil(acquisition)
	assert_instance_of(String, acquisition)
	json=JSON[acquisition]
	assert_instance_of(Hash, json)
	assert_include(json.keys, 'year')
	assert_include(json.keys, 'fields')
	Definitions::assert_json_string(acquisition)
	parsed=Definitions.parse(acquisition)
	assert_equal({:form=>"f1040", :year=>2012, :line=>"L1", :type=>"Amount"},parsed[0], parsed[0].inspect)
	assert_equal([:form, :year, :line, :type],parsed[0].keys, parsed[0].inspect)
	assert_equal(["f1040", 2012, "L1", "Amount"],parsed[0].values, parsed[0].inspect)
	assert_equal('f1040',parsed[0][:form])
	assert_equal(Default_tax_year, parsed[0][:year])
	assert_equal('Amount', parsed[0][:type])
end #parse
def test_dump_sql_to_file
	filename="#{Data_source_directory}/#{model_name?}_#{Default_tax_year}.sql"
	assert_equal(:Definitions, model_name?)
	model_class?.dump_sql_to_file(filename)
	assert_instance_of(Array, model_class?.dump)
	assert_instance_of(String, model_class?.dump[0])
	assert_not_equal('"', model_class?.dump[0][0], model_class?.dump[0][0..20])
	assert_equal("\n", model_class?.dump[0][-1], model_class?.dump[0][0..20])
end #dump_sql_to_file
end #Definitions
class TransformsTest < DefaultTestCase2
include OpenTaxFormFiller::Transforms::Constants
include OpenTaxFormFiller::Transforms::Examples
include OpenTaxFormFiller
def model_class?
	OpenTaxFormFiller::Transforms
end #model_name?
include DefaultTests2
def test_Transformations_parse
	model_class?.raw_acquisitions.each do |r|
		assert_equal(["form", "title", "year", "pdfSum", "fields"], JSON[r].keys)
	end #each
	hash={:year => Default_tax_year, :form => 'f1040', 'fields'=> {'L1' => "Amount"}}
	assert_instance_of(Hash, hash)
	acquisition=JSON[hash]
	puts acquisition.inspect
	assert_not_nil(acquisition)
	assert_instance_of(String, acquisition)
	json=JSON[acquisition]
	assert_instance_of(Hash, json)
	assert_include(json.keys, 'year')
	assert_include(json.keys, 'fields')
	model_class?.assert_json_string(acquisition)
	parsed=model_class?.parse(acquisition)
	assert_equal('f1040',parsed[0][:form])
	assert_equal(Default_tax_year,parsed[0][:year])
end #parse
def test_dump_sql_to_file
	filename="#{Data_source_directory}/#{model_name?}_#{Default_tax_year}.sql"
	assert_equal(:Transforms, model_name?)
	model_class?.dump_sql_to_file(filename)
end #dump_sql_to_file
end #Transforms
