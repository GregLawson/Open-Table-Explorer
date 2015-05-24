#!/usr/bin/ruby
###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# @see http://ruby-doc.org/stdlib-2.0.0/libdoc/optparse/rdoc/OptionParser.html#method-i-make_switch
require 'pp'
#require_relative '../app/models/work_flow.rb'
require_relative '../app/models/command_line.rb'
require_relative '../app/models/unit.rb'
require_relative '../app/models/test_executable.rb'
scripting_executable = TestExecutable.new_from_pathname($0)
require_relative "../app/models/#{scripting_executable.unit.model_basename}"
commands = []
script = CommandLineScript.new($0)
script.add_option(:inspect, 'Inspect.')
script.add_option(:test, 'Test.')
script.parse_options
# good enough for testing; no syntax error

pp commands if $VERBOSE
pp ARGV if $VERBOSE

	case ARGV.size # paths after switch removal?
	when 0 then # scite testing defaults command and file
		puts script.banner
		this_file=File.expand_path(__FILE__)
		argv=[this_file] # incestuous default test case for scite
		commands=[:inspect]
		else
		argv=ARGV
	end #case
	commands.each do |c|
		case c.to_sym
		when :all then
		
		else argv.each do |f|
			puts "#{scripting_executable.unit.inspect}"
			case c.to_sym
			when :inspect then puts scripting_executable.unit.inspect
			when :test then scripting_executable.unit.test
			else
				if scripting_executable.unit.respond_to?(c.to_sym) then
					scripting_executable.unit.send(c.to_sym, *argv)
				else
					puts "#{c.to_sym} is not a method in #{scripting_executable.unit.inspect}"
				end # if
			end #case
		end #each
		end #case
	end #each
1 # successfully completed
