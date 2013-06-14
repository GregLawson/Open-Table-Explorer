require 'test/unit'
require_relative '../test/unit/default_test_case.rb'
require_relative '../app/models/test_environment.rb'
case ARGV.size
when 0 then puts "dct <branch> <file>; where <branch> is development, compiles, or master"; exit
end #case
Edit_branch=ARGV[0]
File=ARGV[1]
Test_file=ARGV[2]
puts ARGV.inspect
def self.revison_tag(branch)
	if branch.to_s==Edit_branch then
		return ''
	else
		return '-r '+branch.to_s
	end #if
end #revison_tag
def file_versions(filename)
	" #{revison_tag(:master)} #{filename} #{revison_tag(:compiles)} #{filename} #{revison_tag(:development)} #{filename}"
end #file_versions
def test_files(*files)
	" #{revison_tag(Edit_branch)} #{files[0]} #{revison_tag(Edit_branch)} #{files[1]} "
end #test_files
command_line="git checkout #{Edit_branch}"
sysout=`#{command_line}`
if !$?.success? then
	puts "command_line=#{command_line}, $?=#{$?.inspect}, $?.success?=#{$?.success?}";exit
else
	command_line="diffuse"+ file_versions(File) + ' -t' +file_versions(Test_file) + ' -t' +test_files(File, Test_file)
	sysout=`#{command_line}`
	if $?.success? then
		command_line="ruby "+ Test_file
		sysout=`#{command_line}`
		if $?.success? then
			puts "command_line=#{command_line}, $?=#{$?.inspect}, $?.success?=#{$?.success?}"
			command_line="git-cola "
			sysout=`#{command_line}`
			puts "command_line=#{command_line}, $?=#{$?.inspect}, $?.success?=#{$?.success?}";exit
		else
			puts "command_line=#{command_line}, $?=#{$?.inspect}, $?.success?=#{$?.success?}";exit
		end #if
	else
		puts "command_line=#{command_line}, $?=#{$?.inspect}";exit
	end #if
	puts command_line
	puts sysout
end #if

