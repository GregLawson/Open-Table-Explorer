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
class RubyVersion < ReportedVersion
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
    Ruby_version_regexp = Version::Semantic_version_regexp
    Ruby_versions = Dir['/usr/bin/ruby[0-9]']
    Ruby_pattern = /ruby / * Ruby_version_regexp
    Parenthetical_date_pattern = / \(/ * /20[0-9]{2}-[01][0-9]-[0-3][0-9]/.capture(:compile_date) * /\)/
    Bracketed_os = / \[/ * /[-_a-z0-9]+/ * /\]/ * "\n"
    Version_pattern = [Ruby_pattern, Parenthetical_date_pattern, Bracketed_os].freeze
    Ruby_version = ShellCommands.new('ruby --version').output
    Preferred = RubyVersion.new(test_command: 'ruby', logging: :silence, minor_version: '2.2', patch_version: '2.2.3p173')
  end # DefinitionalConstants
  include DefinitionalConstants
  module ClassMethods
    def ruby_version(_executable_suffix = '')
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
  # include DefinitionalConstants
  include Virtus.value_object
  values do
    attribute :options, String, default: '-W0'
    attribute :processor_version, RubyVersion, default: RubyVersion::Preferred # system version
    attribute :logging, Symbol, default: :silence
    attribute :minor_version, String, default: '2.2'
    attribute :patch_version, String, default: '2.2.3p173'
  end # values
  module DefinitionalConstants
    include Version::Constants
    Preferred = RubyInterpreter.new(options: '-W0', logging: :silence, minor_version: '2.2', patch_version: '2.2.3p173')
  end # DefinitionalConstants
  include DefinitionalConstants
  # include Generic_Table
  # has_many :bugs
  module ClassMethods
    def shell(command)
      #	puts "command='#{command}'"
      run = ShellCommands.new(command)
      if block_given?
        yield(run)
      else
        run.assert_post_conditions
      end # if
    end # shell

    # Run rubyinterpreter passing arguments
    def ruby(args, &proc)
      shell("ruby #{args}", &proc)
    end # ruby
  end # ClassMethods
  extend ClassMethods
  # attr_reader
  require_relative '../../test/assertions.rb'
  module Assertions
    module ClassMethods
      def assert_pre_conditions(message = '')
        message += "In assert_pre_conditions, self=#{inspect}"
      end # assert_pre_conditions

      def assert_post_conditions(message = '')
        message += "In assert_post_conditions, self=#{inspect}"
      end # assert_post_conditions
    end # ClassMethods
    def assert_pre_conditions(message = '')
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
    end # assert_post_conditions

    def assert_logical_primary_key_defined(message = nil)
      message = build_message(message, 'self=?', inspect)
      refute_nil(self, message)
      assert_instance_of(RubyInterpreter, self, message)

      #	puts "self=#{self.inspect}"
      refute_nil(attributes, message)
      refute_nil(self[:test_type], message)
      refute_nil(test_type, message)
      refute_nil(self['test_type'], message)
      refute_nil(singular_table, message)
    end # assert_logical_primary_key_defined
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # self.assert_pre_conditions
  module Examples
    include DefinitionalConstants
  end # Examples
end # RubyInterpreter
