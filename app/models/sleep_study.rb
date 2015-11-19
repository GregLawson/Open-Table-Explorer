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
	@record_index = 0
def rewind
	@record_index = 0
	self # allows chaining
end # rewind
#def initialize(*args, &block)
#    super
#end # initialize
def each(&block)
	@record_index = 0
	loop do # infinite until StopIteration exception 
		
		block.call(self.next)
	end # begin
rescue StopIteration
end # each
def next
	if @size.nil? || @size == Float::INFINITY then # can't end
		ret = extract_record
	elsif @record_index > @rows-1 then
		raise StopIteration
	else
		ret = extract_record
	end # if
	@record_index += 1
	ret
end # next
end # FixedEnumerator

class BinaryIO < IO
include Virtus.value_object
values do
	attribute :path, String
	attribute :record_length, Fixnum
	attribute :size, Fixnum, :default => lambda { |file, attribute| File.size?(file.path) }
	attribute :rows, Fixnum, :default => lambda { |file, attribute| file.size.fdiv(file.record_length).ceil}
	attribute :record_index, Fixnum, :default => 0
end # values
include FixedEnumerator
def extract_record
		IO.binread(@path, @record_length, @record_index * @record_length)
end # extract_record
module Examples
First_line_hash = '###########################################################################'
Bin_file = BinaryIO.new(path: $0, record_length: First_line_hash.size)
Null_BinaryIO = BinaryIO.new(path: '/dev/null', record_length: 1, size: 0)
end # Examples
end # BinaryIO

class StringEnumerator
include Virtus.value_object
values do
	attribute :data, String
	attribute :record_length, Fixnum
	attribute :size, Fixnum, :default => lambda { |string, attribute| string.data.size || 0 }
	attribute :rows, Fixnum, :default => lambda { |string, attribute| string.size / string.record_length}
	attribute :record_index, Fixnum, :default => 0
end # values
include FixedEnumerator
def extract_record
		ret = @data[@record_index * @record_length, @record_length]
end # extract_record
module Examples
ABC = StringEnumerator.new(data: 'abc', record_length: 1)
end # Examples
end # StringEnumerator

# size may be undefined for ininite streams
class BinaryRecordEnumerator
include Virtus.value_object
values do
 	attribute :enumerator, Object
	attribute :format, String, :default => 'C'
end # values
include Enumerable
#include FixedEnumerator
module ClassMethods
#include Constants
def new_from_StringEnumerator(args)
	BinaryRecordEnumerator.new(enumerator: StringEnumerator.new(data: args[:string], record_length: args[:record_length]))
end # new_from_StringEnumerator
def new_from_BinaryIO(args)
	BinaryRecordEnumerator.new(enumerator: BinaryIO.new(args))
end # new_from_BinaryIO
end # ClassMethods
extend ClassMethods
def next
	@enumerator.next
end # next
def each(&block)
	@enumerator.each(&block)
end # each
def size
	if @enumerator.respond_to?(:size) then
		if @enumerator.size.nil? then
			nil # unknown or infinite
		else
			@enumerator.size
		end # if
	else
		Float::INFINITY # unknown or infinite 
	end # size
end # size
def rewind
	@enumerator.rewind
end # rewind
def slice_string(string, slice_length)
	slices =[] # accumulate here
	start_index = 0
	(string.size / slice_length).times do |i|
		slices << string[i * slice_length, slice_length]
	end # times
	slices
end # slice_string
def format_bytes_unpacked
	ret = @enumerator.extract_record.unpack(@format).size
	@enumerator.rewind
	ret
rescue
	@enumerator.rewind
	0	# end of file on first read
end # format_bytes_unpacked
def extract_record # peek do not move position
	slice_string(@enumerator.extract_record, format_bytes_unpacked).map do |record|
		record.unpack(@format)
	end # map
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
ABC_BinaryRecord = BinaryRecordEnumerator.new(enumerator: StringEnumerator.new(data: 'abc', record_length: 1))
Null_BinaryRecord = BinaryRecordEnumerator.new_from_BinaryIO(path: '/dev/null', record_length: 1, size:0)
Bin_file_BinaryRecord = BinaryRecordEnumerator.new_from_BinaryIO(path: $0, record_length: BinaryIO::Examples::First_line_hash.size)
end # Examples
end # BinaryRecordEnumerator

# include a fixed size
class BinaryTable < BinaryRecordEnumerator
include Enumerable
include Virtus.value_object
values do
 	attribute :enumerator, Object
	attribute :size, Fixnum, :default => lambda { |block, attribute| block.enumerator.size }
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

def table
	@enumerator.map do |record|
		record
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
ABC_BinaryTable = BinaryTable.new(enumerator: BinaryRecordEnumerator.new(enumerator: StringEnumerator.new(data: 'abc', record_length: 1)))
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
