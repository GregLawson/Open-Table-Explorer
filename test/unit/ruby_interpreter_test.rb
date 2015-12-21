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
require_relative '../assertions/shell_command_assertions.rb'
require_relative '../../app/models/ruby_interpreter.rb'
# executed in alphabetical order. Longer names sort later.
class ReportedVersionTest < TestCase
include ReportedVersion::Examples
include ReportedVersion::DefinitionalConstants
def test_ReportedVersion_DefinitionalConstants
end # DefinitionalConstants
def test_virtus_initialize
end # virtus_initialize
def test_DefinitionalConstants
end # DefinitionalConstants
def test_which
end # which
def test_whereis
end # whereis
def test_versions
end # versions
def test_Examples
end # Examples
end # ReportedVersion

class RubyVersionTest < TestCase
include RubyVersion::Examples
include RubyVersion::DefinitionalConstants
def test_RubyVersion_DefinitionalConstants
	assert_match(Ruby_pattern, Ruby_version)
	assert_match(Parenthetical_date_pattern, Ruby_version)
	assert_match(Bracketed_os, Ruby_version)
#	assert_match(Ruby_pattern * / /, Ruby_version)
#	assert_match(Ruby_pattern * / / * Parenthetical_date_pattern, Ruby_version)
	assert_match(Parenthetical_date_pattern * Bracketed_os, Ruby_version)
#	assert_match(Version_pattern, Ruby_version)
end # DefinitionalConstants
def test_ruby_version
	executable_suffix = ''
	parse = Ruby_version.parse(Version_pattern)
#	assert_instance_of(Hash, parse)
#	assert_operator(parse[:major], :>=, '1')
#	assert_operator(parse[:minor], :>=, '1')
#	assert_operator(parse[:patch], :>=, '1')
#	assert_instance_of(String, parse[:pre_release])
end # ruby_version
end # RubyVersion

class RubyInterpreterTest < TestCase
include RubyInterpreter::Examples
include RubyInterpreter::DefinitionalConstants
def test_RubyInterpreter_DefinitionalConstants
end # DefinitionalConstants
def test_shell
	refute_empty(RubyInterpreter.shell('pwd'){|run| run.inspect})
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
	
end #initialize
end # RubyInterpreter
