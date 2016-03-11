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
		ret = ret.merge({file => parse})
	end # each
	assert_equal(ret, Executing_requires.scan)
end # scan
end # Requires
