###########################################################################
#    Copyright (C) 2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'virtus'
require 'prime'
#require_relative '../../app/models/no_db.rb'
module FixedEnumerator
include Enumerable
def rewind
	@record_index = 0
end # rewind
#def initialize(*args, &block)
#    super
#end # initialize
def each(&block)
	@record_index = 0
	loop do # infinite until exception 
		
		block.call(self.next)
	end # begin
rescue StopIteration
end # each
def next
	if @record_index > @rows then
		raise StopIteration
	else
		ret = extract_record
	end # if
	@record_index += 1
	ret
rescue
		raise StopIteration
end # next
end # FixedEnumerator

class BinaryIO < IO
include Virtus.value_object
values do
	attribute :path, String
	attribute :record_length, Fixnum
	attribute :size, Fixnum, :default => lambda { |file, attribute| File.size?(file.path) || 0 }
	attribute :rows, Fixnum, :default => lambda { |file, attribute| file.size / file.record_length}
	attribute :record_index, Fixnum, :default => 0
end # values
include FixedEnumerator
def extract_record
		IO.binread(@path, @record_length, @record_index * @record_length)
end # extract_record
module Examples
First_line_hash = '###########################################################################'
Bin_file = BinaryIO.new(path: $0, record_length: First_line_hash.size)
Null_BinaryIO = BinaryIO.new(path: '/dev/null', record_length: 1)
end # Examples
end # BinaryIO

class StringEnumerator
include Virtus.value_object
values do
	attribute :data, String
	attribute :record_length, Fixnum
	attribute :size, Fixnum, :default => lambda { |string, attribute| string.size || 0 }
	attribute :rows, Fixnum, :default => lambda { |string, attribute| string.size / string.record_length}
	attribute :record_index, Fixnum, :default => 0
end # values
include FixedEnumerator
def extract_record
		ret = @data[@record_index * @record_length, @record_length]
end # extract_record
module Examples
end # Examples
end # StringEnumerator

class BinaryRecordEnumerator
include Virtus.value_object
values do
 	attribute :enumerator, Object
	attribute :format, String, :default => 'C'
end # values
include Enumerable
include FixedEnumerator
def slice_string(string, slice_length)
	slices =[] # accumulate here
	start_index = 0
	(string.size / slice_length).times do |i|
		slices << string[i * slice_length, slice_length]
	end # times
	slices
end # slice_string
def format_bytes_unpacked
	@enumerator.next.unpack(@format).size
end # format_bytes_unpacked
def unpack_row
	slice_string(@enumerator.next, format_bytes_unpacked).map do |record|
		record.unpack(@format)
	end # map
end # unpack_row
def extract_record
		unpack_row
end # extract_record

def csv(path = nil)
	record = @enumerator.next
	csv_string = record.flatten.join("\t") + "/n"
	if path.nil? then
		csv_string
	else
		IO.write(path, csv_string)
	end # if
end # csv
module Examples
ABC = BinaryRecordEnumerator.new(enumerator: StringEnumerator.new(data: 'abc', record_length: 1))
end # Examples
end # BinaryRecordEnumerator

# include a fixed size
class BinaryTable
include Enumerable
include Virtus.value_object
values do
 	attribute :enumerator, Object
	attribute :size, Fixnum, :default => lambda { |block, attribute| block.size }
	attribute :factors, Array, :default => lambda { |block, attribute| (block.size == 0 || block.size.nil?? [] : block.size.prime_division) }
	attribute :format, String, :default => 'C'
	attribute :largest_factor, Fixnum, :default => lambda { |block, attribute| (block.factors.empty? ? 0 : block.factors[-1][0]) }
	attribute :rows, Fixnum, :default => lambda { |block, attribute| block.largest_factor}
	attribute :record_length, Fixnum, :default => lambda { |block, attribute| (block.rows == 0 ? 0 :block.size / block.rows) }
	attribute :record_index, Fixnum, :default => 0
end # values
module Constants # constant parameters of the type
end #Constants
include Constants
module ClassMethods
include Constants
end # ClassMethods
def factors_of(number)
  primes, powers = number.prime_division.transpose
  exponents = powers.map{|i| (0..i).to_a}
  divisors = exponents.shift.product(*exponents).map do |powers|
    primes.zip(powers).map{|prime, power| prime ** power}.inject(:*)
  end
  divisors.sort.map{|div| [div, number / div]}
end # factors_of
# there should be a ruby standard library way to do this
def slice_string(string, slice_length)
	slices =[] # accumulate here
	start_index = 0
	(string.size / slice_length).times do |i|
		slices << string[i * slice_length, slice_length]
	end # times
	slices
end # slice_string
def format_bytes_unpacked
	@enumerator.next.unpack(@format).size
end # format_bytes_unpacked
def unpack_row(row_data_string)
	slice_string(row_data_string, format_bytes_unpacked).map do |record|
		record.unpack(@format)
	end # map
end # unpack_row
def table
	@enumerator.map do |record|
		unpack_row(record)
	end # map
end # table
def csv(path = nil)
	csv_string = table.map do |record|
		record.flatten.join("\t")
	end.join("\n") # map
	if path.nil? then
		csv_string
	else
		IO.write(path, csv_string)
	end # if
end # csv
module Constants # constant objects of the type
end # Constants
include Constants
# attr_reader
require_relative 'assertions.rb'
module Assertions
module ClassMethods
def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
#	asset_nested_and_included(:ClassMethods, self)
#	asset_nested_and_included(:Constants, self)
#	asset_nested_and_included(:Assertions, self)
	self
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
	self
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
	self
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
	self
end #assert_post_conditions
end # Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include BinaryIO::Examples
ABC = BinaryTable.new(enumerator: BinaryRecordEnumerator.new(enumerator: StringEnumerator.new(data: 'abc', record_length: 1)))
end # Examples
end # BinaryTable

class SleepStudy < BinaryTable
  include Virtus.value_object
  values do
 	attribute :path, String
	attribute :file_size, Fixnum, :default => lambda { |study, attribute| File.size?(study.path) }
	attribute :enumerator, Fixnum, :default => lambda { |study, attribute| IO.binread(study.path) }
 	attribute :block, BinaryTable, :default => lambda { |study, attribute| BinaryTable.new(study.path) }
#	attribute :age, Fixnum, :default => 789
#	attribute :timestamp, Time, :default => Time.now
end # values
#extend ClassMethods
#def initialize
#end # initialize
module Examples
#include Constants
File = Pathname.new('~/Downloads/Sleep_Study/XPUJTME7589GZRD.nkamp').expand_path
end # Examples
end # SleepStudy
