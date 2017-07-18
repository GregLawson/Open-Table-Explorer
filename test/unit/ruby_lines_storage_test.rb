###########################################################################
#    Copyright (C) 2014-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/ruby_lines_storage.rb'
require_relative '../examples/ruby_lines_storage.rb'
		
class ExceptionTest < TestCase
	
	def test_Exception_rescued_value
		assert_instance_of(SyntaxError, Exception.rescued_value(SyntaxError){eval('1=2')})
		assert_instance_of(RuntimeError, Exception.rescued_value(RuntimeError){fail})
		assert_instance_of(RuntimeError, Exception.rescued_value(RuntimeError){raise})
#!		assert_instance_of(SyntaxError, Exception.rescued_value(RuntimeError){exit})
		assert_instance_of(SyntaxError, Exception.rescued_value(SyntaxError){raise SyntaxError})
		assert_instance_of(RuntimeError, Exception.rescued_value(RuntimeError){raise RuntimeError})
		no_method_error = Exception.rescued_value(NoMethodError){eval("\"(?-mix:1)\".capture(:a)")}
		assert_instance_of(NoMethodError, no_method_error)
		assert_instance_of(NoMethodError, Exception.rescued_value(NoMethodError){eval("capture(:a)")})
		assert_instance_of(String, Exception.rescued_value(NoMethodError){eval("\"(?-mix:1)\"")})
		assert_instance_of(SyntaxError, Exception.rescued_value(SyntaxError){eval("(?-mix:1).capture(:a)")})
		assert_instance_of(NoMethodError, Exception.rescued_value(NoMethodError){eval("\"(?-mix:1)\".capture(:a)")})
    assert_instance_of(NoMethodError,  Exception.rescued_value(NoMethodError){Regexp.regexp_rescued('[')})
    assert_instance_of(RegexpError,  Exception.rescued_value(RegexpError){Regexp.new('[')})
	end # rescued_value
end # ExceptionTest

class SyntaxErrorTest < TestCase
	module Examples
		Error1 = SyntaxError.rescued_eval('1=2')
		Error2 = SyntaxError.rescued_eval('end')
		Error3 = SyntaxError.rescued_eval('{([')
		All_examples = [Error1, Error2, Error3]
	end # Examples
	include Examples
	
  def test_SyntaxError_DefinitionalConstants
  end # DefinitionalConstants
	def test_rescued_eval
		All_examples.each do |example|
			assert_instance_of(SyntaxError, example)
		end # each
		end # rescued_eval

  def test_ReferenceObjects
#!		assert_equal(SyntaxError::Expected_error_groups, All_examples)
  end # ReferenceObjects

	def test_capture
		All_examples.each do |example|
			assert_match(SyntaxError::Eval_syntax_error_regexp, example.message)
		end # each
	end # capture
	
	def test_message_refinement
		All_examples.each do |example|
			#! example.capture.assert_refinement(:exact)
		end # each
	end # message_refinement

	def test_exception_hash
	end # exception_hash
	
	def test_line_number
	end # line_number
	
	def test_unexpected
	end # unexpected
	
	def test_expecting
	end # expecting
	
	def test_error_group
		All_examples.each do |example|
			#! assert_include(SyntaxError::Expected_error_groups, example.error_group)
		end # each
	end # error_group
	
	def test_unseen?
	end # unseen?
	
	def test_source_context
	end # source_context
	
	def test_assert_syntax_OK
	end # assert_syntax_OK
end # SyntaxError


	def test_RegexpError_rescued_regexp
		assert_instance_of(RegexpError, RegexpError.rescued_regexp('{(['))
	end # rescued_eval

class EvalTest < TestCase
  module Examples
    include Reconstruction::DefinitionalConstants
		Exception_constructor_message = 'This is an example error message.'
#!		include SyntaxErrorTest::Examples
		Start_exception = Exception.new(Exception_constructor_message)
    Exception_constructor = 'e = Exception.new("' + Exception_constructor_message.to_s + + '");e.set_backtrace(' + Start_exception.backtrace.ruby_lines_storage + ');e'
		Exception_reconstruction = Eval.new(Exception_constructor)
    Exception_message = '(eval):17: syntax error, unexpected tSYMBEG, expecting end-of-input'.freeze
  end # Examples
  include Examples
	
	def test_initialize
		start_exception = Exception.new(Exception_constructor_message)
    exception_constructor = 'e = Exception.new("' + Exception_constructor_message.to_s + + '");e.set_backtrace(' + start_exception.backtrace.ruby_lines_storage + ');e'
		reconstructed_exception = Eval.new(exception_constructor)
	end # initialize	
end # Eval

