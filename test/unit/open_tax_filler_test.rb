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
#	puts acquisition.inspect
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
#	puts acquisition.inspect
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
def test_input_file_names
	file_regexp="#{Open_tax_filler_directory}/field_dump/Federal/f*.pjson"
	regexp=RegexpParse.new(file_regexp)
	regexp.to_pathname_glob
	assert_equal('*', regexp.to_pathname_glob)
end #input_file_names
def test_parse
	context={}
	array_of_hashes=[]
	model_class?.raw_acquisitions.each_with_index do |acquisition|
		begin
		assert_not_nil(acquisition)
		assert(!(acquisition.nil?), "acquisition should not be nil at start of parse")
		assert(!(acquisition.size==0), "acquisition should not have a size of zero at start of parse")
		assert(!(acquisition.empty?), "acquisition should not be empty at start of parse")
		assert_instance_of(String, acquisition)
		model_class?.assert_match_regexp_array(acquisition)
		hash={}
		longest=Full_regexp_array.size
		
		regexp=Regexp.new(Full_regexp_array.join)
		assert_instance_of(Regexp, regexp)
		matchData=regexp.match(acquisition)
		if matchData then
			matchData.names.map do |n|
				hash[n.to_sym]=matchData[n]
			end #map
			acquisition=matchData.post_match
			assert(!(acquisition.nil?), "acquisition should not be nil after match")
#ok at end			assert(!(acquisition.size==0), "acquisition should not have a size of zero after match")
#ok at end			assert(!(acquisition.empty?), "acquisition should not be empty after match")
		else
			acquisition=nil
			assert(acquisition.nil? | acquisition.empty? | acquisition.size==0)
		end #if
		assert_instance_of(Hash, hash)
		array_of_hashes << hash.merge(context)
#		puts hash.inspect
#		puts "'#{acquisition}', length=#{acquisition.size}"
		end until (acquisition.nil?) | (acquisition.empty?) | (acquisition.size==0)
		assert((acquisition.nil?) | (acquisition.empty?) | (acquisition.size==0))
		array_of_hashes
	end.flatten #map
	assert_operator(array_of_hashes.size, :>, model_class?.raw_acquisitions.size)
	assert_array_of(array_of_hashes, Hash) #flatten array
	parsed=model_class?.parse
	assert_array_of(parsed, Hash) #flatten array
	model_class?.assert_parsed
	assert_operator(parsed.size, :>=, 2080)
	assert_operator(parsed.uniq.size, :>=, 414)
	assert_no_duplicates(array_of_hashes)
	assert_no_duplicates(parsed)
	assert_equal(parsed.uniq.size, raw_acquisitions.size/4, "parse should be one quarter of raw_acquisitions.")
	assert_equal(parsed.uniq.size, parsed.size, "parse produces duplicates.")
	assert_equal(array_of_hashes.uniq.size, array_of_hashes.size, "array_of_hashes produces duplicates.")
	assert_equal(array_of_hashes.size, 2080)
end #parse
def test_match_regexp_array
	acquisition=model_class?.raw_acquisitions[0]
	rest=acquisition
	combination_indices=[0, 1, 2] #passes
	combination_indices=[0, 1, 2, 4] #passes
	combination_indices=[0, 1, 2, 3] #fails
	regexp_string=Full_regexp_array[combination_indices[0]]
	assert_match(/#{regexp_string}/, acquisition)
	combination_indices.each_cons(2) do |pair|
		if pair[0]+1==pair[1] then # consecutive match
			added_regexp=Full_regexp_array[pair[1]]
		else #mismatch deleted
			added_regexp="(?<error_#{pair[0]}>.*)"
		end #if
		regexp_string+=added_regexp
		if matchData=/#{regexp_string}/.match(acquisition) then
			rest=matchData.post_match
		else
			message="regexp_string=/#{regexp_string}/ did not match acquisition"
			message+="\n#{acquisition[0..100]}"
			message="\npair=/#{pair}" 
			message+="\nadding /#{added_regexp}/ did not match '#{rest[0..100]}'"
			raise message
		end #if
	end #each_cons
	regexp=Regexp.new(regexp_string)
	assert_match(/#{regexp_string}/, acquisition)
	matchData=regexp.match(acquisition)
	assert_not_nil(matchData)
	acquisition=matchData.post_match
	assert(matchData=model_class?.match_regexp_array(combination_indices, acquisition))
	acquisition=matchData.post_match
	model_class?.assert_match_regexp_array(acquisition,combination_indices)
end #match_regexp_array
def test_subset_regexp
	model_class?.raw_acquisitions.map do |acquisition|
		assert_instance_of(String, acquisition)
		longest=Full_regexp_array.size
		Array.new(Full_regexp_array.size){|i| i}.combination(longest) do |c|
			matchData=model_class?.match_regexp_array(c, acquisition)
			if matchData then
				acquisition=matchData.post_match
			end #if
		end #combinations
		hash
	end.flatten #map
end #subset_regexp
def test_dump_sql_to_file
	filename="#{Data_source_directory}/#{model_name?}_#{Default_tax_year}.sql"
	assert_equal(:Pjsons, model_name?)
	assert_respond_to(model_class?, :dump_sql_to_file)
	model_class?.dump_sql_to_file(filename)
end #dump_sql_to_file
end #Pjsons
