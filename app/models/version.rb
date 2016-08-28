###########################################################################
#    Copyright (C) 2011-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'virtus'
require_relative '../../app/models/no_db.rb'
require 'fileutils'
require_relative '../../app/models/parse.rb'
# see http://semver.org/
class Version # semantic version and base class for incompatible versioning convertions
  # see http://semver.org/
  module Constants # constant parameters of the type (suggest all CAPS)
    Version_digits = /[1-9]?[0-9]{1,3}/ # 1 to 9999 or 0 to 099 ? counter-examples in the wild?

    Major_minor_regexp = Version_digits.capture(:major) * '.' * Version_digits.capture(:minor)
    Major_minor_patch_regexp = Major_minor_regexp * '.' * Version_digits.capture(:patch)
    Semantic_version_regexp = Major_minor_patch_regexp * (/[-+.]/ * /[-.a-zA-Z0-9]*/.capture(:pre_release)).group * Regexp::Optional
  end # Constants
  include Constants
  include Virtus.value_object
  values do
    attribute :major, String, default: '0' # system version
    attribute :minor, String, default: '0'
    attribute :patch, String, default: '0'
    attribute :pre_release, String, default: '0'
    attribute :regexp, Regexp, default: Semantic_version_regexp
    attribute :source_string, String
  end # values
  module ClassMethods
    include Constants
    def new_from_string(string)
      parse = string.parse(Semantic_version_regexp)
      Version.new(major: parse[:major], minor: parse[:minor], patch: parse[:patch], pre_release: parse[:pre_release])
    end # new_from_string
  end # ClassMethods
  extend ClassMethods
  # require_relative '../../app/models/assertions.rb'
  module Assertions
    module ClassMethods
      def nested_scope_modules?(context = self)
        nested_constants = context.class.constants
        nested_constants.select do |constant|
          constant.class == Module
        end # select
      end # nested_scopes

      def assert_nested_scope_submodule(_module_symbol, context = self, message = '')
        message += "\nIn assert_nested_scope_submodule for class #{context.name}, "
        message += "make sure module Constants is nested in #{context.class.name.downcase} #{context.name}"
        message += " but not in #{context.nested_scope_modules?.inspect}"
        assert_includes(constants, :Contants, message)
      end # assert_included_submodule

      def assert_included_submodule(_module_symbol, _context = self, message = '')
        message += "\nIn assert_included_submodule for class #{name}, "
        message += "make sure module Constants is nested in #{self.class.name.downcase} #{name}"
        message += " but not in #{nested_scope_modules?.inspect}"
        assert_includes(included_modules, :Contants, message)
      end # assert_included_submodule

      def asset_nested_and_included(module_symbol, _context = self, _message = '')
        assert_nested_scope_submodule(module_symbol)
        assert_included_submodule(module_symbol)
      end # asset_nested_and_included

      def assert_pre_conditions(_message = '')
        asset_nested_and_included(:ClassMethods, self)
        asset_nested_and_included(:Constants, self)
        asset_nested_and_included(:Assertions, self)
      end # assert_pre_conditions

      def assert_post_conditions(message = '')
        message += "In assert_post_conditions, self=#{inspect}"
      end # assert_post_conditions
    end # ClassMethods
    def assert_pre_conditions(message = '')
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
    end # assert_post_conditions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # self.assert_pre_conditions
  module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
    include Version::Constants
    Consecutive_string = '1.2.3'.freeze

    Sorted_version_names = ['1.9.0', '1.10.0', '1.11.0.'].freeze
    First_example_version_name = Sorted_version_names[0]
    First_example_version = Version.new_from_string(First_example_version_name)
  end # Examples
end # Version

require_relative '../../app/models/shell_command.rb'

class Acquisition
  include Virtus.value_object
  values do
    attribute :generic_type, Regexp
  end # values

	def acquisition
		if @cached_acquisition.nil?
			@cached_acquisition = acquire!
		else
			@cached_acquisition
		end # if
	end # acquisition
	
	def to_hash
		if @cached_to_hash.nil?
			@cached_to_hash = acquisition.capture?(@generic_type).output
		else
			@cached_to_hash
		end # if
	end # to_hash
end # Acquisition

class ShellAcquisition < Acquisition
  include Virtus.value_object
  values do
    attribute :acquisition, String
  end # values

	def acquire!
    ShellCommands.new(@acquisition_string).output
	end # acquire
  module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
#    include DefinitionalConstants
    Ruby_version = ShellAcquisition.new(acquisition: 'ruby') # system version
    Linux_version = ShellAcquisition.new(acquisition: 'uname -a') # system version
    Ruby_file_version = ShellAcquisition.new(acquisition: 'file /usr/bin/ruby2.2')
  end # Examples
end # ShellAcquisition

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
    attribute :version_reporting_option, String, default: '--version'
    attribute :version_report, String, default: ->(version, _attribute) { ShellCommands.new(version.test_command + ' ' + version.version_reporting_option).output }
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
    Ruby_version = ReportedVersion.new(test_command: 'ruby') # system version
    Ruby_whereis = Ruby_version.whereis
    Ruby_which = Ruby_version.which
    Linux_version = ReportedVersion.new(test_command: 'uname', version_reporting_option: '-a') # system version
    Ruby_file_version = ReportedVersion.new(test_command: 'file /usr/bin/ruby2.2', version_reporting_option: '')
  end # Examples
end # ReportedVersion
