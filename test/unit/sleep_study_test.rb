###########################################################################
#    Copyright (C) 2015-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/sleep_study.rb'
class FixedEnumeratorTest < TestCase
  # include DefaultTests
  # include RailsishRubyUnit::Executable.model_class?::Examples
  # include StringEnumerator::Examples
  # include BinaryIO::Examples
  def setup
    BinaryIO::Examples::Bin_file.rewind
    BinaryIO::Examples::Null_BinaryIO.rewind
    StringEnumerator::Examples::ABC.rewind
  end # setup

  def test_rewind
    assert_equal(0, StringEnumerator::Examples::ABC.record_index)
    assert_equal(0, BinaryIO::Examples::Bin_file.record_index)
    assert_equal(0, BinaryIO::Examples::Null_BinaryIO.record_index)
    assert_equal(0, StringEnumerator::Examples::ABC.rewind.record_index)
    assert_equal(0, BinaryIO::Examples::Bin_file.rewind.record_index)
    assert_equal(0, BinaryIO::Examples::Null_BinaryIO.rewind.record_index)
  end # rewind

  def test_initialize
    #	Bin_file.eof?
  end # initialize

  def test_next
    assert_equal(BinaryIO::Examples::First_line_hash, BinaryIO::Examples::Bin_file.next)
    assert_equal("\n", BinaryIO::Examples::Bin_file.next[0, 1])
    assert_equal('a', StringEnumerator::Examples::ABC.next)
    assert_equal(BinaryIO::Examples::First_line_hash, BinaryIO::Examples::Bin_file.rewind.next)
    assert_equal('', BinaryIO::Examples::Null_BinaryIO.next)
  end # next

  def test_each
    message = BinaryIO::Examples::Bin_file.inspect
    characters_in_file = 0
    BinaryIO::Examples::Bin_file.each do |c|
      refute_nil(c, message)
      characters_in_file += c.size
    end # each
    message = BinaryIO::Examples::Bin_file.inspect # update
    message += "\nextract_record = " + BinaryIO::Examples::Bin_file.extract_record.to_s
    assert_nil(BinaryIO::Examples::Bin_file.extract_record, message)
    #	message += "\nsize = " + Bin_file.extract_record.size.to_s
    assert_equal(BinaryIO::Examples::Bin_file.size, characters_in_file, message)
  end # each

  def test_next
    assert_equal(BinaryIO::Examples::First_line_hash, BinaryIO::Examples::Bin_file.next)
    assert_equal("\n", BinaryIO::Examples::Bin_file.next[0, 1])
  end # next
end # FixedEnumerator
class BinaryIOTest < TestCase
  include BinaryIO::Examples
  def setup
    Bin_file.rewind
  end # setup

  def test_BinaryRecordEnumerator
    assert_equal(First_line_hash.size, Bin_file.record_length)
    assert_instance_of(Fixnum, Bin_file.record_length)
    assert_equal(First_line_hash, Bin_file.next)
  end # values
end # BinaryIO
class StringEnumeratorTest < TestCase
  include StringEnumerator::Examples
  def setup
    ABC.rewind
  end # setup

  def test_StringEnumerator
    assert_instance_of(Fixnum, ABC.record_length)
    assert_equal(1, ABC.record_length)
    assert_equal('a', ABC.next)
  end # values

  def test_extract_record
    assert_equal('a', ABC.extract_record)
  end # extract_record
