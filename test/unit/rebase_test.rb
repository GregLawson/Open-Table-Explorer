###########################################################################
#    Copyright (C) 2012-2013 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/minimal2.rb'
class RebaseTest < TestCase
  include DefaultTests
  include RailsishRubyUnit::Executable.model_class?::Examples
end # Rebase
