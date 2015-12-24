###########################################################################
#    Copyright (C) 2011-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require 'active_support' # for singularize and pluralize
require_relative '../../app/models/regexp.rb'
require_relative '../assertions/shell_command_assertions.rb'
require_relative '../../app/models/ruby_interpreter.rb'
class ReportedVersionTest < TestCase
include ReportedVersion::Examples
include ReportedVersion::DefinitionalConstants
def test_ReportedVersion_DefinitionalConstants
	assert_match(/.1.gz/, Ruby_whereis)
	assert_match(/[a-z]+/ * /.1.gz/, Ruby_whereis)
	assert_match(/usr/ , Ruby_whereis)
	assert_match(/\/usr/ , Ruby_whereis)
	assert_match(/\/usr\/share\/man\/man1\//, Ruby_whereis)
	assert_match(/\/usr\/share\/man\/man1\// * /[a-z]+/ * /.1.gz/, Ruby_whereis)
	assert_match(Bin_regexp, Ruby_whereis)
	assert_match(Lib_regexp, Ruby_whereis)
	assert_match(Man_regexp, Ruby_whereis)
	assert_match(/ruby: / * Bin_regexp, Ruby_whereis)
	assert_match(Bin_regexp * / / * Lib_regexp, Ruby_whereis)
	assert_match(/ruby: / * Bin_regexp * / /  * (Bin_regexp * / /).group * Regexp::Any * Lib_regexp * / / * Man_regexp, Ruby_whereis)
#	assert_match(Whereis_regexp, Ruby_whereis)
end # DefinitionalConstants
def test_virtus_initialize
end # virtus_initialize
def test_DefinitionalConstants
end # DefinitionalConstants
def test_which
	ruby_version = ReportedVersion.new(test_command: 'ruby')  # system version
	assert_equal("/usr/bin/ruby", ruby_version.which, ruby_version.inspect)
#	assert_equal("/usr/bin/ruby\n", ruby_version.version_report, ruby_version.inspect)
end # which
def test_whereis
	ruby_version = ReportedVersion.new(test_command: 'ruby')  # system version
	capture = ruby_version.whereis.capture?(Whereis_regexp)
#	assert_equal('/usr/lib/ruby', capture.output?[:pathname], capture.inspect)
end # whereis
def test_versions
end # versions
def test_Examples
end # Examples
end # ReportedVersion

class RubyVersionTest < TestCase
include RubyVersion::Examples
include RubyVersion::DefinitionalConstants
def test_RubyVersion_DefinitionalConstants
	assert_match(Ruby_pattern, Ruby_version)
	assert_match(Parenthetical_date_pattern, Ruby_version)
	assert_match(Bracketed_os, Ruby_version)
	so_far = Ruby_version.capture?(Ruby_pattern | Parenthetical_date_pattern)
	assert(so_far.success?, so_far.inspect)
#	assert_match(Ruby_pattern * / /, Ruby_version)
#	assert_match(Ruby_pattern * / / * Parenthetical_date_pattern, Ruby_version)
	assert_match(Parenthetical_date_pattern * Bracketed_os, Ruby_version)
#	assert_match(Version_pattern, Ruby_version)
end # DefinitionalConstants
def test_virtus_initialize
	Ruby_versions.each do |executable_file|
		assert(File.exists?(executable_file), Ruby_versions)
	end # each
	end # values
def test_ruby_version
	executable_suffix = ''
	parse = Ruby_version.parse(Version_pattern)
#	assert_instance_of(Hash, parse)
#	assert_operator(parse[:major], :>=, '1')
#	assert_operator(parse[:minor], :>=, '1')
#	assert_operator(parse[:patch], :>=, '1')
#	assert_instance_of(String, parse[:pre_release])
end # ruby_version
end # RubyVersion

class RubyInterpreterTest < TestCase
include RubyInterpreter::Examples
include RubyInterpreter::DefinitionalConstants
def test_RubyInterpreter_DefinitionalConstants
end # DefinitionalConstants
def test_shell
	refute_empty(RubyInterpreter.shell('pwd'){|run| run.inspect})
end #shell
def test_initialize

end #initialize
end # RubyInterpreter
