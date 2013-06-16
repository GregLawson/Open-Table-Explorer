require_relative '../app/models/work_flow.rb'
case ARGV.size
when 0 then puts "dct <branch> <file>; where <branch> is development, compiles, or master"; exit
end #case
EditTestGit=WorkFlow.new(ARGV)
EditTestGit.execute
