###########################################################################
#    Copyright (C) 2014-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'virtus'
# require_relative '../../app/models/no_db.rb'
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/parse.rb'
require_relative '../../app/models/file_pattern.rb'
require_relative '../../app/models/file_tree.rb'
require_relative '../../config/initializers/backup.rb'

class Backup # pure class, maybe should be Module?, but Virtus inherits poorly
  module ClassMethods
  end # ClassMethods
  extend ClassMethods
  module DefinitionalConstants
		Default_dry_run = lambda do |backup, attribute|
			backup.run(dry_run: true, minimize: true)
		end # Default_dry_run
  end # DefinitionalConstants
  include DefinitionalConstants
  include Virtus.value_object
  values do
    attribute :source_dir, Pathname
    attribute :backup_dir, Pathname
		attribute :recursive, Object, default: true
		attribute :dry_run, Object, default: false
		attribute :minimize, Object, default: false
  end # values

  require_relative '../../app/models/assertions.rb'
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
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
end # Backup

class Rsync < Backup
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
		Integer_with_commas_regexp = /[0-9,]+/
		Float_with_commas_regexp = Integer_with_commas_regexp * /\.[0-9]{2}/
		Stats_regexp = /sent / * Integer_with_commas_regexp * / bytes  received / * Integer_with_commas_regexp * / bytes  / * Float_with_commas_regexp * / bytes\/sec\ntotal size is / * Integer_with_commas_regexp * /  speedup is / * Float_with_commas_regexp * / \(DRY RUN\)\n/
		Rsync_regexp = /sending/ | Stats_regexp |
			/skipping directory / * (FilePattern::Relative_pathname_included_regexp.capture(:skip_path) * /\n/) | 
			(FilePattern::Relative_pathname_included_regexp.capture(:path) * /\n/)
  end # DefinitionalConstants
  include DefinitionalConstants

  module DefinitionalClassMethods
		def each(added_options = { recursive: true, dry_run: false })
			Backup_directories.each_pair do |directory_map, sub_directory_map|
				directory_map.each_pair do |source_dir, backup_dir|
					sub_directory_map.each_pair do |source_sub_directory, backup_sub_directory|
						backup = Rsync.new(source_dir: source_dir + source_sub_directory, 
							backup_dir: backup_dir + backup_sub_directory, recursive: false, dry_run: true)
						yield(backup)
					end # each_pair
				end # each_pair
			end # each_pair
		end # each
		
		def map(added_options = { recursive: true, dry_run: false })
			ret =[]
			each(added_options) do |backup|
				ret << backup
			end # each
			ret
		end # map
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods

  include Virtus.value_object
  values do
    attribute :options, String, :default => '--archive --verbose --update --links --ignore-existing'
		attribute :cached_shell_command, ShellCommands, default: Default_dry_run 
  end # values

	def options_string(added_options = { recursive: true, dry_run: false })
		@options + ' ' + (@recursive ? '--recursive' : '--no-recursive') + 
							 ' ' + (@dry_run ? '--dry-run' : '--no-dry-run') + 
							 ' ' + (@minimize ? '--dirs --no-recursive' : '--recursive')
	end # options_string
	
	def command_string(added_options = { recursive: true, dry_run: false })
    command_string = 'rsync ' + options_string + ' ' + ' ' + Shellwords.escape(@source_dir) + '* ' + Shellwords.escape(@backup_dir)
	end # command_string
	
	def run(added_options)
		@cached_shell_command = ShellCommands.new(command_string(added_options))
	end # run
	
	def planned_backup(added_options = ' --dry-run ')
		@cached_shell_command = run(added_options)
#		@cached_shell_command.output.capture?(Rsync_regexp, SplitCapture)
	end # planned_backup

	def write_all(file_name, added_options)
		log_file = IO.open(Unit::Executing.data_source_directory + file_name)
		Rsync.each(dry_run: true, minimize: true, recursive:false) do |backup|
			run = backup.planned_backup(added_options)
			log_file.write(run.output)
			end # each
	end # write_all

	def minimal_dry_run_all
		write_all('minimal_dry_run_all.log', dry_run: true, minimize: true, recursive:false)
	end # minimal_dry_run_all

	def full_dry_run_all
		write_all('full_dry_run_all.log', dry_run: true, minimize: false, recursive:true)
	end # full_dry_run_all

	def backup_all
		write_all('backup_all.log', dry_run: false, minimize: false, recursive:true)
	end # backup_all

  def backup
    run(' ')
  end # backup

  def merge_back
    command_string = 'rsync ' + options_string + ' ' + @backup_dir + '* ' + @source_dir
    ShellCommands.new(command_string)
  end # merge_back
  require_relative '../../app/models/assertions.rb'
  module Assertions
    module ClassMethods
      def assert_pre_conditions(message = '')
        message += "In assert_pre_conditions, self=#{inspect}"
        self
      end # assert_pre_conditions

      def assert_post_conditions(message = '')
        message += "In assert_post_conditions, self=#{inspect}"
        self
      end # assert_post_conditions
    end # ClassMethods
		include RubyAssertions
    def assert_pre_conditions(message = '')
      message += "In assert_pre_conditions, self=#{inspect}"
      refute_nil(@source_dir, message)
      refute_nil(@backup_dir, message)
      refute_nil(@recursive, message)
      refute_nil(@options, message)
      refute_nil(options_string, message)
			assert_directory_exists(@source_dir)
			assert_kind_of(Backup, self)
			assert_instance_of(Rsync, self)
      self
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
      message += "In assert_post_conditions, self=#{inspect}"
			assert_directory_exists(@backup_dir)
			message = 'cached_shell_command is not initialized; check default. ' + inspect
			assert_instance_of(ShellCommands, @cached_shell_command, message)
      self
    end # assert_post_conditions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # self.assert_pre_conditions
  module Examples
    include DefinitionalConstants
  end # Examples
end # Rsync
