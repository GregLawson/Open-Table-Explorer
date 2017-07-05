###########################################################################
#    Copyright (C) 2014-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/ruby_lines_storage.rb'
class SyntaxErrorTest < TestCase
	include SyntaxError::DefinitionalConstants
	module Examples
    Exception_message = '(eval):17: syntax error, unexpected tSYMBEG, expecting end-of-input'.freeze
		Exception_constructor_message = 'This is an example error message.'
		Start_exception = SyntaxError.new(Exception_constructor_message)
		Unexpected_end_of_input = SyntaxError.rescued_eval('1+')
		Unexpected_close_bracket = SyntaxError.rescued_eval('[,2]')
		Unexpected_close_bracket_message = "(eval):1: syntax error, unexpected ',', expecting ']'"
	end # Examples
	include Examples
	
	def test_Examples
		assert_instance_of(SyntaxError, Start_exception)
		assert_instance_of(SyntaxError, Unexpected_end_of_input)
		assert_instance_of(SyntaxError, Unexpected_close_bracket)
		assert_equal(Unexpected_close_bracket_message, Unexpected_close_bracket.message)
	end # Examples
  def test_SyntaxError_DefinitionalConstants
    assert_match(Eval_error_regexp, Exception_message)
    assert_match(Syntax_error_regexp, Exception_message)
    assert_match(Unexpected_regexp, Exception_message)
    assert_match(/expecting /, Exception_message)
    assert_match(/[[:graph:]]+/.capture(:expecting), Exception_message)
    assert_match(/expecting / * /[[:graph:]]+/.capture(:expecting), Exception_message)
    assert_match(Expecting_regexp, Exception_message)
    assert_match(Eval_syntax_error_regexp, Exception_message)
    exception_hash = Exception_message.parse(Eval_syntax_error_regexp)
    assert_equal('17', exception_hash[:line])
		assert_equal([:line, :class_words, :unexpected, :expecting, :context, :position], exception_hash.keys, exception_hash.inspect)
		assert_match(Unexpected_regexp, Unexpected_end_of_input.message)
		assert_match(Unexpected_regexp, Unexpected_close_bracket.message)
		assert_match(Expecting_regexp, Unexpected_close_bracket.message)
		refute_match(Expecting_regexp, Unexpected_end_of_input.message)
  end # DefinitionalConstants

	def test_rescued_eval
		assert_equal(2, SyntaxError.rescued_eval('2') )
		assert_instance_of(SyntaxError, SyntaxError.rescued_eval("'") )
	end # rescued_eval

	def test_capture
		Unexpected_end_of_input.capture.assert_refinement(:exact)
		Unexpected_close_bracket.capture.assert_refinement(:exact)
		Start_exception.capture.assert_refinement(:scattered)
	end # capture
	
	def test_message_refinement
		Unexpected_close_bracket.message_refinement.assert_match_kind(:exact, Unexpected_close_bracket.message)
		Start_exception.message_refinement.assert_match_kind(:no_matches, Start_exception.message)
	end # message_refinement
	
	def test_exception_hash
			unique_exception_hashes = Eval.errors_seen(Log_glob).map {|eval| eval.rescued_eval}.map do |error|
				assert_instance_of(SyntaxError, error)
				refute_nil(error.exception_hash[:unexpected], error.inspect)
				refute_empty(error.exception_hash[:unexpected], error.inspect)
				refute_equal(0, error.exception_hash[:unexpected].size, error.inspect)
				assert_operator(1, :==, error.exception_hash[:unexpected].size, error.message)
				if error.message.match(/expecting/)
					refute_nil(error.exception_hash[:expecting], error.inspect)
				end # if
				error.exception_hash
			end.compact.uniq
			assert_equal([], unique_exception_hashes)
	end # exception_hash
	
	def test_line_number
			unique_line_numbers = Eval.errors_seen(Log_glob).map {|eval| eval.rescued_eval}.map do |error|
				assert_instance_of(SyntaxError, error)
				error.line_number
			end.compact.uniq
			assert_equal([2, 5], unique_line_numbers)
	end # line_number
	
	def test_unexpected
			unique_unexpecteds = Eval.errors_seen(Log_glob).map {|eval| eval.rescued_eval}.map do |error|
				assert_instance_of(SyntaxError, error)
				error.unexpected
			end.compact.uniq
			assert_equal([], unique_unexpecteds)
	end # unexpected
	
	def test_expecting
	end # expecting
	
	def test_error_group
			assert_equal(SyntaxError::Expected_error_groups, Eval.unique_error_groups(Log_glob))
	end # error_group
	
	def test_unseen?
	end # unseen?
	
	def test_source_context
	end # source_context
	
	def test_assert_syntax_OK
	end # assert_syntax_OK
