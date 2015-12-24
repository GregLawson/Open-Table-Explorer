###########################################################################
#    Copyright (C) 2011-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/no_db.rb'
require 'virtus'
require_relative '../../app/models/version.rb'
require_relative '../../app/models/shell_command.rb'
class ReportedVersion < Version # version can be reported by a command
module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
Man_regexp = /\/usr\/share\/man\/man1\// * /[a-z]+/ * /.1.gz/.capture(:man_path)
Lib_regexp = /\/usr\/lib\// * /[a-z]+/.capture(:lib_path)
Bin_regexp = /\/usr\/bin\// * /[a-z0-9.]+/.capture(:bin_path)
Whereis_regexp = /ruby: / * Man_regexp
end # DefinitionalConstants
include DefinitionalConstants
  include Virtus.value_object
  values do
  attribute :test_command, String
  attribute :version_reporting_option, String, :default => '--version'
  attribute :version_report, String, :default => lambda { |version, attribute| ShellCommands.new(version.test_command + ' ' + version.version_reporting_option).output }
	end # values
def which
	ShellCommands.new('which ' + @test_command).output.chomp
end # which
def whereis
	ShellCommands.new('whereis ' + @test_command).output
end # whereis
def versions
end # versions
module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
include DefinitionalConstants
Ruby_version = ReportedVersion.new(test_command: 'ruby')  # system version
Ruby_whereis = Ruby_version.whereis
Ruby_which = Ruby_version.which
Linux_version = ReportedVersion.new(test_command: 'uname', version_reporting_option: '-a')  # system version
Ruby_file_version = ReportedVersion.new(test_command: 'file /usr/bin/ruby2.2', version_reporting_option: '')
end # Examples
end # ReportedVersion

class RubyVersion < ReportedVersion
module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
Ruby_version_regexp = Version::Semantic_version_regexp
Ruby_versions = Dir['/usr/bin/ruby[0-9]']
Ruby_pattern = /ruby / * Ruby_version_regexp
Parenthetical_date_pattern = / \(/ * /20[0-9]{2}-[01][0-9]-[0-3][0-9]/.capture(:compile_date) * /\)/
Bracketed_os = / \[/ * /[-_a-z0-9]+/ * /\]/ * "\n"
Version_pattern = [Ruby_pattern, Parenthetical_date_pattern, Bracketed_os]
Ruby_version = ShellCommands.new('ruby --version').output
end # DefinitionalConstants
include DefinitionalConstants
module ClassMethods
def ruby_version(executable_suffix = '')
	ShellCommands.new('ruby --version').output.split(' ')
	testRun = RubyInterpreter.new(test_command: 'ruby', options: '--version').run
	testRun.output.parse(Version_pattern).output
end # ruby_version
end # ClassMethods
extend ClassMethods
end # RubyVersion

require 'fileutils'
require_relative '../../app/models/version.rb'

class RubyInterpreter # < ActiveRecord::Base
module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
Preferred = RubyVersion.new(test_command: 'ruby', logging: :silence, minor_version: '2.2', patch_version: '2.2.3p173')
end # DefinitionalConstants
include DefinitionalConstants
  include Virtus.value_object
  values do
  attribute :options, String, :default => '-W0'
  attribute :processor_version, RubyVersion, :default => Preferred # system version
  attribute :logging, Symbol, :default => :silence
  attribute :minor_version, String, :default => '2.2'
  attribute :patch_version, String, :default => '2.2.3p173'
	end # values
module DefinitionalConstants
include Version::Constants
Preferred = RubyInterpreter.new(options: '-W0', logging: :silence, minor_version: '2.2', patch_version: '2.2.3p173')
end # DefinitionalConstants
include DefinitionalConstants
#include Generic_Table
#has_many :bugs
module ClassMethods
def shell(command, &proc)
#	puts "command='#{command}'"
	run =ShellCommands.new(command)
	if block_given? then
		proc.call(run)
	else
		run.assert_post_conditions
	end # if
end #shell
# Run rubyinterpreter passing arguments
def ruby(args, &proc)
	shell("ruby #{args}",&proc)
end #ruby
end # ClassMethods
extend ClassMethods
# attr_reader
def assert_logical_primary_key_defined(message=nil)
	message=build_message(message, "self=?", self.inspect)	
	refute_nil(self, message)
	assert_instance_of(RubyInterpreter,self, message)

#	puts "self=#{self.inspect}"
	refute_nil(self.attributes, message)
	refute_nil(self[:test_type], message)
	refute_nil(self.test_type, message)
	refute_nil(self['test_type'], message)
	refute_nil(self.singular_table, message)
end #assert_logical_primary_key_defined
module Examples
include DefinitionalConstants
end # Examples
end # RubyInterpreter
