###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative '../../app/models/no_db.rb'
#require_relative '../../test/assertions/repository_assertions.rb'
require_relative '../../app/models/repository.rb'
#assert_global_name(:Repository)
require_relative '../../app/models/parse.rb'
class Reference
end # Reference
class BranchReference
module Constants
Unambiguous_ref_age_pattern = /[0-9]+/.capture(:age)
Unambiguous_ref_pattern = /[a-z]+@\{/ * Unambiguous_ref_age_pattern * /}/
end #Constants
module ClassMethods
def previous_changes(filename)
	reflog?(filename)
end # previous_changes
def reflog?(filename, repository)
	reflog_run = repository.git_command("reflog  --all --pretty=format:%gd,%gD,%h,%aD -- " + filename)
	reflog_run.assert_post_conditions
	lines = reflog_run.output.split("\n")
	lines.map do |line|
		refs = line.split(',')
		if refs[0] == '' then
			{:ref => refs[2], :time => refs[3]} # hash
		else
			{:ref => refs[0], :time => refs[3]} # unambiguous ref
		end # if
	end # map
end # reflog?
def last_change?(filename, repository)
	reflog?(filename, repository)[0][:ref]
end # last_change?
end #ClassMethods
extend ClassMethods
def initialize(branch, age = 0)
	@branch = branch
	@age = age
end # initialize

end # BranchReference
class Branch
#include Repository::Constants
module Constants
#assert_global_name(:Repository)
#include Repository::Examples
Branch_name_regexp = /[-a-z0-9A-Z_]+/
Branch_name_alternative = [Branch_name_regexp.capture(:branch)]
Pattern = /[* ]/*/[a-z0-9A-Z_-]+/.capture(:branch)*/\n/
Git_branch_line = [/[* ]/, / /, Branch_name_regexp.capture(:branch)]
Git_branch_remote_line = [/[* ]/, / /, Branch_name_alternative]
Branch_regexp = /[* ]/*/ /*/[-a-z0-9A-Z_]+/.capture(:branch)
Branches_regexp = Branch_regexp.group * Regexp::Many
Patterns = [Pattern, Branches_regexp,
				/[* ]/*/ /*/[-a-z0-9A-Z_]+/.capture(:branch),
				/^[* ] /*/[a-z0-9A-Z_-]+/.capture(:branch)
				]
end #Constants
include Constants
module ClassMethods
#include Repository::Constants
include Constants
def branch_capture?(repository, branch_command = '--list')
	branch_output = repository.git_command('branch ' + branch_command).assert_post_conditions.output
	branch_output.capture?(Branch_regexp)
end # branch_command?
def current_branch_name?(repository)
	branch_capture = branch_capture?(repository, '--list')
	if branch_capture.success? then
		branch_capture.output?.map {|c| c[:branch].to_sym}
	else
		fail Exception.new('git branch parse failed = ' + branch_capture.inspect)
	end # if
end #current_branch_name
def branches?(repository)
	branch_capture = branch_capture?(repository, '--list')
	if branch_capture.success? then
		branch_capture.output?.map do |c| 
			Branch.new(repository, c[:branch].to_sym)
		end # map
	else
		fail Exception.new('git branch parse failed = ' + branch_capture.inspect)
	end # if
end #branches?
def remotes?(repository)
	pattern=/  /*(/[a-z0-9\/A-Z]+/.capture(:remote))
	repository.git_parse('branch --list --remote', pattern).map{|h| h[:remote]}
end #remotes?
def branch_names?(repository)
	branches?(repository).map {|b| b.branch}
end # 
def new_from_git_branch_line(git_branch_line)

end # new_from_git_branch_line
end #ClassMethods
extend ClassMethods
attr_reader :repository, :branch, :remote_branch
def initialize(repository, branch=repository.current_branch_name?, remote_branch=nil)
	fail "Branch.new first argument must be of type Repository" unless repository.instance_of?(Repository)
#	fail "@repository must respond to :remotes?\n"+
#		"repository.inspect=#{repository.inspect}\n" +
#		"repository.methods(false)=#{repository.methods(false).inspect}" unless repository.respond_to?(:remotes?)
	@repository=repository
	@branch=branch
	if remote_branch.nil? then
		@remote_branch=find_origin
	else
		@remote_branch=remote_branch
	end # if
end # initialize
# Allows Branch objects to be used in most contexts where a branch name Symbol is expected
def to_s
	@branch.to_s
end # to_s
def to_sym
	@branch.to_sym
end # to_s
def find_origin
	if Branch.remotes?(@repository).include?(@repository.current_branch_name?) then
		'origin/'+@branch.to_s
	else
		nil
	end #if
end # find_origin
def rebase!
	if remotes?.include?(current_branch_name?) then
		git_command('rebase --interactive origin/'+current_branch_name?).assert_post_conditions.output.split("\n")
	else
		puts current_branch_name?.to_s+' has no remote branch in origin.'
	end #if
end #rebase!
end # Branch