end # SyntaxError

class EvalTest < TestCase
  module Examples
    include SyntaxError::DefinitionalConstants
		include SyntaxErrorTest::Examples
    exception_constructor = 'e = Exception.new("' + Exception_constructor_message.to_s + + '");e.set_backtrace(' + Start_exception.backtrace.ruby_lines_storage + ');e'
		Exception_reconstruction = Eval.new(exception_constructor)
		require_relative '../examples/ruby_lines_storage.rb'
  end # Examples
  include Examples
	
		def test_read_all
			Log_reads.each do |eval| # = Eval.read_all(Log_glob)
				assert_instance_of(Eval, eval)
			end # each
		end # read_all
		
		def test_errors_seen
		  error_evals = Log_reads.reject do |eval|
				assert_instance_of(Eval, eval)
				eval.success? 
			end # reject
			errors_seen = error_evals.map do |eval|
				assert_instance_of(Eval, eval)
				refute(eval.success?, eval.ruby_lines_storage)
				assert_instance_of(SyntaxError, eval.rescued_eval)
			  eval
			 end # map
			assert_equal(Errors_seen.size, errors_seen.size)
			assert_equal(Errors_seen[0].class, errors_seen[0].class)
			assert_equal(Errors_seen[0], errors_seen[0])
#!			assert_empty(Errors_seen - errors_seen)
#!			assert_empty(errors_seen - Errors_seen)
			assert_equal(Errors_seen, errors_seen)
			Errors_seen.each do |eval| # = Log_reads.reject {|eval| eval.success? }
				assert_instance_of(Eval, eval)
			end # each
		end # errors_seen

		def test_unique_error_groups
			unique_error_groups = Eval.errors_seen(Log_glob).map {|eval| eval.rescued_eval}.map do |error|
				assert_instance_of(SyntaxError, error)
				error.error_group
			end.compact.uniq
			assert_equal(SyntaxError::Expected_error_groups, Eval.unique_error_groups(Log_glob))
#!			Unique_error_messages = Errors_seen.map{|e| e}.compact.uniq
			assert_empty(Unique_error_messages - SyntaxError::Expected_error_groups )
		end # unique_error_groups
		def test_unexpected_errors
		
		end # unexpected_errors

		def test_select_error_group
		end # select_error_group
	
	def test_Eval_initialize
		start_exception = Exception.new(Exception_constructor_message)
    exception_constructor = 'e = Exception.new("' + Exception_constructor_message.to_s + + '");e.set_backtrace(' + start_exception.backtrace.ruby_lines_storage + ');e'
		reconstructed_exception = Eval.new(exception_constructor)
	end # initialize	

	def test_rescued_eval
		assert_instance_of(Exception, Exception.new(Exception_constructor_message))
		assert_instance_of(Exception, Exception_reconstruction.rescued_eval, Exception_reconstruction.inspect)
	end # rescued_eval
	
	def test_success?
    Log_reads.each do |eval|
      if eval.success?
				assert(eval.success?, eval.ruby_lines_storage)
				assert_instance_of(Hash, eval.rescued_eval)
			else
				refute(eval.success?, eval.ruby_lines_storage)
				assert_instance_of(SyntaxError, eval.rescued_eval)
			end # if
    end # each

		Errors_seen.each do |eval| # = Log_reads.reject {|eval| eval.success? }
			assert_instance_of(Eval, eval)
			assert_instance_of(SyntaxError, eval.rescued_eval)
		end # each
	end # success?
	
	def test_state
	end # state
end # Eval

class ReconstructionTest < TestCase


end # Reconstruction

