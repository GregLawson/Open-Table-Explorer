require_relative '../app/models/work_flow.rb'
case ARGV.size
when 0 then 
	puts "dct <branch> <file>; where <branch> is development, compiles, or master"
	ARGV=['../test/unit/work_flow.rb'] # incestuous default test case for scite
end #case
EditTestGit=WorkFlow.new(ARGV)
EditTestGit.execute
