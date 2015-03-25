###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/generic_file.rb'
require_relative '../../app/models/no_db.rb'
module OpenTaxFormFiller
module Constants
Default_tax_year=2012
Data_source_directory='test/data_sources/open_tax_form_filler/'
end #Constants

class Definitions
include NoDB
extend NoDB::ClassMethods
include GenericJsons
extend GenericJsons::ClassMethods
include GenericJsons::Assertions
extend GenericJsons::Assertions::ClassMethods
module Constants
include OpenTaxFormFiller::Constants
Open_tax_filler_directory="../OpenTaxFormFiller/#{Default_tax_year}"
Input_filenames="#{Open_tax_filler_directory}/definition/Federal/f*.json"
OTF_SQL_dump_filename="#{Data_source_directory}/OTF_SQL_dump_#{Default_tax_year}.sql"
end #Constants
include Constants
def self.input_file_names
	Input_filenames
end #input_file_names
def table_name?
	'Definitions'
end #model_name?
# returns array of hashes
def self.parse
	raw_acquisitions.map do |acquisition|
		json=JSON[acquisition]
		entries=[]
		json['fields'].each_pair do |key, value|
			flat={}
			flat[:form]=json['form']
			flat[:year]=json['year']
			flat[:line]=key
			flat[:type]=value
			entries.push(flat)
		end #each_pair
		entries
	end.flatten #map
end #parse
def self.all
	All
end #all
module Examples
Simple_acquisition="{\"year\":2012,\"form\":\"f1040\",\"fields\":[{}]}"
All=Definitions.all_initialize


end #Examples
#require_relative '../../test/assertions/default_assertions.rb'

include Examples
end #Definitions

class Transforms
include NoDB
extend NoDB::ClassMethods
include GenericJsons
extend GenericJsons::ClassMethods
module Constants
include OpenTaxFormFiller::Constants
Open_tax_filler_directory="../OpenTaxFormFiller/#{Default_tax_year}"
Input_filenames="#{Open_tax_filler_directory}/transform/Federal/f*.json"
Data_source_directory='test/data_sources'
OTF_SQL_dump_filename="#{Data_source_directory}/OTF_SQL_dump_#{Default_tax_year}.sql"
Symbol_pattern='^ ?([-A-Za-z0-9?]+)'
Symbol_regexp=/#{Symbol_pattern}/
end #Constants
include Constants
def self.input_file_names
	Input_filenames
end #input_file_names
# returns array of hashes
def self.parse 
	coarse= raw_acquisitions.map do |acquisition|
		json=JSON[acquisition]
		entries=[]
		json['fields'].each_pair do |key, value|
			flat={}
			flat[:form]=json['form']
			flat[:title]=json['title']
			flat[:year]=json['year']
			flat[:pdfSum]=json['pdfSum']
			flat[:line]=key
			flat[:type]=value
			entries.push(flat)
		end #each_pair
		entries
	end.flatten #map
end #parse
def self.all
	All
end #all
module Examples
Simple_acquisition="{\"year\":2012,\"form\":\"f1040\",\"fields\":[{}]}"

All=Transforms.all_initialize
end #Examples
include Examples
end #Transforms

class Pjsons
include NoDB
extend NoDB::ClassMethods
include GenericFiles
extend GenericFiles::ClassMethods
include GenericFiles::Assertions
extend GenericFiles::Assertions::ClassMethods
module Constants
include OpenTaxFormFiller::Constants
Open_tax_filler_directory="../OpenTaxFormFiller/#{Default_tax_year}"
Data_source_directory='test/data_sources'
Record_separator='},\n'
Field_name_regexp='"F(?<field_number>[0-9a-f]+)":{\n'
Start_regexp='"fdf":"(?<form_type>topmostSubform|form1)\[0\].Page(?<page>1|2)\[0\]\.'
Path_regexp='(?<path>[A-Za-z]+\.){0,3}'
Last_field_regexp='(?<field_designator>p[0-9]-t?[0-9]+|f[0-9]+[_-][0-9]+)\[0'
End_regexp='\]",\n\"type\":\"text\"\n},'
Full_regexp_array=[Field_name_regexp, Start_regexp, Path_regexp, Last_field_regexp, End_regexp]
end #Constants
include Constants
def self.input_file_names

	file_regexp="#{Open_tax_filler_directory}/field_dump/Federal/f*.pjson"
end #input_file_names
def self.full_regexp_array
	Full_regexp_array
end #full_regexp_array
# returns array of hashes
def self.parse 
	array_of_hashes=[]
	sequence_number=0
	raw_acquisitions.map do |acquisition|
		begin
		hash={}
		regexp=Regexp.new(Full_regexp_array.join)
		matchData=regexp.match(acquisition)
		if matchData then
			matchData.names.map do |n|
				hash[n.to_sym]=matchData[n]
			end #map
			acquisition=matchData.post_match
		else
			acquisition=nil
		end #if
		array_of_hashes.push(hash)
		end until (acquisition.nil?) | (acquisition.empty?) | (acquisition.size==0)
		array_of_hashes
	end.flatten #map
end #parse
def self.all
	All
end #all
# array of indices  to match
# nil value means need insertion of any characters
def self.match_regexp_array(combination_indices, acquisition)
	rest=acquisition
	regexp_string=Full_regexp_array[combination_indices[0]]
	combination_indices.each_cons(2) do |pair|
		if pair[0]+1==pair[1] then # consecutive match
			added_regexp=Full_regexp_array[pair[1]]
		else #mismatch deleted
			added_regexp="(?<error_#{pair[0]}>.*)"
		end #if
		regexp_string+=added_regexp
	end #each_cons
	regexp=Regexp.new(regexp_string)
	matchData=regexp.match(acquisition)
end #match_regexp_array
def self.leftmost_match(regexp_array, acquisition)
	[0..regexp_array.size-1].times.find do |i|
		match_regexp_array(regexp_array[0..i], acquisition)
	end #find
end #leftmost_match
def self.reverse_array_match(regexp_array, acquisition)
	Array.new(regexp_array.size){|i| regexp_array.size-i}.find do |i|
		match_regexp_array(regexp_array[i..-1], acquisition)
	end #find
end #reverse_array_match
def self.subset_regexp(size)
	longest=Full_regexp_array.size
	Full_regexp_array.combination(longest) do |c|
		raw_acquisitions.map do |line|
			Regexp.new(c.join).match(line)
		end #map
	end #combinations
	Full_regexp_array.map do |rs|
		/#{rs}/
	end #map
end #subset_regexp
def self.coarse_filter
	raw_acquisitions.select do |acquisition|
		Full_regexp_array.first do |rs|
			/#{rs}/.match(acquisition)
		end #first
	end #select
end #coarse_filter

include Assertions
extend Assertions::ClassMethods
#Pjsons.assert_pre_conditions
module Examples
Simple_acquisition="{\"year\":2012,\"form\":\"f1040\",\"fields\":[{}]}"

All=Pjsons.all_initialize
end #Examples
include Examples
end #Pjsons
end #OpenTaxFormFiller
