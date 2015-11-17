###########################################################################
#    Copyright (C) 2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/sleep_study.rb'
class BinaryTableTest < TestCase
#include DefaultTests
#include Unit::Executable.model_class?::Examples
include BinaryIO::Examples
include BinaryTable::Examples
def setup
	Bin_file.rewind
end # setup
def test_initialize
#	Bin_file.eof?
end # initialize
def test_next
	assert_equal(First_line_hash, Bin_file.next)
	assert_equal("\n", Bin_file.next[0, 1])
end # next
def test_each
	characters_in_file = 0
	Bin_file.each do |c|
		characters_in_file += c.size
	end # each
	assert_equal(Bin_file.size, characters_in_file)
end # each
include BinaryTable::Examples
def test_factors_of
def test_slice_string
def test_BinaryRecordEnumerator
	assert_equal('C',ABC.format)
	assert_equal(1,ABC.record_length)
	assert_instance_of(Fixnum,ABC.record_length)
	assert_equal('a',ABC.enumerator.next)
end # values
end # slice_string
def test_format_bytes_unpacked
	assert_equal(1,ABC.format_bytes_unpacked)
end # format_bytes_unpacked
def test_unpack_row
end # unpack_row
def test_BinaryTable
#	assert_equal('abc',ABC.enumerator)
	assert_equal(3,ABC.size)
	assert_equal(4800.prime_division, [[2, 6], [3, 1], [5, 2]])
	assert_equal([[3,1]],ABC.factors)
	assert_equal('C',ABC.format)
	assert_equal(3,ABC.largest_factor)
	assert_equal(3,ABC.rows)
	assert_equal(1,ABC.record_length)
	assert_instance_of(Fixnum,ABC.record_length)
end # values
end # factors_of
# @see http://ruby-doc.org/core-1.9.3/Enumerator.html
def test_readme
def each_to_a(enumerator, &block)
	array = []
	begin
		array << enumerator.each(&block).next
	end # loop
rescue StopIteration
	array
end # each_to_a
def ext_each(e)
  while true
    begin
      vs = e.next_values
    rescue StopIteration
      return $!.result
    end
    y = yield(*vs)
    e.feed y
  end
end

o = Object.new

def o.each(&block)
  puts yield
  puts yield(1)
  puts yield(1, 2)
  3
end
#	enumerator = o.each
#	assert_instance_of(Enumerator, enumerator)
	internal_array = each_to_a(o) {|*x| x; [:b, *x] }
	answer = [[], [:b], [1], [:b, 1], [1, 2], [:b, 1, 2], 3]
#	assert_instance_of(Enumerator, enumerator)
# use o.each as an internal iterator directly.
#assert_equal(internal_array, answer)

# convert o.each to an external iterator for
# implementing an internal iterator.
	external_array = each_to_a(o) {|*x| x; [:b, *x] }
#	assert_equal(ext_each(o.to_enum) {|*x| x; [:b, *x] }, answer)
end # readme
def test_table
	assert_equal([[[97]], [[98]], [[99]]],ABC.table)
end # table
def test_csv
	assert_equal("97\n98\n99", ABC.csv)
end # csv
def test_Examples
	array_BinaryTable = BinaryTable.new(enumerator: [1, 2, 3])
	code_BinaryTable = BinaryTable.new(enumerator: Bin_file)
	null_BinaryTable = BinaryTable.new(enumerator: Null_BinaryIO)
end # Examples
end # BinaryTable
class SleepStudyTest < TestCase
def test_Examples
	path = Pathname.new(SleepStudy::Examples::File).expand_path
	data = IO.binread(path)
	puts 'data size = ' + data.size.to_s
	factors = data.size.prime_division
	puts 'factors = ' + factors.inspect
	assert_operator(factors.size, :>, 1, factors)
	largest_factor = factors[-1][0]
	records = largest_factor
	record_length = data.size / records
	word_size = 1
#	sleep_study = SleepStudy.new(path: SleepStudy::Examples::File)
end # Examples
end # SleepStudy