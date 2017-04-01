###########################################################################
#    Copyright (C) 2011-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative 'test_environment'
require_relative '../../app/models/unit.rb'
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/regexp.rb'
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/acquisition.rb'
require_relative '../../app/models/version.rb'
class VersionTest < TestCase
  module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
#    include DefinitionalConstants
    include Version::Constants
    Consecutive_string = '1.2.3'.freeze

    Sorted_version_names = ['1.9.0', '1.10.0', '1.11.0.'].freeze
    First_example_version_name = Sorted_version_names[0]
    First_example_version = Version.new_from_string(First_example_version_name)
    Ruby_version = Acquisition.new(uri_string: 'shell:ruby -v', generic_type: Version::Semantic_version_regexp) # system version
    Linux_version = Acquisition.new(uri_string: 'shell:uname -a', generic_type: Version::Semantic_version_regexp) # system version
    Ruby_file_version = Acquisition.new(uri_string: 'file /usr/bin/ruby2.2', generic_type: Version::Semantic_version_regexp)
  end # Examples
	include Examples
	
  def test_Constants
    assert_match(Version_digits, Consecutive_string)
    assert_match(Version_digits.capture(:major) * '.', Consecutive_string)
    assert_match(Version_digits.capture(:major) * '.' * Version_digits.capture(:minor) * '.', Consecutive_string)
    assert_match(Version_digits.capture(:major) * '.' * Version_digits.capture(:minor) * '.' * Version_digits.capture(:patch), Consecutive_string)
    assert_match(Version_digits.capture(:major) * '.' * Version_digits.capture(:minor) * '.' * Version_digits.capture(:patch) * (/[-+.]/ * /[-.a-zA-Z0-9]*/.capture(:pre_release)).group * Regexp::Optional, Consecutive_string)
    assert_match(Version_digits.capture(:major) * '.' * Version_digits.capture(:minor) * '.' * Version_digits.capture(:patch) * (/[-+.]/ * /[-.a-zA-Z0-9]*/.capture(:pre_release)).group * Regexp::Optional, Consecutive_string)
    assert_match(Semantic_version_regexp, Consecutive_string)
  end # Constants

  def test_value_object
    new_version = Version.new
    assert_equal('0', new_version.major, new_version.inspect)
    assert_equal('0', new_version.minor, new_version.inspect)
    assert_equal('0', new_version.patch, new_version.inspect)
    assert_equal('0', new_version.pre_release, new_version.inspect)
    new_args = Version.new(major: '1', minor: '2', patch: '3', pre_release: '4')
    assert_equal('1', new_args.major, new_args.inspect)
    assert_equal('2', new_args.minor, new_args.inspect)
    assert_equal('3', new_args.patch, new_args.inspect)
    assert_equal('4', new_args.pre_release, new_args.inspect)
  end # values

  def test_new_from_string
    string = '1.2.3'
    parse = Consecutive_string.parse(Semantic_version_regexp)
    assert_instance_of(Hash, parse)
    assert_equal('1', parse[:major], parse.inspect)
    assert_equal('2', parse[:minor], parse.inspect)
    assert_equal('3', parse[:patch], parse.inspect)
    assert_equal(nil, parse[:pre_release], parse.inspect)
    new_args = Version.new(major: '1', minor: '2', patch: '3', pre_release: '4')
    assert_equal('1', new_args.major, new_args.inspect)
    assert_equal('2', new_args.minor, new_args.inspect)
    assert_equal('3', new_args.patch, new_args.inspect)
    assert_equal('4', new_args.pre_release, new_args.inspect)
    version = Version.new(major: parse[:major], minor: parse[:minor], patch: parse[:patch], pre_release: parse[:pre_release])
    assert_equal('1', version.major, version.inspect)
    assert_equal('2', version.minor, version.inspect)
    assert_equal('3', version.patch, version.inspect)
    assert_equal(nil, version.pre_release, version.inspect)
    new_from_string = Version.new_from_string(Consecutive_string)
    assert_equal('1', new_from_string.major, new_from_string.inspect)
  end # new_from_string

  def test_ruby_version
    executable_suffix = ''
    ruby_interpreter = Version.new(test_command: 'ruby', options: '--version')
    parse = ruby_interpreter.attributes
    assert_instance_of(Hash, parse)
    assert_operator(parse[:major], :>=, '0')
    assert_operator(parse[:minor], :>=, '0')
    assert_operator(parse[:patch], :>=, '0')
    assert_instance_of(String, parse[:pre_release])
  end # ruby_version

  def test_Version_Examples
    assert_match(/[1-9]?[0-9]{1,3}/, '1.9.0')
    assert_match(Version_digits, First_example_version_name)
    parsed_version_string = First_example_version_name.parse(Semantic_version_regexp)
    assert_equal({ major: '1', minor: '9', patch: '0', pre_release: nil }, parsed_version_string)
    first_example_version = Version.new_from_string(First_example_version_name)
  end # Examples
