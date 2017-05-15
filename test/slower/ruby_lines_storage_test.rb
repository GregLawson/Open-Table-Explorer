###########################################################################
#    Copyright (C) 2014-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# require 'descriptive-statistics'
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/ruby_lines_storage.rb'

module RubyLinesStorage
  require_relative '../assertions/ruby_lines_storage_assertions.rb'
end # RubyLinesStorage

class RubyLinesStorageTest < TestCase
  module Examples
    include RubyLinesStorage::DefinitionalConstants
    Short_array = [1, 2, 3].freeze
    Long_array = Array.new(50, 1)
    Empty_hash = {}.freeze
    Short_hash = { a: 1, b: 2 }.freeze
    Short_nil = nil
    Short_fixnum = 123
    Short_string = '123'.freeze
    Long_string = "cat\ndog".freeze
    Approximate_Time = Time.now
    Short_Date = Date.today
    Approximate_DateTime = DateTime.now
    Exception_message = '(eval):17: syntax error, unexpected tSYMBEG, expecting end-of-input'.freeze
  end # Examples
  include Examples

  def eval_rescued(example_string)
    eval(example_string)
  rescue Exception => exception_raised
    raise 'example_string.inspect = ' + example_string.inspect + "\n" + exception_raised.inspect
  end # eval_example

  require 'prime'
  def test_DateTime_ruby_lines_storage
    samples = (1..120_000).map do |_i|
      time = DateTime.now
    end # map
    errors = samples.map do |time|
      ((time - eval(time.ruby_lines_storage)) * 1_000_000_000).to_i
    end # map
    differences = errors.each_cons(2).map do |pair|
      pair[0] - pair[1]
    end.sort.uniq # each_cons
    #		puts 'errors = ' + errors.inspect
    puts differences.inspect
    #		message = 'mean = ' + samples.mean.to_f.to_s + 'mode = ' + samples.mode.to_f.to_s
    #		puts message
    message = 'min = ' + errors.min.to_f.to_s + 'max = ' + errors.max.to_f.to_s
    puts message
    assert_operator(0, :<=, errors.min, errors.inspect)
    assert_operator(11_574, :>=, errors.max, errors.inspect)
    assert_equal([[2, 1], [3, 2], [643, 1]], 11_574.prime_division)
    assert_equal(11_574, '2D36'.to_i(16), '%02X' % 11_574) # not a simple truncation!
  end # DateTime

end # RubyLinesStorage
