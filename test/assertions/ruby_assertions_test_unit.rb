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
  def missing_file_message(pathname)
    pathname = Pathname.new(pathname).expand_path
    if pathname.exist?
      ''
    else
      existing_dir = nil
      pathname.ascend { |f| (existing_dir = f) && break if f.exist? }
      'pathname = ' + pathname.to_s + " does not exist\n" \
        'parent directory ' +
        existing_dir.to_s +
        ' does exists containing ' +
        Dir[existing_dir.to_s + '*'].map { |f| File.basename(f) }.inspect
    end # if
  end # missing_file_message

  def assert_pathname_exists(pathname, message = '')
    message = missing_file_message(pathname.to_s) + message
    refute_nil(pathname, message)
    refute_empty(pathname.to_s, message + 'Assume pathname to not be empty.')
    pathname = Pathname.new(pathname).expand_path
    message += "\nPathname(#{pathname}).exist?=" + pathname.exist?.to_s + "\n" + missing_file_message(pathname)
    assert(pathname.exist?, message)
    assert(File.exist?(pathname), message + "File.exists?(#{pathname})=#{File.exist?(pathname).inspect}")
    pathname # allow chaining
  end # assert_pathname_exists
	
	def assert_raises(args, &block)
		assert_raise(args) {block.call}
	end # assert_raises
end # RubyAssertions
