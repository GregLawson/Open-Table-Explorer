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
class DefinitionsTest < DefaultTestCase2
include DefaultTests2
def model_name?
	'OpenTaxFormFiller::Definitions'.to_sym
end #model_name?
include OpenTaxFormFiller::Definitions::Constants
include OpenTaxFormFiller::Definitions::Examples
include OpenTaxFormFiller
def test_CLASS_constants
	
	assert(File.exists?(Open_tax_filler_directory), Dir["#{Open_tax_filler_directory}/*"].inspect)
	assert_not_empty(Dir[OTF_definition_filenames])
	assert(File.exists?(Data_source_directory), Dir["#{Data_source_directory}/*"].inspect)
	Definitions.assert_post_conditions

end #Constants
def test_initialize
	assert_not_nil(Definitions.new)
end #initialize
def test_parse
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
	otff=Definitions.parse(acquisition)
	assert_equal({:form=>"f1040", :year=>2012, :line=>"L1", :type=>"Amount"},otff[0].attributes, otff[0].inspect)
	assert_equal([:form, :year, :line, :type],otff[0].attributes.keys, otff[0].inspect)
	assert_equal(["f1040", 2012, "L1", "Amount"],otff[0].attributes.values, otff[0].inspect)
	assert_equal('f1040',otff[0][:form])
	assert_equal(Default_tax_year,otff[0][:year])
	assert_equal('Amount', otff[0][:type])
end #parse
def test_raw_acquisitions
	all_files=Dir[OTF_definition_filenames]
	all=all_files.map do |filename|
		json_string=IO.read(filename)
		otff=Definitions.parse(json_string)
	end.compact # map
	raw_acquisitions=Definitions.raw_acquisitions
	assert_instance_of(Array, raw_acquisitions, raw_acquisitions.inspect)
	assert_instance_of(Definitions, raw_acquisitions[0], raw_acquisitions[0].inspect)
	assert_equal(867, Definitions.raw_acquisitions.size, raw_acquisitions.inspect)
	assert_equal([:form, :year, :line, :type], raw_acquisitions[0].keys, raw_acquisitions.inspect)
	types=raw_acquisitions.map do |otff|
		otff[:type]
	end.uniq #map
	assert_equal(["Amount", "Choice", "Text", "Number", "Integer", "Percent"], types)
end #raw_acquisitions
def test_coarse_filter
	assert_not_empty(Definitions.coarse_filter.compact, Definitions.coarse_filter.inspect)
	assert_operator(867, :==, Definitions.coarse_filter.size, Definitions.coarse_filter.inspect)
end #coarse_filter
def test_coarse_rejections
	Definitions.coarse_rejections.each do |acquisition|
		puts acquisition if Type_regexp.match(acquisition) 
		puts acquisition if Description_regexp.match(acquisition)
	end #select
	assert_operator(0, :==, Definitions.coarse_rejections.size, Definitions.coarse_rejections.inspect)
end #coarse_rejections
def test_all
	assert_operator(867, :==, Definitions.all.size, Definitions.fine_rejections.inspect)
	Definitions.all(Default_tax_year).each do |ots|
		assert_instance_of(Definitions, ots)
		assert_instance_of(Hash, ots.attributes)
		assert_respond_to(ots.attributes, :values)
#		assert_scope_path(:DefaultAssertions, :ClassMethods)
#		assert_constant_instance_respond_to(:NoDB, :insert_sql)
		assert_include(ots.class.included_modules, NoDB)
#		assert_include(NoDB.methods, :insert_sql)
		assert_includes(Definitions.methods, :insert_sql)
#		explain_assert_respond_to(Definitions, :insert_sql)
		assert_respond_to(Definitions, :insert_sql)
		assert_instance_of(Array, ots.attributes.values)
#		ots.assert_pre_conditions
		values=ots.insert_sql
	end #each
	assert_instance_of(Array, Definitions.dump)
	assert_instance_of(String, Definitions.dump[0])
	assert_not_equal('"', Definitions.dump[0][0], Definitions.dump[0][0..20])
	assert_equal("\n", Definitions.dump[0][-1], Definitions.dump[0][0..20])
	IO.binwrite(OTF_SQL_dump_filename, Definitions.dump.join(''))
end #all
def test_fine_rejections
	Definitions.fine_rejections.each do |r|
	end #each
end #fine_rejections
def test_assert_json_string
	Definitions::assert_json_string(Simple_acquisition)

end #assert_full_match
end #OpenTaxFormFiller
