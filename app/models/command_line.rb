###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'optparse'
require 'ostruct'
require 'pp'
require 'test/unit'
require 'mime/types' # new ruby detailed library
require_relative '../../app/models/shell_command.rb'
class CommandLine
module ClassMethods
def path_of_command(command)
		whereis=ShellCommands.new("whereis "+command).execute.output
end #path_of_command
end #ClassMethods
extend ClassMethods
def initialize(path, description=nil, help_source=nil)
	@path=File.expand_path(path)
	@description=description
	@help_source=help_source
	@file_type=	ShellCommands.new("file -b "+@path).execute.output
	@mime_type=	ShellCommands.new("file -b --mime "+@path).execute.output
	@dpkg="grep "#{@path}$"  /var/lib/*/info/*.list"
	if @mime_type=='application/octet' then
		@basename=File.basename(path,File.extname(path))
		@version=ShellCommands.new(@basename+" --version").execute.output
		@v=ShellCommands.new(basename+" -v").execute.output
		@man=ShellCommands.new("man "+@basename).execute.output
		@info=ShellCommands.new("info "+@basename).execute.output
		@help=ShellCommands.new(@basename+" --help").execute.output
		@h=ShellCommands.new(@basename+" -h").execute.output
		@whereis=ShellCommands.new("whereis "+command).execute.output
	end #if
end #initialize
#mime/types in a ruby library
def ruby_mime
    plaintext = MIME::Types[@mime_type]
    # returns [text/plain, text/plain]
    text      = plaintext.first
end #ruby_mime
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
def assert_post_conditions
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
end #Assertions
include Assertions
#TestWorkFlow.assert_pre_conditions
module Constants
end #Constants
include Constants
module Examples
include Constants
end #Examples
include Examples
end #CommandLine
class CommandLineScript < CommandLine
def add_option(name, description=name, long_option=name, short_option=name[0])
	option=CommandLineOption.new(name, description, long_option, short_option)
	@options = (@options.nil? ? [] : @options)+[option]
end #add_option
def parse_options
	@commands = []
	OptionParser.new do |opts|
		opts.banner = "Usage: #@basename} --<command> files"
		@options.each do |option|
			opts.on(option.short_option, "--[no-]#{option.long_option}", option.description) do |o|
				@commands+=[option.name] if o
		  end #on
	  end #each
	end.parse!
end #parse_options
def run
	case ARGV.size
	when 0 then # scite testing defaults command and file
		puts "work_flow --<command> <file>"
		this_file=File.expand_path(__FILE__)
		argv=[this_file] # incestuous default test case for scite
	else
		argv=ARGV
	end #case
	if @coomands.size=0 then
		@commands=[:test]
	end #if
	argv.each do |f|
		command_line=CommandLine.new(f)
		@commands.each do |c|
			command_line.method(c)
		end #each
	end #each
end #run
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
def assert_post_conditions
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
end #Assertions
include Assertions
#TestWorkFlow.assert_pre_conditions
module Constants
end #Constants
include Constants
module Examples
include Constants
SELF=CommandLineScript.new($0)
end #Examples
include Examples
end #CommandLineScript
class CommandLineOption
def initialize(name, description=name, long_option=name, short_option=name[0])
	@name=name
	@description=description
	@short_option=short_option
	@long_option=long_option
end #initialize
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
def assert_post_conditions
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
end #Assertions
include Assertions
#TestWorkFlow.assert_pre_conditions
module Constants
end #Constants
include Constants
module Examples
include Constants
end #Examples
include Examples
end #CommandLineOption
