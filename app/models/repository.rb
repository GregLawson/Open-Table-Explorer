###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#assert_include(Module.constants, :ShellCommands)
#assert_not_include(Module.constants, :FilePattern)
#assert_not_include(Module.constants, :Unit)
#assert_include(Module.constants, :Capture)
#assert_include(Module.constants, :Branch)
# @see http://grit.rubyforge.org/
require 'grit'  # sudo gem install grit
# partial API at @see less /usr/share/doc/ruby-grit/API.txt
# code in @see /usr/lib/ruby/vendor_ruby/grit
#assert_include(Module.constants, :ShellCommands)
#assert_include(Module.constants, :FilePattern)
#assert_include(Module.constants, :Unit)
#assert_include(Module.constants, :Capture)
#assert_include(Module.constants, :Branch)
#assert_not_include(Module.constants, :Unit)
require_relative 'unit.rb'
assert_include(Module.constants, :Unit)
assert_include(Module.constants, :FilePattern)
require_relative 'shell_command.rb'
assert_include(Module.constants, :ShellCommands)
#require_relative 'global.rb'
assert_not_include(Module.constants, :Capture)
require_relative 'parse.rb'
assert_include(Module.constants, :Capture)
assert_not_include(Module.constants, :Branch)
#require_relative 'branch.rb'
#assert_include(Module.constants, :Branch)
assert_not_include(Module.constants, :Repository)
class Repository #<Grit::Repo
module Constants
Repository_Unit = Unit.new_from_path?(__FILE__)
Root_directory=FilePattern.project_root_dir?(__FILE__)
Source=File.dirname(Root_directory)+'/'
README_start_text='Minimal repository.'
Error_classification={0 => :success,
				1     => :single_test_fail,
				100 => :initialization_fail,
				10000 => :syntax_error}
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
	Repository_Unit.data_sources_directory? + Time.now.strftime("%Y-%m-%d %H:%M:%S.%L")
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
def abort_rebase_and_merge!
	if File.exists?('.git/rebase-merge/git-rebase-todo') then
		git_command("rebase --abort")
	end
#	git_command("stash save").assert_post_conditions
	if File.exists?('.git/MERGE_HEAD') then
		git_command("merge --abort")
	end # if
end # abort_rebase_and_merge!
def standardize_position!
	 abort_rebase_and_merge!
	git_command("checkout master")
end #standardize_position!
def state?
	state=[]
	if File.exists?('.git/rebase-merge/git-rebase-todo') then
		state << :rebase
	end
	if File.exists?('.git/MERGE_HEAD') then
		state << :merge
	end # if
	if something_to_commit? then
		state << :dirty
	else
		state << :clean
	end # if
	return state
end # state?
def current_branch_name?
	@grit_repo.head.name.to_sym
end #current_branch_name
def confirm_branch_switch(branch)
	checkout_branch=git_command("checkout #{branch}")
	if checkout_branch.errors!="Already on '#{branch}'\n" && checkout_branch.errors!="Switched to branch '#{branch}'\n" then
		checkout_branch #.assert_post_conditions
	end #if
	checkout_branch # for command chaining
end #confirm_branch_switch
# This is safe in the sense that a stash saves all files
# and a stash apply restores all tracked files
# safe is meant to mean no files or changes are lost or buried.
def safely_visit_branch(target_branch, &block)
	push_branch=current_branch_name?
	changes_branch=push_branch # 
	push=something_to_commit? # remember
	if push then
#		status=@grit_repo.status
#		puts "status.added=#{status.added.inspect}"
#		puts "status.changed=#{status.changed.inspect}"
#		puts "status.deleted=#{status.deleted.inspect}"
#		puts "something_to_commit?=#{something_to_commit?.inspect}"
		git_command('stash save --include-untracked')
		merge_conflict_files?.each do |conflict|
			shell_command('diffuse -m '+conflict[:file])
			confirm_commit
		end #each
		changes_branch=:stash
	end #if

	if push_branch!=target_branch then
		confirm_branch_switch(target_branch)
		ret=block.call(changes_branch)
		confirm_branch_switch(push_branch)
	else
		ret=block.call(changes_branch)
	end #if
	if push then
		apply_run=git_command('stash apply --quiet')
		if apply_run.errors.match(/Could not restore untracked files from stash/) then
			puts apply_run.errors
			puts git_command('status').output
			puts git_command('stash show').output
		else
			apply_run #.assert_post_conditions('unexpected stash apply fail')
		end #if
		merge_conflict_files?.each do |conflict|
			shell_command('diffuse -m '+conflict[:file])
			confirm_commit
		end #each
	end #if
	ret
end #safely_visit_branch
def stage_files(branch, files)
	safely_visit_branch(branch) do |changes_branch|
		validate_commit(changes_branch, files)
	end #safely_visit_branch
end #stage_files
def unit_names?(files)
	files.map do |f|
		FilePattern.unit_base_name?(f).to_s
	end #map
end #unit_names?
def confirm_commit(interact=:interactive)
	if something_to_commit? then
		case interact
		when :interactive then
			cola_run = git_command('cola')
			cola_run = cola_run.tolerate_status_and_error_pattern(0, /Warning/)
			cola_run #.assert_post_conditions
			if !something_to_commit? then
#				git_command('cola rebase '+current_branch_name?.to_s)
			end # if
		when :echo then
		when :staged then
			git_command('commit ').assert_post_conditions			
		when :all then
			git_command('add . ').assert_post_conditions
			git_command('commit ').assert_post_conditions
		else
			raise 'Unimplemented option=' + interact.to_s
		end #case
	end #if
	puts 'confirm_commit('+interact.inspect+" something_to_commit?="+something_to_commit?.inspect
end #confirm_commit
def validate_commit(changes_branch, files, interact=:interactive)
	puts files.inspect if $VERBOSE
	files.each do |p|
		puts p.inspect  if $VERBOSE
		git_command(['checkout', changes_branch.to_s, p])
	end #each
	if something_to_commit? then
		confirm_commit(interact)
#		git_command('rebase --autosquash --interactive')
	end #if
end #validate_commit
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
def rebase!
	if remotes?.include?(current_branch_name?) then
		git_command('rebase --interactive origin/'+current_branch_name?).assert_post_conditions.output.split("\n")
	else
		puts current_branch_name?.to_s+' has no remote branch in origin.'
	end #if
end #rebase!
end # Repository
assert_include(Module.constants, :ShellCommands)
assert_include(Module.constants, :FilePattern)
assert_include(Module.constants, :Unit)
assert_include(Module.constants, :Capture)
#assert_include(Module.constants, :Branch)
assert_include(Module.constants, :Repository)
assert_include(Repository.constants, :Constants)
assert_include(Repository.constants, :ClassMethods)

