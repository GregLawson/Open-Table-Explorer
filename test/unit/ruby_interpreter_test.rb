###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require 'active_support' # for singularize and pluralize
require_relative '../../app/models/regexp.rb'
require_relative '../../app/models/parse.rb'
require_relative '../../app/models/ruby_interpreter.rb'

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
    assert_match(Ruby_version_regexp, RUBY_ENGINE_VERSION)
    assert_match(/ruby/, RUBY_DESCRIPTION)

    assert_instance_of(Fixnum, RUBY_REVISION)
    assert_operator(0, :<=, RUBY_REVISION)
		assert_match(Ruby_version_regexp, RUBY_VERSION)
		assert_instance_of(Class, RubyVM)
		assert_equal([], RubyVM.instance_variables)
		assert_equal([:stat], RubyVM.methods(false))
		assert_equal({:global_method_state=>213, :global_constant_state=>3091, :class_serial=>50169}, RubyVM.stat)
  end # DefinitionalConstants

  def test_virtus_initialize
    Ruby_versions.each do |executable_file|
      assert(File.exist?(executable_file), Ruby_versions)
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
    refute_empty(RubyInterpreter.shell('pwd', &:inspect))
  end # shell

  def test_initialize
  end # initialize
end # RubyInterpreter
