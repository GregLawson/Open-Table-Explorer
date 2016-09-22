###########################################################################
#    Copyright (C) 2014-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require 'descriptive-statistics'
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/ruby_lines_storage.rb'
class RubyLinesStorageTest < TestCase
	module Examples
		include RubyLinesStorage::DefinitionalConstants
		Short_array = [1,2,3]
		Long_array = Array.new(50, 1)
		Short_hash = {}
		Short_nil = nil
		Short_fixnum = 123
		Short_string = '123'
		Long_string = "cat\ndog"
		Approximate_Time = Time.now
		Short_Date = Date.today
		Approximate_DateTime = DateTime.now
		Exception_message = '(eval):17: syntax error, unexpected tSYMBEG, expecting end-of-input'
	end # Examples
	include Examples

	def eval_rescued(example_string)
		eval(example_string)
	rescue Exception => exception_raised
		raise example_string + "\n" + exception_raised.inspect
	end # eval_example
	
	def eval_name(name)
			expression_string = 'Examples::' + name.to_s
			eval_rescued(expression_string)
		rescue 
			raise 'name = ' + name.inspect + ' in expression ' + expression_string + ' should eval.'
	end # eval_name
	
	def test_read
    example_minitest_log = IO.read('./log/unit/2.2/2.2.3p173/silence/single_test_fail.rb.log')
		assert_match(/\(eval\):/ * /[0-9]+/.capture(:line), Exception_message)
		assert_match(/\(eval\):/ * /[0-9]+/.capture(:line) * /: / */.*/, Exception_message)
		assert_match(Eval_syntax_error_regexp, Exception_message)
		exception_hash = Exception_message.parse(Eval_syntax_error_regexp)
		assert_equal('17', exception_hash[:line])

    example_minitest = RubyLinesStorage.read('./log/unit/2.2/2.2.3p173/silence/single_test_fail.rb.log')
    example_testunit = RubyLinesStorage.read('./log/unit/2.2/2.2.3p173/silence/initialization_fail.rb.log')
	end # read

	def assert_reversible(object)
		ruby_lines_storage = object.ruby_lines_storage
		message = ruby_lines_storage.inspect + ' should eval to ' + object.inspect
		assert_equal(object, eval_rescued(object.ruby_lines_storage), message)
	end # assert_reversible

	def assert_lines(object)
		ruby_lines_storage = object.ruby_lines_storage
		message = ruby_lines_storage.inspect + ' should have a newline from ' + object.inspect
		assert_match(/\n/, ruby_lines_storage)
	end # assert_reversible

	def assert_approximate(numeric, max_error = 0.000000001)
		ruby_lines_storage = numeric.ruby_lines_storage
		eval_numeric = eval(ruby_lines_storage)
		round_off = numeric - eval_numeric
		message = ruby_lines_storage.inspect + ' should eval to approximately ' + numeric.inspect
		assert_operator(round_off.abs.to_f, :<=, max_error, message)
	end # assert_reversible

	def test_assert_reversible
		Examples.constants.each do |name|

			if name.to_s[0,12] == 'Approximate_'
				assert_approximate(eval_name(name), Rational(11574, 1000000000))
			else
#				assert_reversible(eval_name(name))
			end # if

		end # each
	end # assert_reversible
	
	def test_assert_lines
		Examples.constants.each do |name|
			if name.to_s[0,5] == 'Long_'
				assert_lines(eval_name(name))
			end # if
#				assert_reversible(eval_name(name))
		end # each
	end # assert_lines
	
	def test_assert_approximate
		Examples.constants.each do |name|
			if name.to_s[0,12] == 'Approximate_'
				assert_approximate(eval_name(name), Rational(11574, 1000000000))
			end # if
		end # each
	end # assert_approximate
	
	def test_Array_ruby_lines_storage
		assert_equal('[1, 2, 3]', [1,2,3].ruby_lines_storage)
		assert_match(/\n/, Long_array.ruby_lines_storage)
		assert_reversible(Short_array)
		assert_reversible(Long_array)
	end # ruby_lines_storage

	def test_Hash_ruby_lines_storage
#		assert_equal('{}', {}.ruby_lines_storage)
		assert_reversible(Short_hash)
	end # ruby_lines_storage
	
	def test_NilClass_ruby_lines_storage
		assert_equal('nil', nil.ruby_lines_storage)
		assert_reversible(nil)
	end # ruby_lines_storage

	def test_Fixnum_ruby_lines_storage
		assert_equal('123', 123.ruby_lines_storage)
		assert_reversible(123)
	end # ruby_lines_storage

	def test_String_ruby_lines_storage
		assert_equal("'cat'", 'cat'.ruby_lines_storage)
		assert_equal("'cat\ndog'", "cat\ndog".ruby_lines_storage)
		refute_equal("'cat\ndog'".inspect, "cat\ndog".ruby_lines_storage)
		assert_reversible('12\'3')
	end # ruby_lines_storage

	def test_Symbol_ruby_lines_storage
		assert_equal(':cat', :cat.ruby_lines_storage)
		assert_reversible(:cat)
		assert_reversible(:"cat\ndog")
		assert_equal(':"cat\\ndog"', :"cat\ndog".ruby_lines_storage)
	end # ruby_lines_storage
	
	def test_Date_ruby_lines_storage
		time = Date.today
		assert_reversible(time)
	end # ruby_lines_storage
	
require 'prime'	
	def test_DateTime_ruby_lines_storage
		samples = (1..120000).map do |i|
			time = DateTime.now
		end # map
		errors = samples.map do |time|
			((time - eval(time.ruby_lines_storage)) * 1000000000).to_i
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
		assert_operator(11574, :>=, errors.max, errors.inspect)
		assert_equal([[2, 1], [3, 2], [643, 1]], 11574.prime_division)
		assert_equal(11574, "2D36".to_i(16), "%02X" % 11574) # not a simple truncation!
		assert_approximate(DateTime.now, Rational(11574, 1000000000))
	end # ruby_lines_storage
	
	def test_Time_ruby_lines_storage
		time = Time.now
		seconds = Rational(1000000000 * time.sec + time.nsec, 1000000000)
		assert_instance_of(Rational, seconds)
		refute_equal(0, seconds)
		eval_time = eval(time.ruby_lines_storage)
		round_off = time - eval_time
		assert_equal(time, eval_time, time.strftime('%Y-%m-%d %H:%M:%S.%9N %z') + time.ruby_lines_storage + round_off.to_f.to_s)
		assert_reversible(time)
	end # ruby_lines_storage
	
	def test_Object_ruby_lines_storage
		assert_equal('[1, 2, 3]', [1,2,3].ruby_lines_storage)
		assert_equal(['1', '2', '3'], [1,2,3].map {|e| e.ruby_lines_storage})
		assert_equal([1, 1, 1], [1,2,3].map {|e| e.ruby_lines_storage.size})
		assert_equal(['1', '2', '3'], [1,2,3].map(&:ruby_lines_storage))
		assert_equal([1, 1, 1], [1,2,3].map(&:ruby_lines_storage).map(&:size))
	end # ruby_lines_storage
end # RubyLinesStorage