end # Version

class ReportedVersionTest < TestCase
  module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
    include ReportedVersion::DefinitionalConstants
    Ruby_version = ReportedVersion.new(test_command: 'ruby') # system version
    Ruby_whereis = Ruby_version.whereis
    Ruby_which = Ruby_version.which
    Linux_version = ReportedVersion.new(test_command: 'uname', version_reporting_option: '-a') # system version
    Ruby_file_version = ReportedVersion.new(test_command: 'file /usr/bin/ruby2.2', version_reporting_option: '')
  end # Examples
	include Examples

		def test_acquisition
		end # acquisition
	
	def test_to_hash
	end # to_hash

		def test_acquire!
		end # acquire
  include ReportedVersion::DefinitionalConstants
  def test_ReportedVersion_DefinitionalConstants
    assert_match(/.1.gz/, Ruby_whereis)
    assert_match(/[a-z]+/ * /.1.gz/, Ruby_whereis)
    assert_match(/usr/, Ruby_whereis)
    assert_match(/\/usr/, Ruby_whereis)
    assert_match(/\/usr\/share\/man\/man1\//, Ruby_whereis)
    assert_match(/\/usr\/share\/man\/man1\// * /[a-z]+/ * /.1.gz/, Ruby_whereis)
    assert_match(Bin_regexp, Ruby_whereis)
    assert_match(Lib_regexp, Ruby_whereis)
    assert_match(Man_regexp, Ruby_whereis)
    assert_match(/ruby: / * Bin_regexp, Ruby_whereis)
    assert_match(Bin_regexp * / / * Lib_regexp, Ruby_whereis)
    assert_match(/ruby: / * Bin_regexp * / / * (Bin_regexp * / /).group * Regexp::Any * Lib_regexp * / / * Man_regexp, Ruby_whereis)
    #	assert_match(Whereis_regexp, Ruby_whereis)
  end # DefinitionalConstants

  def test_virtus_initialize
  end # virtus_initialize

  def test_DefinitionalConstants
  end # DefinitionalConstants

  def test_which
    ruby_version = ReportedVersion.new(test_command: 'ruby') # system version
    assert_equal('/usr/bin/ruby', ruby_version.which, ruby_version.inspect)
    #	assert_equal("/usr/bin/ruby\n", ruby_version.version_report, ruby_version.inspect)
  end # which

  def test_whereis
    ruby_version = ReportedVersion.new(test_command: 'ruby') # system version
    capture = ruby_version.whereis.capture?(Whereis_regexp)
    #	assert_equal('/usr/lib/ruby', capture.output[:pathname], capture.inspect)
		whereis_acq = Acquisition.new(uri_string: 'shell:whereis ' + 'ruby', ) # system version
  end # whereis

  def test_versions
  end # versions

  def test_Examples
  end # Examples
end # ReportedVersion
