############################################################################
#    Copyright (C) 2010 by Greg Lawson   #
#    GregLawson@gmail.com   #
#                                                                          #
#    This program is free software; you can redistribute it and#or modify  #
#    it under the terms of the GNU General Public License as published by  #
#    the Free Software Foundation; either version 2 of the License, or     #
#    (at your option) any later version.                                   #
#                                                                          #
#    This program is distributed in the hope that it will be useful,       #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#    GNU General Public License for more details.                          #
#                                                                          #
#    You should have received a copy of the GNU General Public License     #
#    along with this program; if not, write to the                         #
#    Free Software Foundation, Inc.,                                       #
#    59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             #
############################################################################
require 'test/unit'
require 'columns.rb'
class Test_Columns <Test::Unit::TestCase
def pattern2type?(example,expectedClass)
	expectedTypeRecord=Generic_Types.find(:first,:conditions => { :import_class => expectedClass.name })
	expectedPattern=expectedTypeRecord.data_regexp
	matchedTypeRecord=Import_Column.firstMatch(example)
	matchedPattern=matchedTypeRecord.data_regexp.inspect
	if matchedTypeRecord.search_sequence > expectedTypeRecord.search_sequence then
		order="after (#{matchedTypeRecord.search_sequence}>#{expectedTypeRecord.search_sequence})"
	else
		order="before (#{matchedTypeRecord.search_sequence}<#{expectedTypeRecord.search_sequence})"
	end
	example =~ Regexp.new(expectedPattern) # without ^$ anchors
	doesMatch=$~.to_s # matched string
	message="Import string #{example.inspect} matched pattern #{matchedPattern} #{order} pattern /^#{expectedPattern}$/. An unanchored match matches #{doesMatch.inspect}."
	assert_equal(expectedClass,matchedTypeRecord.import_class,message)
	#Example_Types.create(:import_class => expectedClass.name, :example_string => example)
end
def test_regexp
# @matchPos=(importString =~ Regexp.new()
	puts "Import_Column.firstMatch('').inspect=#{Import_Column.firstMatch('').inspect}" if $DEBUG
	puts "Import_Column.firstMatch('').import_class=#{Import_Column.firstMatch('').import_class}" if $DEBUG
	pattern2type?('',NULL_Column)
	Example_Types.all.each do |example|
		puts "example.inspect=#{example.inspect}" if $DEBUG
		pattern2type?(example.example_string,example.import_class)
	end
end # def
def test_ruby_class
	assert_kind_of(12.34.class,Float_Column.new('12.34').to_f)
	assert_equal(12.34,Float_Column.new('12.34').to_f)
	assert_kind_of(1234.class,Integer_Column.new('1234').to_i)
	assert_equal(1234,Integer_Column.new('1234').to_i)
	assert_kind_of(IPAddr.new('1.2.3.4').class,Inet_Column.new('1.2.3.4').value)
	puts "IPAddr.new('1.2.3.4')=#{IPAddr.new('1.2.3.4')}" if $DEBUG
	puts "Inet_Column.new('1.2.3.4').value=#{Inet_Column.new('1.2.3.4').value}"  if $DEBUG
	assert_raise(ArgumentError) {Inet_Column.new('12.34')} # wrong format
	assert_equal(IPAddr.new('1.2.3.4'),Inet_Column.new('1.2.3.4').value)
	assert_equal(Time.parse('Dec 21,1953 12:34PM"'),Time_Column.new('Dec 21,1953 12:34PM').value)
#	assert_kind_of(false.class,Boolean_Column.new('false'))
end
def test_ruby2string
	Example_Types.all.each do |example|
		puts "example.inspect=#{example.inspect}" if $DEBUG
		str=example.example_string # variable used in expressions
		exampleTypeRecord=Generic_Types.find(:first,:conditions => { :import_class => example.import_class.name })
		typedValue=example.import_class.new(example.example_string)
		puts "typedValue.to_s=#{typedValue.to_s}" if $DEBUG
		puts "typedValue.to_s.class=#{typedValue.to_s.class}" if $DEBUG
		assert_instance_of(String,typedValue.to_s) if $DEBUG
	end # each example
end # def	
def test_round_trip_conversions
	Example_Types.all.each do |example|
		puts "example.inspect=#{example.inspect}" if $DEBUG
		 
		exampleTypeRecord=Generic_Types.find(:first,:conditions => { :import_class => example.import_class.name })
		typedValue=example.import_class.new(example.example_string)
		puts "typedValue.to_s=#{typedValue.to_s}" if $DEBUG
		puts "example.inspect_value=#{example.inspect_value}" if $DEBUG
		puts "typedValue.to_s.class=#{typedValue.to_s.class}" if $DEBUG
		puts "example.inspect_value.class=#{example.inspect_value.class}" if $DEBUG
		assert_equal(example.inspect_value,typedValue.to_s)
	end # each example

end #def
def test_canonical_form
	tc=(Time_Column.new('Dec 21,1953 12:34PM'))
	tc.typedSet('Dec 21,1953 12:34PM')
	assert_not_equal(tc.value,'Dec 21,1953 12:34PM')
	tc.set('Dec 21,1953 12:34PM')
	assert_not_equal(tc.value,'Dec 21,1953 12:34PM')
	assert_equal(Time_Column.new('Dec 21,1953 12:34PM').value,Time_Column.new('12/21/1953 12:34PM').value)
	assert_equal(Timestamp_Column.new('Dec 21,1953 12:34PM').value,Timestamp_Column.new('12/21/1953 12:34PM').value)
end
end # class
#Generic_Types.sample