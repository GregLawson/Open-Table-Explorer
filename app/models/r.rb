require "rubygems"
require 'rserve'
class RSession
def initialize
	@con=Rserve::Connection.new
end #initialize
def eval(r_code)
	@con.eval(r_code)
rescue Rserve::Connection::EvalError => exception
#	puts "\nr_code=#{r_code}"
#	puts "exception.message=#{exception.message}"
#	puts "exception.backtrace=#{exception.backtrace}"
#	puts caller_lines
	matchData=/status=error:'(.*)'/.match(exception.message)
#	puts "/status=error:'(.*)'\(/.match(exception.message).inspect}=#{/status=error:(.*)/.match(exception.message).inspect}"
	error_message=matchData[1]
#	puts "error_message=#{error_message}"
	message=build_message(nil, "\n? error while evaluating R expression ?\n", error_message, r_code)
	raise exception.exception(message) #quit on first error
rescue StandardError => exception
#	puts "\nr_code=#{r_code}"
#	puts exception.inspect
#	puts "exception.class.name=#{exception.class.name}"
#	puts "exception.methods(false)=#{exception.methods(false)}"
#	puts "exception.class.methods(false)=#{exception.class.methods(false)}"
	message=build_message(nil, "\n? error while evaluating R expression ?\n", exception.message, r_code)
	raise exception(message) #don't know anything about
ensure
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
	@name=name.to_sym
	@session=session
end #initialize
def csv_import(name_order, filename=@name.to_s+'.csv', sep=',')
	@session.eval("loopback<-read.table('#{filename}',sep='#{sep}',fill=TRUE)")
end #csv_import
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
end #plot
def r_symbol(field=:V0)
	"#{@name}$#{field}"
end #r_symbol
def r_class_symbol(field=:V0)
	var="#{@name}$#{field}"
	Default_Session.eval("class(#{var})").as_strings[0]
end #r_class_symbol
def variableSummary(var, tableName=@name)
	"#{var} "+@session.eval("class(#{var})")+@session.eval("summary(#{var})")
end #variableSummary
def pairSummary(x,y)
	variableSummary(x)
	variableSummary(y)
	plot(x,y)
end #pairSummary
module Examples
Loopback_Filename='/tmp/loopback4.csv'
Loopback=DataFrames.new(:loopback)
end #Examples


end # DataFrames module