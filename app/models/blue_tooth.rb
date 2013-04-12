###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../test/assertions/open_tax_form_filler_assertions.rb'
module BlueTooth
module Constants
end #Constants


class BluezTestDeviceList
include NoDB
extend NoDB::ClassMethods
include GenericFiles
extend GenericFiles::ClassMethods
module Constants
include BlueTooth::Constants
Full_regexp_array=[Field_name_regexp, Start_regexp, Path_regexp, Last_field_regexp, End_regexp]
end #Constants
include Constants
def self.input_urls

	"shell:bluez-test-device list"
end #input_input_urls
def self.full_regexp_array
	Full_regexp_array
end #full_regexp_array
# returns array of hashes
def self.parse 
	array_of_hashes=[]
	coarse= raw_acquisitions.map do |acquisition, id|
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
		array_of_hashes << hash
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
BluezTestDeviceList.assert_pre_conditions
module Examples
Simple_acquisition="{\"year\":2012,\"form\":\"f1040\",\"fields\":[{}]}"

All=BluezTestDeviceList.all_initialize
end #Examples
include Examples
end #BluezTestDeviceList
end #BlueTooth
