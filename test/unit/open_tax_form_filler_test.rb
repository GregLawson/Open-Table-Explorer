###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/open_tax_form_filler.rb'
class DefinitionsTest < DefaultTestCase2
include OpenTaxFormFiller::Definitions::Constants
include OpenTaxFormFiller::Definitions::Examples
include OpenTaxFormFiller
def test_CLASS_constants
	
	assert(File.exists?(Open_tax_filler_directory), Dir["#{Open_tax_filler_directory}/*"].inspect)
	assert(File.exists?(OTF_definition_filename), "File #{OTF_definition_filename} doesnot exist.")
	assert(File.exists?(Data_source_directory), Dir["#{Data_source_directory}/*"].inspect)
	assert(File.exists?(OTF_SQL_dump_filename), Dir["#{Data_source_directory}/*"].inspect)
	assert_match(/#{Symbol_pattern}/, Simple_acquisition)
	assert_match(/#{Delimiter}/, Simple_acquisition)
	assert_match(/#{Type_pattern}/, Simple_acquisition)
	assert_match(/#{Description_pattern}/, Simple_acquisition)
	assert_match(Symbol_regexp, Simple_acquisition)
	assert_match(Type_regexp, Simple_acquisition)
	assert_match(Description_regexp, Simple_acquisition)
	assert_match(Full_regexp, Simple_acquisition)
	OpenTaxFormFiller.assert_post_conditions

end #Constants
include DefaultTests2
def test_initialize
	assert_not_nil(OpenTaxFormFiller.new)
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
	OpenTaxFormFiller::assert_json_string(acquisition)
	otff=OpenTaxFormFiller.parse(acquisition)
	assert_equal({:form=>"f1040", :year=>2012, :line=>"L1", :type=>"Amount"},otff[0].attributes, otff[0].inspect)
	assert_equal([:form, :year, :line, :type],otff[0].attributes.keys, otff[0].inspect)
	assert_equal(["f1040", 2012, "L1", "Amount"],otff[0].attributes.values, otff[0].inspect)
	assert_equal('f1040',otff[0][:form])
	assert_equal(Default_tax_year,otff[0][:year])
	assert_equal('Amount', otff[0][:type])
end #parse
def test_raw_acquisitions
	all_files=Dir[OTF_definition_filenames]
	all_files.map do |filename|
		json=JSON[IO.read(filename)]
		entries=json['fields'].each_pair do |key, value|
			flat={}
			flat[:form]=json['form']
			flat[:year]=json['year']
			flat[:line]=key
			flat[:type]=value
			assert_equal([:form, :year, :line, :type], flat.keys, flat.keys.inspect)
			flat
		end #each_pair
		entries
	end.compact # map
	raw_acquisitions=OpenTaxFormFiller.raw_acquisitions
	assert_instance_of(Array, raw_acquisitions, raw_acquisitions.inspect)
	assert_instance_of(Hash, raw_acquisitions[0], raw_acquisitions[0].inspect)
	assert_equal(9, OpenTaxFormFiller.raw_acquisitions.size, raw_acquisitions.inspect)
	assert_equal([:form, :year, :line, :type], raw_acquisitions[0].keys, raw_acquisitions.inspect)
end #raw_acquisitions
def test_coarse_filter
	assert_not_empty(OpenTaxFormFiller.coarse_filter.compact, OpenTaxFormFiller.coarse_filter.inspect)
	assert_operator(84, :==, OpenTaxFormFiller.coarse_filter.size, OpenTaxFormFiller.coarse_filter.inspect)
end #coarse_filter
def test_coarse_rejections
	OpenTaxFormFiller.coarse_rejections.each do |acquisition|
		puts acquisition if Type_regexp.match(acquisition) 
		puts acquisition if Description_regexp.match(acquisition)
	end #select
	assert_operator(31, :==, OpenTaxFormFiller.coarse_rejections.size, OpenTaxFormFiller.coarse_rejections.inspect)
end #coarse_rejections
def test_all
	ret=OpenTaxFormFiller.coarse_filter.map do |r| #map
		matchData=Full_regexp.match(r)
		if matchData then
			OpenTaxFormFiller.assert_full_match(r)
			otff=OpenTaxFormFiller.parse(r, Full_regexp)
			otff[:tax_year]=Default_tax_year
		else
			nil
		end #if
	end.compact #select
	assert_not_empty(ret.compact, ret.inspect)
	assert_operator(84, :==, OpenTaxFormFiller.all.size, OpenTaxFormFiller.fine_rejections.inspect)
	OpenTaxFormFiller.all(Default_tax_year).each do |ots|
		assert_instance_of(OpenTaxFormFiller, ots)
		assert_instance_of(Hash, ots.attributes)
		assert_respond_to(ots.attributes, :values)
		assert_scope_path(:DefaultAssertions, :ClassMethods)
		assert_constant_instance_respond_to(:NoDB, :insert_sql)
		assert_include(ots.class.included_modules, NoDB)
#		assert_include(NoDB.methods, :insert_sql)
		assert_includes(OpenTaxFormFiller.methods, :insert_sql)
		explain_assert_respond_to(OpenTaxFormFiller, :insert_sql)
		assert_respond_to(OpenTaxFormFiller, :insert_sql)
		assert_instance_of(Array, ots.attributes.values)
		ots.assert_pre_conditions
		values=ots.insert_sql
	end #each
	assert_instance_of(Array, OpenTaxFormFiller.dump)
	assert_instance_of(String, OpenTaxFormFiller.dump[0])
	assert_not_equal('"', OpenTaxFormFiller.dump[0][0], OpenTaxFormFiller.dump[0][0..20])
	assert_equal("\n", OpenTaxFormFiller.dump[0][-1], OpenTaxFormFiller.dump[0][0..20])
	IO.binwrite(OTF_SQL_dump_filename, OpenTaxFormFiller.dump.join(''))
end #all
def test_fine_rejections
	OpenTaxFormFiller.fine_rejections.each do |r|
		OpenTaxFormFiller.assert_full_match(r)
	end #each
end #fine_rejections
def test_assert_json_string
	OpenTaxFormFiller::assert_json_string(Simple_acquisition)

end #assert_full_match
end #OpenTaxFormFiller
