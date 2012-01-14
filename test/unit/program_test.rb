###########################################################################
#    Copyright (C) 2010-2011 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/test_helper'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class Program < ActiveRecord::Base
end #Program
Program.establish_connection(
  :adapter => "mysql2",
  :encoding => "utf8",
  :database => "mythconverg",
  :pool => 5,
  :username => "mythtv",
  :password => "mythtv",
  :socket => "/tmp/mysql.sock")
  
class ProgramTest < ActiveSupport::TestCase
	assert_not_nil(Program.new)
end #ProgramTest
