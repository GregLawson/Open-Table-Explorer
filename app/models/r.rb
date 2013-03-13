require "rubygems"
require 'rserve'
class RSession
def initialize
	@con=Rserve::Connection.new
end #initialize
def eval(r_code)
	@con.eval(r_code)
end #eval
def assign(variable, r_code)
	@con.assign(variable, r_code)
end #assign
def self.eval_R_shell(rCommand)
	shellCmd="R --save --quiet -e \'#{rCommand}\'"
	puts "shellCmd=#{shellCmd}" if $VERBOSE
	sysout=`#{shellCmd}`
	puts "sysout=#{sysout}" if $VERBOSE
	return sysout
end #eval_R_shell
module Constants
Default_Session=RSession.new # use to share everything
end #Constants
include Constants
require_relative '../../test/assertions/default_assertions.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
include Test::Unit::Assertions
extend Test::Unit::Assertions
module Assertions
def assert_invariant
	assert_equal(eval('1+2'))

end #assert_invariant
module ClassMethods

def assert_invariant
	assert_not_nil(RSession.new.eval('1+2'))
	assert_not_equal("  PID TTY          TIME CMD\n", `ps -C Rserve`, "Enter R CMD Rserve to start R server.")
end #assert_class_post_conditions
end #ClassMethods
end #Assertions
include Assertions
extend Assertions::ClassMethods
end #RSession
class DataFrames
	@r=RSession.new
def initialize(name, session=RSession::Default_Session)
	@name=name
	@session=session
end #initialize
def psqlExport(tableName=@name)
	#sql="COPY #{tableName} TO '#{tableName}.csv' WITH CSV HEADER "
	sql="COPY #{tableName} TO STDOUT WITH CSV HEADER "
	puts "sql=#{sql}"	
	psql="psql --no-align --tuples-only --host localhost --dbname energy_development --command \"#{sql}\" >/tmp/#{tableName}.csv"
	puts "psql=#{psql}"	
	sysout=`#{psql}`
end
def importRelation(tableName=@name)
# 	pv<-read.csv('/home/greg/energy/rails/energy/production.csv')
	@session.eval("#{tableName}<-read.csv(\"/tmp/#{tableName}.csv\")")
#	@r.assign("foo",@r.read_csv("/tmp/#{tableName}.csv"))
#	puts @r.foo.size
#	puts @r.read_csv("/tmp/#{tableName}.csv")
end
def plot(x,y, tableName=@name)
	@session.eval("png(filename = \"#{tableName}.png\",width = 480, height = 480, units = \"px\", pointsize = 12, bg = \"white\",  res = NA,type = c(\"cairo\", \"Xlib\", \"cairo1\", \"quartz\"))")
	@session.eval("plot(#{x},#{y})")
	@session.eval("dev.off()")
end
def variableSummary(var, tableName=@name)
	puts "#{var} "
	puts @session.eval("class(#{var})")
	puts @session.eval("summary(#{var})")
end
def pairSummary(x,y)
	variableSummary(x)
	variableSummary(y)
	plot(x,y)
end

end # DataFrames module