require_relative '../app/models/work_flow.rb'
case ARGV.size
when 0 then 
	puts "work_flow <command> <file>; where <command> is not yet implemented"
	this_file=File.expand_path(__FILE__)
	argv=[:downgrade, this_file] # incestuous default test case for scite
else
	argv=ARGV
end #case
argv[1..-1].each do |f|
	editTestGit=WorkFlow.new(f)
	case argv[0].to_sym
	when :execute editTestGit.execute
	when :edit editTestGit.edit
	when :test editTestGit.test
	when :upgrade editTestGit.upgrade
	when :downgrade editTestGit.downgrade
	end #case
end #each
