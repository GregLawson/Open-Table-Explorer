###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'pathname'
require_relative '../../app/models/global.rb'
require 'set'
module RubyAssertions
  include AssertionsModule
  extend AssertionsModule
  # def assert_includes(list, element,  message = '')
  #	message = "First argument of assert_include must be an Array or Set"
  #	message += ', not ' + list.inspect
  #	fail message if !(list.instance_of?(Array) || list.instance_of?(Set))
  #	message = message + element.inspect
  #	message += " is not in list " + list.inspect
  #	assert(list.include?(element),message)
  # end #assert_include
  # def refute_includes(list, element,  message = '')
  #	message=build_message(message, "? is in list ?", element,list)
  #	assert_block(message){!list.include?(element)}
  # end #refute_include
	
	def assert_raise(args, &block)
		assert_raises(args) {block.call}
	end # assert_raise
end # RubyAssertions
