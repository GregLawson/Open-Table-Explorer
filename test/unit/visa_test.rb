###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative 'test_environment' # avoid recursive requires
require 'test/unit'
TestCase=Test::Unit::TestCase
require_relative '../../app/models/default_test_case.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../app/models/shell_command.rb'
require 'fiddle'
require 'ffi'
class VisaTest < TestCase
extend FFI::Library
def test_example
	libm = Fiddle.dlopen('/usr/lib/x86_64-linux-gnu/libvisa.so')

	floor = Fiddle::Function.new(
	  libm['floor'],
	  [Fiddle::TYPE_DOUBLE],
	  Fiddle::TYPE_DOUBLE
	)

	puts floor.call(3.14159)
	assert_instance_of(Fixnum, floor.call(3.14159))
end # example
def test_script
	install_execution=ShellCommands.new('locate libvisa').assert_post_conditions
end # script
def test_GetPid
	libm = Fiddle.dlopen('/usr/lib/x86_64-linux-gnu/libvisa.so')

	floor = Fiddle::Function.new(
	  libm['getpid'],
	  [],
	  Fiddle::TYPE_INT
	)

	puts floor.call
	assert_instance_of(Fixnum, floor.call)
end # GetPid
end # Visa

