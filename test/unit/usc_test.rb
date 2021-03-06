###########################################################################
#    Copyright (C) 2014-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/usc.rb'
require_relative '../assertions/shell_command_assertions.rb'
class UscTest < TestCase
  # include DefaultTests
  include RailsishRubyUnit::Executable.model_class?::Examples
  # Usc_file.gets
  def test_Constants
    assert(File.exist?(First_usc.path))
    assert(FTDI_ttys.include?(First_usc_filename), FTDI_ttys.inspect)
    assert_includes(FTDI_ttys, Usc_filename)
  end # Constants
end # Usc