class RubyLinesStorageTest < TestCase
  module Examples
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

  def test_RubyLinesStorage_read

    example_minitest = Eval.read('./log/unit/2.2/2.2.3p173/silence/single_test_fail.rb.log')
    example_testunit = Eval.read('./log/unit/2.2/2.2.3p173/silence/initialization_fail.rb.log')

    example_minitest_log = IO.read('./log/unit/2.2/2.2.3p173/silence/single_test_fail.rb.log')
		
		refute_empty(Log_paths)
    errors_seen = Log_paths.map do |path|
      file_contents = IO.read(path)
      eval = Eval.read(path)
      assert_instance_of(Eval, eval)
      if eval.success?
				assert(eval.success?, eval.ruby_lines_storage)
			else
				refute(eval.success?, eval.ruby_lines_storage)
			end # if
    end.uniq # each
		assert_empty(Unique_error_messages.map{|e| e.class.name}.uniq - ['SyntaxError'])
		expecting_right_paren_not_comma_contexts = errors_seen.select{|e| e[:errors] == expecting_right_paren_not_comma}.map{|e| e[:context].split(',')}
		expecting_right_brace_not_comma_contexts = errors_seen.select{|e| e[:errors] == expecting_right_brace_not_comma}.map{|e| e[:context].split(',')}
		unexpect_less_than_contexts = errors_seen.select{|e| e[:errors] == unexpect_less_than}.map{|e| e[:context].split('<')}
#!    refute_includes(unique_error_messages, unexpect_less_than, unexpect_less_than_contexts.ruby_lines_storage)
#!    refute_includes(unique_error_messages, expecting_right_paren_not_comma, expecting_right_paren_not_comma_contexts.ruby_lines_storage)
#!    refute_includes(unique_error_messages, expecting_right_brace_not_comma, expecting_right_brace_not_comma_contexts.ruby_lines_storage)
  end # read
	
	def test_assert_readable
    file_times = Log_paths.map do |path|
				eval = Eval.read(path)
				assert_instance_of(Eval, eval)
				if eval.success?
					assert(eval.success?, eval.ruby_lines_storage)
#!					refute_includes(eval.keys, :exception_hash, eval.ruby_lines_storage)
				else
					refute(eval.success?, eval.ruby_lines_storage)
				end # if
#!			RubyLinesStorage.assert_readable(path)
		end # each
	end # assert_read
  def eval_name(name)
    expression_string = 'Examples::' + name.to_s
    eval_rescued(expression_string)
  rescue
    raise 'name = ' + name.inspect + ' in expression ' + expression_string + ' should eval.'
  end # eval_name

  def assert_reversible(object)
    ruby_lines_storage = object.ruby_lines_storage
    assert_instance_of(String, ruby_lines_storage, 'Method ruby_lines_storage in class ' + object.class.name + ' must return a String.')
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
      if name.to_s[0, 12] == 'Approximate_'
        assert_approximate(eval_name(name), Rational(11_574, 1_000_000_000))
      end # if
    end # each
  end # assert_reversible

  def test_assert_lines
    Examples.constants.each do |name|
      if name.to_s[0, 5] == 'Long_'
        assert_lines(eval_name(name))
      end # if
      #				assert_reversible(eval_name(name))
    end # each
  end # assert_lines

  def test_assert_approximate
    Examples.constants.each do |name|
      if name.to_s[0, 12] == 'Approximate_'
        assert_approximate(eval_name(name), Rational(11_574, 1_000_000_000))
      end # if
    end # each
  end # assert_approximate

  def test_Array_ruby_lines_storage
    assert_equal('[1, 2, 3]', [1, 2, 3].ruby_lines_storage)
    assert_match(/\n/, Long_array.ruby_lines_storage)
    assert_reversible(Short_array)
    assert_reversible(Long_array)
    assert_reversible([])
    assert_reversible([1])
  end # Array

  def test_Hash_ruby_lines_storage
    assert_equal("{\n}\n", Empty_hash.ruby_lines_storage)
    assert_reversible(Empty_hash)

    ret = []
    Short_hash.each_pair do |key, value|
      ret << key.ruby_lines_storage + ' => ' + value.ruby_lines_storage
    end # each_pair
    assert_equal([':a => 1', ':b => 2'], ret)
    ret = '{' + ret.join(",\n") + "\n" + "}\n"
    assert_equal("{:a => 1,\n:b => 2\n}\n", ret)
    assert_equal("{:a => 1,\n:b => 2\n}\n", Short_hash.ruby_lines_storage)
    assert_reversible(Short_hash)
  end # Hash

  def test_NilClass_ruby_lines_storage
    assert_equal('nil', nil.ruby_lines_storage)
    assert_reversible(nil)
  end # NilClass

  def test_Fixnum_ruby_lines_storage
    assert_equal('123', 123.ruby_lines_storage)
    assert_reversible(123)
  end # Fixnum

  def test_FalseClass_ruby_lines_storage
    assert_reversible(false)
  end # FalseClass

  def test_TrueClass_ruby_lines_storage
    assert_reversible(true)
  end # TrueClass

  def test_String_ruby_lines_storage
    assert_equal("'cat'", 'cat'.ruby_lines_storage)
    assert_equal("'cat\ndog'", "cat\ndog".ruby_lines_storage)
    refute_equal("'cat\ndog'".inspect, "cat\ndog".ruby_lines_storage)
    assert_reversible('12\'3')
