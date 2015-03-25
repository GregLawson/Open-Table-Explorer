###########################################################################
#    Copyright (C) 2011-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require 'active_support' # for singularize and pluralize
require_relative '../../app/models/regexp.rb'
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/ruby_interpreter.rb'
# executed in alphabetical order. Longer names sort later.
class RubyInterpreterTest < TestCase
include RubyInterpreter::Examples
include RubyInterpreter::Constants
def test_virtus_initialize
end # virtus_initialize
def test_Constants
	assert_match(Ruby_pattern, Ruby_version)
	assert_match(Parenthetical_date_pattern, Ruby_version)
	assert_match(Bracketed_os, Ruby_version)
	assert_match(Ruby_pattern * Parenthetical_date_pattern, Ruby_version)
	assert_match(Parenthetical_date_pattern * Bracketed_os, Ruby_version)
	assert_match(Version_pattern, Ruby_version)
end # Constants
def test_ruby_version
	executable_suffix = ''
	ruby_interpreter = RubyInterpreter.new(test_command: 'ruby', options: '--version').run
	parse = ruby_interpreter.output.parse(Version_pattern).output
	assert_instance_of(Hash, parse)
	assert_operator(parse[:major], :>=, '1')
	assert_operator(parse[:minor], :>=, '1')
	assert_operator(parse[:patch], :>=, '1')
	assert_instance_of(String, parse[:pre_release])
end # ruby_version
def test_shell
	assert_not_empty(RubyInterpreter.shell('pwd'){|run| run.inspect})
end #shell
def test_initialize
	ruby_interpreter=RubyInterpreter.new
	assert_respond_to(ruby_interpreter, 'processor_version')
	ruby_interpreter.processor_version='method'
	assert_equal('method', ruby_interpreter.processor_version)
	assert_equal('method', ruby_interpreter.attributes[:processor_version])
	assert_nil(ruby_interpreter.attributes['processor_version'])
	
	ruby_interpreter[:processor_version]='sym_hash'
	assert_equal('sym_hash', ruby_interpreter.processor_version)
	assert_equal('sym_hash', ruby_interpreter[:processor_version])
	
	ruby_interpreter['processor_version']='string_hash'
	assert_equal('string_hash', ruby_interpreter.processor_version)
	assert_equal('string_hash', ruby_interpreter[:processor_version])
	
	Singular_ruby_interpreter.assert_logical_primary_key_defined
end #initialize
end # RubyInterpreter
