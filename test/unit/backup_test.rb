###########################################################################
#    Copyright (C) 2014-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative 'test_environment'
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/backup.rb'
require_relative '../../config/initializers/backup.rb'
class BackupTest < TestCase
#include DefaultTests
#include RailsishRubyUnit::Executable.model_class?::Examples
include RubyAssertions
	module Examples
		File_and_stat = "sharedConfig/ruby-pg-0.8.0/spec/pgresult_spec.rb\nsharedConfig/ruby-pg-0.8.0/spec/data/\nsharedConfig/ruby-pg-0.8.0/spec/data/expected_trace.out\nsharedConfig/ruby-pg-0.8.0/spec/data/random_binary_data\ntotal: matches=0  hash_hits=0  false_alarms=0 data=0\n\nsent 10,240,877 bytes  received 12,358,064 bytes  367,462.46 bytes/sec\ntotal size is 1,426,535,739,545  speedup is 63,124.01 (DRY RUN)\n"
		Dry_run = Rsync.map(dry_run: true, recursive:false) do |backup|
				backup.run(dry_run: true)
			end # each
	end # Examples
	include Examples

	def test_config
		deeper_plan ={}
	Backup_directories.each_pair do |directory_map, sub_directory_map|
		directory_map.each_pair do |source_dir, backup_dir|
			assert_directory_exists(source_dir)
			assert(File.exist?(backup_dir), backup_dir)
			assert_directory_exists(backup_dir)
			sub_directory_map.each_pair do |source_sub_directory, backup_sub_directory|
				assert_directory_exists(source_dir + source_sub_directory)
				assert_directory_exists(backup_dir + backup_sub_directory)
					deeper_plan = { { source_dir => backup_dir} => {source_sub_directory => backup_sub_directory} }
			end # each_pair
		end # each_pair
	end # each_pair
		assert_equal(deeper_plan, Backup_directories)
	end # config

	def test_Constants
		assert_match(FilePattern::Relative_pathname_included_regexp.capture(:path) * /\n/, File_and_stat)
		assert_match(Rsync::Examples::Stats_regexp, File_and_stat)
		Dry_run.each do |backup_run|
			assert_match(/skipping directory / * (FilePattern::Relative_pathname_regexp.capture(:skip_path) * /\n/), backup_run.output)
			assert_match(FilePattern::Relative_pathname_regexp.capture(:path) * /\n/, backup_run.output)
			assert_match(Rsync::Examples::Rsync_regexp, backup_run.output)
			assert_match(Rsync::Examples::Stats_regexp, backup_run.output)
		end # each
  end # Constants
end # Backup

