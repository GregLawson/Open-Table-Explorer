###########################################################################
#    Copyright (C) 2011-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/regexp.rb'
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/version.rb'
# executed in alphabetical order. Longer names sort later.
class VersionTest < TestCase
include Version::Examples
include Version::Constants
def test_virtus_initialize
end # virtus_initialize
def test_square_brackets
	assert_equal('1'. First_example_version.major)
end # square_brackets
def test_ruby_version
	executable_suffix = ''
	ruby_interpreter = Version.new(test_command: 'ruby', options: '--version')
	parse = ruby_interpreter.attributes
	assert_instance_of(Hash, parse)
	assert_operator(parse[:major], :>=, '0')
	assert_operator(parse[:minor], :>=, '0')
	assert_operator(parse[:patch], :>=, '0')
	assert_instance_of(String, parse[:pre_release])
end # ruby_version
def test_initialize
	ruby_interpreter=Version.new
	assert_respond_to(ruby_interpreter, 'major')
	ruby_interpreter.major='method'
	assert_equal('method', ruby_interpreter.major)
	assert_equal('method', ruby_interpreter.attributes[:major])
	assert_nil(ruby_interpreter.attributes['major'])
	
	ruby_interpreter[:major]='sym_hash'
	assert_equal('sym_hash', ruby_interpreter.major)
	assert_equal('sym_hash', ruby_interpreter[:major])
	
	ruby_interpreter['major']='string_hash'
	assert_equal('string_hash', ruby_interpreter.major)
	assert_equal('string_hash', ruby_interpreter[:major])
	
	First_example_version.assert_logical_primary_key_defined
end #initialize
def test_Version_Examples
	assert_match(/[1-9]?[0-9]{1,3}/, '1.9.0')
	assert_match(Version_digits, First_example_version_name)
	assert_match(Version_pattern, First_example_version_name)
end # Examples
end # Version
