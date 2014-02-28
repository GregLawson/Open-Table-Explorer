###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require 'pp'
require_relative '../../app/models/command_line.rb'
class CommandLineTest < TestCase
include CommandLineScript::Examples
def test_path_of_command
	assert_match('/usr/bin/ruby', CommandLine.path_of_command('ruby'))
end #path_of_command
def test_initialize
	path=File.expand_path(__FILE__)
	file_type=	ShellCommands.new("file -b "+path).puts
	mime_type=	ShellCommands.new("file -b --mime "+path).puts
	@dpkg="grep "#{@path}$"  /var/lib/*/info/*.list"
	if mime_type=='application/octet' then
		basename=File.basename(path)
		version=ShellCommands.new(basename+" --version").output
		v=ShellCommands.new(basename+" -v").output
		man=ShellCommands.new("man "+basename).output
		info=ShellCommands.new("info "+basename).assert_post_conditions.puts
		help=ShellCommands.new(basename+" --help").assert_post_conditions.puts
		h=ShellCommands.new(basename+" -h").assert_post_conditions.puts
		whereis=ShellCommands.new("whereis "+command).output
	end #if
end #initialize
def test_ruby_mime
# example code from zless /usr/share/doc/ruby-mime-types/README.rdoc.gz
    plaintext = MIME::Types['text/plain']
    # returns [text/plain, text/plain]
	assert_instance_of(Array, plaintext)
    text      = plaintext.first

    puts text.media_type            # => 'text'
    puts text.sub_type              # => 'plain'

    puts text.extensions.join(" ")  # => 'txt asc c cc h hh cpp hpp dat hlp'

    puts text.encoding              # => quoted-printable
    puts text.binary?               # => false
    puts text.ascii?                # => true
    puts text.obsolete?             # => false
    puts text.registered?           # => true
    puts text == 'text/plain'       # => true
    puts MIME::Type.simplified('x-appl/x-zip')
                                    # => 'appl/zip'

    puts MIME::Types.any? { |type|
      type.content_type == 'text/plain'
    }                               # => true
    puts MIME::Types.all?(&:registered?)
                                    # => false
	mime=SELF.ruby_mime
end #ruby_mime
def test_add_option
  SELF.add_option("edit", "Edit related files and versions in diffuse")
  SELF.add_option("downgrade", "Test downgraded related files in git branches")
  SELF.add_option("upgrade", "Test upgraded related files in git branches")
  SELF.add_option("test", "Test. No commit. ")
end #add_option


def test_initialize
	name = :test
	description=name.to_s
	long_option=name
	short_option=name[0] 
	executing_command_line = CommandLineOption.new(name, description, long_option, short_option=name[0])
end #initialize
def test_non_interactive_scripts
	no_arg_run=ShellCommands.new('ruby  script/command_line.rb').assert_post_conditions
	assert_equal('', no_arg_run.errors)
	assert_not_equal('', no_arg_run.output)
	help_run=ShellCommands.new('ruby  script/command_line.rb --help')
	inspect_run=ShellCommands.new('ruby  script/command_line.rb --inspect')
	test_run=ShellCommands.new('ruby  script/command_line.rb --test')
	hypothesis = :bad_opt_hypothesis
	case hypothesis
	when :bad_opt_hypothesis then
		assert_match(/can't convert Symbol into String/, help_run.errors)
		assert_match(/invalid option/, inspect_run.errors)
		assert_match(/invalid option/, test_run.errors)
		assert_equal(inspect_run.errors.sub(/inspect/, ''), test_run.errors.sub(/test/, ''))
	else 
		help_run.assert_post_conditions
		inspect_run.assert_post_conditions
		test_run.assert_post_conditions
	end # case
#	assert_equal('', help_run.errors)
#	assert_equal('', help_run.output)
end #non_interactive_scripts
end #CommandLine
