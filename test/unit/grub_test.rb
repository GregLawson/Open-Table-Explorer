###########################################################################
#    Copyright (C) 2012-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/grub.rb'
require_relative '../assertions/shell_command_assertions.rb'
class GrubTest < TestCase
  # include DefaultTests
  include RailsishRubyUnit::Executable.model_class?::Examples
  def test_Constants
    linux = Config_run.lines.map do |line|
      #   puts line
      capture = line.capture?(Config_pattern)
      search = line.capture?(Search_regexp)
      next unless capture.success? || search.success?
      #        puts line
      #       puts capture.output.inspect
      [capture.output, search.output]
      # if
    end.compact.uniq # map
    assert_instance_of(Array, linux, linux.inspect)
    #   assert_equal(['3', '4'], linux.map{|l| l[0][:major]}.uniq.sort)
    assert_equal(5, linux.uniq.size, linux.uniq.inspect)
    sans_indent = linux.map { |l| l[0].delete(:indent); l }.uniq
    puts sans_indent.join("\n")
    assert_equal(3, sans_indent.size, sans_indent.inspect)
    assert_equal(36, linux[0][:uuid].size)

    assert_instance_of(Array, search, search.inspect)
    end # Constants
end # Grub
