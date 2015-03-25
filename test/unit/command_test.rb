###########################################################################
#    Copyright (C) 2012-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/command.rb'
class CommandTest < TestCase
include DefaultTests
include TE.model_class?::Examples
def test_paths?
	Command.paths?.each do |path|
		assert_pathname_exists(path)
	end # each
end # paths?
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
def test_what_is?
	assert_match(/find/, Command.new('find').what_is?)
end # what_is?
def test_where_is?
	Command.new('find').where_is?.each do |path|
		assert_match(/find/, path)
	end # each
end # where_is?
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
end # Command
