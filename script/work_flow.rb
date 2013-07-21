require_relative '../app/models/work_flow.rb'
case ARGV.size
when 0 then 
	puts "dct <branch> <file>; where <branch> is development, compiles, or master"
	this_file=File.expand_path(__FILE__)
	argv=[this_file] # incestuous default test case for scite
else
	argv=ARGV
end #case
EditTestGit=WorkFlow.new(argv)
EditTestGit.execute
