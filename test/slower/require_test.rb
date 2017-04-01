###########################################################################
#    Copyright (C) 2012-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/require.rb'
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/test_run.rb'
class RequireTest < TestCase
  # include DefaultTests
  include RailsishRubyUnit::Executable.model_class?::Examples
  def test_scan
    assert_equal(Require.new(path: 'test/unit/shell_command_test.rb').requires, Require.new(path: 'test/unit/test_run_test.rb').requires)
  end # scan
end # Require