class RsyncTest < TestCase
include Rsync::Examples
	module Examples
		File_and_stat = "sharedConfig/ruby-pg-0.8.0/spec/pgresult_spec.rb\nsharedConfig/ruby-pg-0.8.0/spec/data/\nsharedConfig/ruby-pg-0.8.0/spec/data/expected_trace.out\nsharedConfig/ruby-pg-0.8.0/spec/data/random_binary_data\ntotal: matches=0  hash_hits=0  false_alarms=0 data=0\n\nsent 10,240,877 bytes  received 12,358,064 bytes  367,462.46 bytes/sec\ntotal size is 1,426,535,739,545  speedup is 63,124.01 (DRY RUN)\n"
		Dry_run = Rsync.map(dry_run: true, minimize: true, recursive:false) do |backup|
			assert_kind_of(Backup, backup)
			assert_instance_of(Rsync, backup)
			backup.assert_pre_conditions
			backup.assert_post_conditions
			run =	backup.planned_backup(dry_run: true)
			backup.assert_post_conditions
			assert_instance_of(ShellCommands, run)
			assert_instance_of(ShellCommands, backup.cached_shell_command)
			backup
			end # each
	end # Examples
	include Examples
 	def test_Rsync_DefinitionalConstants
		assert_match(FilePattern::Relative_pathname_included_regexp.capture(:path) * /\n/, File_and_stat)
		assert_match(Integer_with_commas_regexp, File_and_stat)
		assert_match(Float_with_commas_regexp, File_and_stat)
		assert_match(Rsync_regexp, File_and_stat)
		assert_match(/sent / * Integer_with_commas_regexp * / bytes  received /, File_and_stat)
		assert_match(/sent / * Integer_with_commas_regexp * / bytes  received / * Integer_with_commas_regexp * / bytes  /, File_and_stat)
		assert_match(/sent / * Integer_with_commas_regexp * / bytes  received / * Integer_with_commas_regexp * / bytes  / * Float_with_commas_regexp, File_and_stat)
		assert_match(/sent / * Integer_with_commas_regexp * / bytes  received / * Integer_with_commas_regexp * / bytes  / * Float_with_commas_regexp * / bytes\/sec\ntotal size is /, File_and_stat)
		assert_match(/sent / * Integer_with_commas_regexp * / bytes  received / * Integer_with_commas_regexp * / bytes  / * Float_with_commas_regexp * / bytes\/sec\ntotal size is / * Integer_with_commas_regexp, File_and_stat)
		assert_match(/sent / * Integer_with_commas_regexp * / bytes  received / * Integer_with_commas_regexp * / bytes  / * Float_with_commas_regexp * / bytes\/sec\ntotal size is / * Integer_with_commas_regexp * /  speedup is /, File_and_stat)
		assert_match(/sent / * Integer_with_commas_regexp * / bytes  received / * Integer_with_commas_regexp * / bytes  / * Float_with_commas_regexp * / bytes\/sec\ntotal size is / * Integer_with_commas_regexp * /  speedup is / * Float_with_commas_regexp, File_and_stat)
		assert_match(                                                             Integer_with_commas_regexp * / bytes  / * Float_with_commas_regexp * / bytes\/sec\ntotal size is / * Integer_with_commas_regexp * /  speedup is / * Float_with_commas_regexp * / \(DRY RUN\)\n/, File_and_stat)
		assert_match(Stats_regexp, File_and_stat)
		Dry_run.each do |backup|
			backup.assert_pre_conditions
			backup.assert_post_conditions
			assert_instance_of(ShellCommands, backup.cached_shell_command, backup.inspect) # fail nil
			output = backup.cached_shell_command.output

			assert_match(/skipping directory / * (FilePattern::Relative_pathname_regexp.capture(:skip_path) * /\n/), backup.cached_shell_command.output)
			assert_match(FilePattern::Relative_pathname_regexp.capture(:path) * /\n/, backup.cached_shell_command.output)
			assert_match(Rsync::Examples::Rsync_regexp, backup.cached_shell_command.output)
			assert_match(Rsync::Examples::Stats_regexp, backup.cached_shell_command.output)
		end # each
  end # DefinitionalConstants
	
		def test_each
			Rsync.each(recursive: false, options: '') do |backup|
				backup.assert_pre_conditions
			end # each
		end # each
		
		def test_map
			Rsync.map do |backup|
			end # map
		end # map


	def test_Virtus_values
  end # values

	def test_options_string
	end # options_string

def test_command_string
			Rsync.each(recursive: false, options: '') do |backup|
				assert_match(/rsync/, backup.command_string)
			end # each
end # command_string

def test_planned_backup
	Backup_directories.each_pair do |directory_map, sub_directory_map|
		directory_map.each_pair do |source_dir, backup_dir|
			sub_directory_map.each_pair do |source_sub_directory, backup_sub_directory|
				backup = Rsync.new(source_dir: source_dir + source_sub_directory, 
					backup_dir: backup_dir + backup_sub_directory,
					recursive: false)
				planned_backup = backup.planned_backup
				refute_empty(planned_backup.output, backup.inspect)
				proposed_copies = planned_backup.capture?(Rsync_regexp)
				proposed_copies.each do |relative_path|
					file_to_copy = source_dir + source_sub_directory + relative_path
					assert_pathname_exists(file_to_copy)
				end # each
			end # map
		end # each_pair
	end # map
end # planned_backup

    def test_assert_pre_conditions
			uuid_links = Dir['/dev/disk/by-uuid/*']
			refute_empty(uuid_links)
			uuid_links.each do |uuid_link|
				message = uuid_link.inspect
				pathname = uuid_link
				ftype = File.ftype(pathname).to_sym
				assert_equal(:link, ftype)
				if ftype == :link
					symlink = File.readlink(pathname)
					expanded = File.expand_path(symlink, File.dirname(pathname))
					refute_equal(pathname, symlink, 'recursion problem: ' + message)
					assert(File.exist?(symlink), message)
				else
					assert_equal(ftype, :directory, message + "File.ftype(#{pathname})=#{File.ftype(pathname).inspect}")
				end # if
				pathname # allow chaining
#				RubyAssertions.assert_directory_exists(uuid_link)
			end # each
    end # assert_pre_conditions
end # Rsync
