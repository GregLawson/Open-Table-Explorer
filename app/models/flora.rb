###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/generic_files.rb'
require_relative '../../app/models/shell_command.rb'
module Flora
module Constants
end #Constants


class AvrDude
include NoDB
extend NoDB::ClassMethods
include GenericFiles
extend GenericFiles::ClassMethods
module Constants
include Flora::Constants
end #Constants
include Constants
def self.input_urls

	"test/data_sources/flora_dmesg.log"
end #input_input_urls
def self.full_regexp_array
	['[',"[0-9]{6,7}\.[0-9]{6,7} [usb]{3,8} [1]-[1].[2]: [a-zA-Z 0-9:]+"]
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

include Assertions
extend Assertions::ClassMethods
include DefaultAssertions::ClassMethods
#AvrDude.assert_pre_conditions
module Examples
Load=ShellCommands.new("avrdude -p m32u4 -P /dev/ttyACM0 -c avr109 main.out")
Devices=ShellCommands.new('ls -1 /dev/ttyACM*')
All=AvrDude.all_initialize
end #Examples
include Examples
end #AvrDude
end #Flora