end # String

  def test_Regexp_ruby_lines_storage
    #		assert_reversible(/a|b/)
    #		assert_reversible(/a|"b/)
    #		assert_reversible(/a|'b/)
    assert_match(/\//, '/')
    assert_equal('/', /\//.source)
    assert_equal('/', Regexp.escape('/')) # slash not escaped!
    assert_equal('/', Regexp.escape(/\//.source))
  #		assert_reversible(/\//)
  #		assert_reversible(/a|\/b/)
end # Regexp

  def test_MatchData_ruby_lines_storage
    match_data = 'a'.match(/a/)
    assert_instance_of(MatchData, match_data)
    assert_equal('a', match_data[0])
    assert_equal(/a/, match_data.regexp)
    assert_reversible(match_data)
  end # MatchData

  def test_Module_ruby_lines_storage
    assert_reversible(Object)
  end # Module

  def test_Symbol_ruby_lines_storage
    assert_equal(':cat', :cat.ruby_lines_storage)
    assert_reversible(:cat)
    assert_reversible(:"cat\ndog")
    assert_equal(':"cat\\ndog"', :"cat\ndog".ruby_lines_storage)
  end # Symbol

  def test_Date_ruby_lines_storage
    time = Date.today
    assert_reversible(time)
  end # Date

  def test_DateTime_ruby_lines_storage
    assert_approximate(DateTime.now, Rational(11_574, 1_000_000_000))
  end # DateTime

  def test_Time_ruby_lines_storage
    time = Time.now
    seconds = Rational(1_000_000_000 * time.sec + time.nsec, 1_000_000_000)
    assert_instance_of(Rational, seconds)
    refute_equal(0, seconds)
    eval_time = eval(time.ruby_lines_storage)
    round_off = time - eval_time
    assert_equal(time, eval_time, time.strftime('%Y-%m-%d %H:%M:%S.%9N %z') + time.ruby_lines_storage + round_off.to_f.to_s)
    assert_reversible(time)
  end # Time

	def test_Exception
		message = 'This is an example error message.'
		start_exception = Exception.new(message)
    exception_constructor = 'e = Exception.new("' + message.to_s + + '");e.set_backtrace(' + start_exception.backtrace.ruby_lines_storage + ');e'
		reconstructed_exception = eval(exception_constructor)
		assert_instance_of(Exception, Exception.new(message))
		assert_instance_of(Exception, reconstructed_exception, exception_constructor)
		assert_equal(start_exception.message, reconstructed_exception.message)
		assert_equal(start_exception, reconstructed_exception)
    assert_reversible(Exception.new(message))
	end # Exception

  def test_Object_ruby_lines_storage
    assert_equal('[1, 2, 3]', [1, 2, 3].ruby_lines_storage)
    assert_equal(%w(1 2 3), [1, 2, 3].map(&:ruby_lines_storage))
    assert_equal([1, 1, 1], [1, 2, 3].map { |e| e.ruby_lines_storage.size })
    assert_equal(%w(1 2 3), [1, 2, 3].map(&:ruby_lines_storage))
    assert_equal([1, 1, 1], [1, 2, 3].map(&:ruby_lines_storage).map(&:size))
    #		assert_reversible(MatchCapture::Examples::Branch_capture)
    #		assert_equal('', MatchCapture::Examples::Branch_capture.ruby_lines_storage, MatchCapture::Examples::Branch_capture.ruby_lines_storage)
  end # Object
end # RubyLinesStorage
