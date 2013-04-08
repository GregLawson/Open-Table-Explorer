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
	parsed=Definitions.parse
	assert_equal({:form=>"1040sa", :year=>2012, :line=>"L1", :type=>"Amount"},parsed[0], parsed[0].inspect)
	assert_equal([:form, :year, :line, :type],parsed[0].keys, parsed[0].inspect)
	assert_equal(["1040sa", 2012, "L1", "Amount"],parsed[0].values, parsed[0].inspect)
	assert_equal('1040sa',parsed[0][:form])
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
def test_parse
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
	parsed=model_class?.parse
	assert_equal('1040',parsed[0][:form])
	assert_equal(Default_tax_year,parsed[0][:year])
end #parse
def test_dump_sql_to_file
	filename="#{Data_source_directory}/#{model_name?}_#{Default_tax_year}.sql"
	assert_equal(:Transforms, model_name?)
	model_class?.dump_sql_to_file(filename)
end #dump_sql_to_file
end #Transforms

class PjsonsTest < DefaultTestCase2
include OpenTaxFormFiller::Pjsons::Constants
include OpenTaxFormFiller::Pjsons::Examples
include OpenTaxFormFiller
def model_class?
	OpenTaxFormFiller::Pjsons
end #model_name?
include DefaultTests2
def test_parse
	model_class?.raw_acquisitions.each do |acquisition|
		assert_not_nil(acquisition)
		assert_instance_of(String, acquisition)
		model_class?.assert_parseable(acquisition, strict=false)
		model_class?.assert_parseable(acquisition, strict=true)
		hash={}
		matchDatas= Full_regexp_array.map do |rs|
			matchData=/#{rs}/.match(acquisition)
			if matchData then
				matchData.names.map do |n|
					hash[n.to_sym]=matchData[n]
				end #map
				acquisition=matchData.post_match
			end #if
		end #map
		assert_instance_of(Hash, hash)
		hash
	end.flatten #map
	parsed=model_class?.parse
	model_class?.assert_parsed
end #parse
def test_subset_regexp
	longest=Full_regexp_array.size
	Full_regexp_array.combination(longest) do |c|
		Pjsons.raw_acquisitions.map do |line|
			assert_instance_of(String, line)
			regexp=Regexp.new(c.join)
			assert_instance_of(Regexp, regexp)
			regexp.match(line)
		end #map
	end #combinations
	Full_regexp_array.map do |rs|
		/#{rs}/
	end #map
end #subset_regexp
def test_dump_sql_to_file
	filename="#{Data_source_directory}/#{model_name?}_#{Default_tax_year}.sql"
	assert_equal(:Pjsons, model_name?)
	assert_respond_to(model_class?, :dump_sql_to_file)
	model_class?.dump_sql_to_file(filename)
end #dump_sql_to_file
end #Pjsons
