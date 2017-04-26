###########################################################################
#    Copyright (C) 2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
ruby -W0 script/disk.rb
ruby -W0 script/command_line_sub_executable.rb disk
ruby -W0 script/command_line_executable.rb disk