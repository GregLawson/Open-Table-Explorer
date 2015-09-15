###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#assert_includes(Module.constants, :ShellCommands)
#refute_includes(Module.constants, :FilePattern)
#refute_includes(Module.constants, :Unit)
#assert_includes(Module.constants, :Capture)
#assert_includes(Module.constants, :Branch)
# @see http://grit.rubyforge.org/
require 'grit'  # sudo gem install grit
# partial API at @see less /usr/share/doc/ruby-grit/API.txt
# code in @see /usr/lib/ruby/vendor_ruby/grit
#assert_includes(Module.constants, :ShellCommands)
#assert_includes(Module.constants, :FilePattern)
#assert_includes(Module.constants, :Unit)
#assert_includes(Module.constants, :Capture)
#assert_includes(Module.constants, :Branch)
#refute_includes(Module.constants, :Unit)
require_relative 'unit.rb'
#assert_includes(Module.constants, :Unit)
#assert_includes(Module.constants, :FilePattern)
require_relative 'shell_command.rb'
#assert_includes(Module.constants, :ShellCommands)
#require_relative 'global.rb'
#refute_includes(Module.constants, :Capture)
require_relative 'parse.rb'
#assert_includes(Module.constants, :Capture)
#refute_includes(Module.constants, :Branch)
#require_relative 'branch.rb'
#assert_includes(Module.constants, :Branch)
#refute_includes(Module.constants, :Repository)
class Repository #<Grit::Repo
module Constants
Repository_Unit = Unit.new_from_path(__FILE__)
Root_directory=FilePattern.project_root_dir?(__FILE__)
Source=File.dirname(Root_directory)+'/'
README_start_text='Minimal repository.'
end #Constants
include Constants
module ClassMethods
include Constants
def git_command(git_command, repository_dir)
	ShellCommands.new('git '+ShellCommands.assemble_command_string(git_command), :chdir=>repository_dir)
end #git_command
def create_empty(path, interactive = :interactive)
	Dir.mkdir(path)
	@interactive = interactive
	if File.exists?(path) then
		ShellCommands.new([['cd', path], '&&', ['git', 'init']])
		new_repository = Repository.new(path, @interactive)
	else
		raise "Repository.create_empty failed: File.exists?(#{path})=#{File.exists?(path)}"
	end #if
	new_repository
end #create_empty
def delete_existing(path)
# @see http://www.ruby-doc.org/stdlib-1.9.2/libdoc/fileutils/rdoc/FileUtils.html#method-c-remove
	FileUtils.remove_entry_secure(path) #, force = false)
end #delete_existing
def replace_or_create(path, interactive)
	if File.exists?(path) then
		delete_existing(path)
	end #if
	create_empty(path, interactive)
end #replace_or_create
def create_if_missing(path, interactive = :interactive)
	if File.exists?(path) then
		Repository.new(path, interactive)
	else
		create_empty(path, interactive)
	end #if
end #create_if_missing
def timestamped_repository_name?
	Repository_Unit.data_sources_directory? + Time.now.strftime("%Y-%m-%d_%H.%M.%S.%L")
end # timestamped_repository_name?
def create_test_repository(path=timestamped_repository_name?, 
	interactive)
	replace_or_create(path, interactive)
	@interactive = interactive
	if File.exists?(path) then
		new_repository=Repository.new(path, @interactive)
		IO.write(path+'/README', README_start_text+"\n") # two consecutive slashes = one slash
		new_repository.git_command('add README')
		new_repository.git_command('commit -m "create_empty initial commit of README"')
		new_repository.git_command('branch passed')
	else
		raise "Repository.create_empty failed: File.exists?(#{path})=#{File.exists?(path)}"
	end #if
	new_repository
end #create_test_repository
end #ClassMethods
extend ClassMethods
attr_reader :path, :grit_repo, :recent_test, :deserving_branch, :related_files, :interactive
def initialize(path, interactive = :interactive)
	if path.to_s[-1,1]!='/' then
		path=path.to_s+'/'
	end #if
	@url=path
	@path=path.to_s
	puts '@path='+@path if $VERBOSE
	@interactive = interactive
	@grit_repo=Grit::Repo.new(@path)
end #initialize
module Constants
This_code_repository = Repository.new(Root_directory, :interactive)
end #Constants
def shell_command(command, working_directory=@path)
	ShellCommands.new(command, :chdir=>working_directory)
end #shell_command
def git_command(git_subcommand)
	Repository.git_command(git_subcommand, @path)
end #git_command
def inspect
	git_command('status --short --branch').output
end #inspect
def corruption_fsck
	git_command("fsck")
end #corruption
def corruption_rebase
#	git_command("rebase")
end #corruption
def corruption_gc
	git_command("gc")
end #corruption
def current_branch_name?
	@grit_repo.head.name.to_sym
end #current_branch_name
def something_to_commit?
	status=@grit_repo.status
	ret=status.added!={}||status.changed!={}||status.deleted!={}
	message="status.added=#{status.added.inspect}"
	message+="\nstatus.changed=#{status.changed.inspect}"
	message+="\nstatus.deleted=#{status.deleted.inspect}"
	message+="\nstatus.added!={}||status.changed!={}||status.deleted!={}==#{ret}"
	puts message if $VERBOSE
	ret
end #something_to_commit
def testing_superset_of_passed
	git_command("shortlog testing..passed")
end #testing_superset_of_passed
def edited_superset_of_testing
	git_command("shortlog edited..testing")
end #edited_superset_of_testing
def force_change(content=README_start_text+Time.now.strftime("%Y-%m-%d %H:%M:%S.%L")+"\n")
	IO.write(@path+'/README', content) # timestamp make file unique
end #force_change
def revert_changes
	git_command('reset --hard')
end #revert_changes
def merge_conflict_files?
	unmerged_files=git_command('status --porcelain --untracked-files=no').output
	ret=[]
	if !unmerged_files.empty? then
		unmerged_files.split("\n").map do |line|
			file=line[3..-1]
			ret << {:conflict => line[0..1], :file => file}
			puts 'ruby script/workflow.rb --test '+file
			rm_orig=shell_command('rm '+file.to_s+'.BASE.*')
			rm_orig=shell_command('rm '+file.to_s+'.BACKUP.*')
			rm_orig=shell_command('rm '+file.to_s+'.LOCAL.*')
			rm_orig=shell_command('rm '+file.to_s+'.REMOTE.*')
			rm_orig=shell_command('rm '+file.to_s+'.orig')
		end #map
	end #if
	ret
end #merge_conflict_files?
def git_parse(command, pattern)
	output=git_command(command).assert_post_conditions.output
	output.parse(pattern)

end # git_parse
end # Repository
#assert_includes(Module.constants, :ShellCommands)
#assert_includes(Module.constants, :FilePattern)
#assert_includes(Module.constants, :Unit)
#assert_includes(Module.constants, :Capture)
#assert_includes(Module.constants, :Branch)
#assert_includes(Module.constants, :Repository)
#assert_includes(Repository.constants, :Constants)
#assert_includes(Repository.constants, :ClassMethods)