class ReconstructionTest < TestCase
  module Examples
    include Reconstruction::DefinitionalConstants
		Exception_constructor_message = 'This is an example error message.'
		start_exception = Exception.new(Exception_constructor_message)
    exception_constructor = 'e = Exception.new("' + Exception_constructor_message.to_s + + '");e.set_backtrace(' + start_exception.backtrace.ruby_lines_storage + ');e'
		Exception_reconstruction = Reconstruction.new(exception_constructor)
  end # Examples
  include Examples
	
	def test_initialize
		start_exception = Exception.new(Exception_constructor_message)
    exception_constructor = 'e = Exception.new("' + Exception_constructor_message.to_s + + '");e.set_backtrace(' + start_exception.backtrace.ruby_lines_storage + ');e'
		reconstructed_exception = Reconstruction.new(exception_constructor)
	end # initialize
	
		def test_read_all
		end # read_all
		
		def test_errors_seen
		end # errors_seen

		def test_unique_error_groups
		end # unique_error_groups
		
		def test_unexpected_errors
		
		end # unexpected_errors

		def test_select_error_group
		end # select_error_group
	def test_reconstruction
		assert_instance_of(Exception, Exception.new(Exception_constructor_message))
		assert_instance_of(Exception, Exception_reconstruction.reconstruction, Exception_reconstruction.inspect)
	end # reconstruction
	
	def test_success?
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
		require_relative '../examples/ruby_lines_storage.rb'
  end # Examples
  include Examples
	
  def test_read_error_context
    assert_match(/\(eval\):/ * /[0-9]+/.capture(:line), Exception_message)
    assert_match(/\(eval\):/ * /[0-9]+/.capture(:line) * /: / * /.*/, Exception_message)
    assert_match(Reconstruction::Eval_syntax_error_regexp, Exception_message)
    exception_hash = Exception_message.parse(Reconstruction::Eval_syntax_error_regexp)
    assert_equal('17', exception_hash[:line])
  end # read_error_context

  def test_eval_rls
  end # eval_rls
	
  def eval_rescued(example_string)
    eval(example_string)
  rescue Exception => exception_raised
    raise 'example_string.inspect = ' + example_string.inspect + "\n" + exception_raised.inspect
  end # eval_example

	def test_read_success?
    Log_evals.each do |eval|
      if eval.success?
				assert(eval.success?, eval.ruby_lines_storage)
			else
				refute(eval.success?, eval.ruby_lines_storage)
			end # if
    end # each
	end # read_success?

  def test_RubyLinesStorage_read

    example_minitest = RubyLinesStorage.read('./log/unit/2.2/2.2.3p173/silence/single_test_fail.rb.log')
    example_testunit = RubyLinesStorage.read('./log/unit/2.2/2.2.3p173/silence/initialization_fail.rb.log')

    example_minitest_log = IO.read('./log/unit/2.2/2.2.3p173/silence/single_test_fail.rb.log')
		
		refute_empty(Log_paths)
    errors_seen = Log_paths.map do |path|
      file_contents = IO.read(path)
      eval = RubyLinesStorage.read(path)
      assert_instance_of(Eval, eval)
      if eval.success?
				assert(eval.success?, eval.ruby_lines_storage)
			else
				refute(eval.success?, eval.ruby_lines_storage)
			end # if
    end.uniq # each
		assert_instance_of(Hash, Unique_error_messages, Unique_error_messages.ruby_lines_storage)
		assert_empty(Unique_error_messages.keys.map{|e| e[:exception_class]}.uniq - [SyntaxError], Unique_error_messages.keys.ruby_lines_storage)
#!		assert_empty(Unique_error_messages - [expecting_right_paren_not_comma, 		 expecting_right_brace_not_comma, unexpect_less_than ] )
#!		expecting_right_paren_not_comma_contexts = Unique_error_messages[expecting_right_paren_not_comma].map{|e| e[:context].split(',')}
#!		expecting_right_brace_not_comma_contexts = Unique_error_messages[expecting_right_brace_not_comma].map{|e| e[:context].split(',')}
#!		unexpect_less_than_contexts = Unique_error_messages[unexpect_less_than].map{|e| e[:context].split('<')}
#!    refute_includes(unique_error_messages.keys, Unexpect_less_than, unexpect_less_than_contexts.ruby_lines_storage)
#!    refute_includes(unique_error_messages.keys, Expecting_right_paren_not_comma, expecting_right_paren_not_comma_contexts.ruby_lines_storage)
#!    refute_includes(unique_error_messages.keys, Expecting_right_brace_not_comma, expecting_right_brace_not_comma_contexts.ruby_lines_storage)
  end # read
	
	def test_assert_readable
    file_times = Log_paths.map do |path|
				eval = RubyLinesStorage.read(path)
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
			else
				assert_reversible(eval_name(name))
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
		assert_equal(['1', '2', '3'], [1,2,3].map {|e| e.ruby_lines_storage})
    assert_equal([1, 1, 1], [1, 2, 3].map { |e| e.ruby_lines_storage.size })
		assert_equal(['1', '2', '3'], [1,2,3].map(&:ruby_lines_storage))
    assert_equal([1, 1, 1], [1, 2, 3].map(&:ruby_lines_storage).map(&:size))
    #		assert_reversible(MatchCapture::Examples::Branch_capture)
    #		assert_equal('', MatchCapture::Examples::Branch_capture.ruby_lines_storage, MatchCapture::Examples::Branch_capture.ruby_lines_storage)
  end # Object
end # RubyLinesStorage
