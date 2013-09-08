Temporary='~/Desktop/git/'
Source='/media/greg/SD_USB_32G/Repository Backups/'
require "#{Source}clone-reconstruct/app/models/shell_command.rb"
ShellCommands.new("copy -a #{Source}development_old #{Temporary}recover").assert_post_conditions #uncorrupted old backup to start
#subshell (cd_command=ShellCommands.new("cd #{Temporary}recover")).assert_post_conditions
#puts "cd_command=#{cd_command.inspect}"
def fetch_commits(name, commit, repository_file)
	ShellCommands.new("git fetch file://"+repository+" "+name)
end #fetch_commits
def initialize_branch(name, commit, repository_file)
	ShellCommands.new("git fetch file://"+repository+" "+name)
	ShellCommands.new("git symbolic-link #{name.to_s} "+commit.to_s).assert_post_conditions
end #initialize_branch
#exists ShellCommands.new("git branch details").assert_post_conditions
ShellCommands.new("git reset 8db16b5cfaa0adacfd157c8ffba727c26117179d").assert_post_conditions
#exists ShellCommands.new("git branch summary").assert_post_conditions

def add_commits(from_repository, last_commit_to_add, branch, history_options='--squash -Xthiers ')
	ShellCommands.new("git fetch file://"+repository+" "+name)
	ShellCommands.new("git checkout  #{branch}").assert_post_conditions
	ShellCommands.new("git merge #{history_options} "+" -m "+name.to_s+commit.to_s).assert_post_conditions
end #add_commits

#add_commits("postgres", :postgres, Temporary+"details")
#add_commits("activeRecord", :activeRecord, Temporary+"details")
#add_commits("rails2", :rails2, Temporary+"details")
#add_commits("rails3", :rails3, Temporary+"details")
#add_commits("", :default, Source+"details")
#add_commits("taxesFreeeze", :taxesFreeeze, Source+"copy-master")
#add_commits("", :taxesStopped, Source+"copy-master")
#add_commits("development", :development, Source+"copy-master")
#add_commits("compiles", :compiles, Source+"copy-master")
#add_commits("master", :master, Source+"copy-master")
#add_commits("usb", :usb, Source+"clone-reconstruct-newer ")


#ShellCommands.new("rsync -a #{Temporary}recover /media/greg/B91D-59BB/recover").assert_post_conditions
