###########################################################################
#    Copyright (C) 2012-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/requires.rb'
class RequireTest < TestCase
#include DefaultTests
include RailsishRubyUnit::Executable.model_class?::Examples
def test_scan
	ret = {}
	Unit::Executable.edit_files.each do |file|
		code = IO.read(file)
		parse = code.capture?(Require_regexp)
		ret = ret.merge({FilePattern.find_from_path(file)[:name] => parse})
	end # each
	assert_instance_of(Hash, ret)
	assert_equal(ret, Executing_requires.requires)
end # scan
def test_Require_attributes
	assert_instance_of(Hash, Executing_requires.requires)
	assert_includes(Executing_requires.requires.keys, :unit)
end # values
end # Require
