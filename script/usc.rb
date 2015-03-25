#!/usr/bin/ruby
###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# @see http://ruby-doc.org/stdlib-2.0.0/libdoc/optparse/rdoc/OptionParser.html#method-i-make_switch
require_relative '../app/models/command_line.rb'
pp ARGV if $VERBOSE
IO.foreach('/dev/ttyUSB0') do |line|
	puts line
end # foreach