end # StringEnumerator
class BinaryRecordEnumeratorTest < TestCase
  include BinaryRecordEnumerator::Examples
  def setup
    ABC_BinaryRecord.rewind
    Bin_file_BinaryRecord.rewind
    Null_BinaryRecord.rewind
  end # setup

  def test_BinaryRecordEnumerator
    assert_equal('C', ABC_BinaryRecord.format)
    assert_equal(1, ABC_BinaryRecord.enumerator.record_length)
    assert_instance_of(Fixnum, ABC_BinaryRecord.enumerator.record_length)
    assert_equal('a', ABC_BinaryRecord.enumerator.next)

    assert_equal('b', ABC_BinaryRecord.enumerator.next)
    #	assert_equal(BinaryIO::Examples::First_line_hash, Bin_file_BinaryRecord.rewind.next)
    assert_raises(StopIteration) { Null_BinaryRecord.enumerator.next }
    assert_instance_of(StringEnumerator, ABC_BinaryRecord.enumerator)
  end # values

  def test_new_from_string
  end # new_from_StringEnumerator

  def test_new_from_IO
  end # new_from_BinaryIO

  def test_next
    #	assert_equal(BinaryIO::Examples::First_line_hash, Bin_file_BinaryRecord.rewind.next)

    refute_nil(ABC_BinaryRecord.enumerator.record_index)
    #	assert_equal('a', ABC_BinaryRecord.next)
    assert_equal([[97]], ABC_BinaryRecord.rewind.next)
    assert_equal([[98]], ABC_BinaryRecord.next)
    assert_equal([[99]], ABC_BinaryRecord.next)
    assert_raises(StopIteration) { ABC_BinaryRecord.next }
    assert_raises(StopIteration) { Null_BinaryRecord.next }
  end # next

  def test_size
    assert_equal(3, ABC_BinaryRecord.size)
    assert_instance_of(Fixnum, Bin_file_BinaryRecord.size)
    assert_equal(0, Null_BinaryRecord.size)
  end # size

  def test_slice_string
  end # slice_string

  def test_format_bytes_unpacked
    assert_equal(1, ABC_BinaryRecord.format_bytes_unpacked)
    assert_equal(1, Bin_file_BinaryRecord.format_bytes_unpacked)
    assert_equal(1, Null_BinaryRecord.format_bytes_unpacked)
  end # format_bytes_unpacked

  def test_BinaryRecordEnumerator_csv
    assert_equal("97\n", ABC_BinaryRecord.csv)
  end # csv
end # BinaryRecordEnumerator

class BinaryTableTest < TestCase
  include BinaryTable::Examples
  def test_BinaryTable
    assert_equal(4800.prime_division, [[2, 6], [3, 1], [5, 2]])
    assert_equal([[3, 1]], ABC_BinaryTable.factors)
    assert_equal('C', ABC_BinaryTable.format)
    assert_equal(3, ABC_BinaryTable.largest_factor)
    assert_equal(3, ABC_BinaryTable.rows)
    assert_instance_of(StringEnumerator, ABC_BinaryTable.enumerator)
    refute_nil(ABC_BinaryTable.enumerator.record_index)
    assert_instance_of(Fixnum, ABC_BinaryTable.enumerator.record_length)
    assert_equal(1, ABC_BinaryTable.enumerator.record_length)
    #	assert_equal('abc',ABC_BinaryTable.enumerator)
    assert_equal(3, ABC_BinaryTable.size)
    assert_equal([[97]], ABC_BinaryTable.rewind.next)
    assert_equal([[98]], ABC_BinaryTable.next)
    assert_equal([[99]], ABC_BinaryTable.next)
    assert_raises(StopIteration) { ABC_BinaryTable.next }
    assert_raises(StopIteration) { Null_BinaryTable.next }
  end # values

  def test_factors_of
  end # factors_of

  def test_table
    assert_equal(3, ABC_BinaryTable.size)
    #	assert_equal(1,ABC_BinaryTable.format_bytes_unpacked)
    assert_equal([[97]], ABC_BinaryTable.rewind.next)
    assert_equal([[98]], ABC_BinaryTable.next)
    assert_equal([[99]], ABC_BinaryTable.next)
    assert_raises(StopIteration) { ABC_BinaryTable.next }
    assert_equal([[[97]], [[98]], [[99]]], ABC_BinaryTable.rewind.table)
  end # table

  def test_BinaryTable_csv
    assert_equal(3, ABC_BinaryTable.size)
    refute(ABC_BinaryTable.rewind.enumerator.eof?, ABC_BinaryTable.enumerator.inspect)
    assert_equal([[97]], ABC_BinaryTable.rewind.next)
    assert_equal([[98]], ABC_BinaryTable.next)
    assert_equal([[99]], ABC_BinaryTable.next)
    ABC_BinaryTable.rewind
    csv_string = ''
    begin
      loop do
        csv_string += ABC_BinaryTable.next.flatten.join("\t") + "\n"
      end # loop
    rescue StopIteration
    end # loop
    assert_equal("97\n98\n99\n", csv_string, csv_string.inspect)
    assert_equal("97\n98\n99\n", ABC_BinaryTable.rewind.csv)
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
