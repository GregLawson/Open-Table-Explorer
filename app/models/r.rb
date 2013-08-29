require "rubygems"
require 'rserve'
class RSession
def initialize
	@con=Rserve::Connection.new
	@log=[]
	eval("library(ggplot2)")
end #initialize
def eval(r_code)
	@log << r_code # Array of all expressions evaluated
	@con.eval(r_code)
rescue Rserve::Connection::EvalError => exception
	matchData=/status=error:'(.*)'/.match(exception.message)
	error_message=matchData[1]
	message=build_message(nil, "\n? error while evaluating R expression ?\n#{@log.join("\n")}", error_message, r_code)
	raise exception.exception(message) #quit on first error
rescue StandardError => exception
	message=build_message(nil, "\n? error while evaluating R expression ?\n", exception.message, r_code)
	raise exception.exception(message) #don't know anything about
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
	assert_equal(3, eval('1+2'))

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
def initialize(name, session=RSession::Default_Session)
	@name=name.to_sym
	@session=session
end #initialize
def csv_import(name_order, filename=@name.to_s+'.csv', sep=',')
	@session.eval("#{@name}<-read.table('#{filename}',sep='#{sep}',fill=TRUE)")
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

end
def show_plot(x,y)
	@session.eval("plot(#{r_symbol(x)},#{r_symbol(y)})")
end #show_plot
def png_plot(x,y)
	@session.eval("png(filename = \"#{@name}.png\",width = 480, height = 480, units = \"px\", pointsize = 12, bg = \"white\",  res = NA,type = c(\"cairo\", \"Xlib\", \"cairo-png\", \"quartz\"))")
	show_plot(x,y)
	@session.eval("dev.off()")	
end #png_plot

def r_symbol(field=:V0)
	"#{@name}$#{field}"
end #r_symbol
def r_class_symbol(field=:V0)
	var="#{@name}$#{field}"
	@session.eval("class(#{var})").as_strings[0]
end #r_class_symbol
def variableSummary(var, tableName=@name)
	ret={}
	statistics=@session.eval("summary(#{r_symbol(var)})").as_doubles
	ret[:Min], ret[:Quartile1], ret[:Median], ret[:Mean], ret[:Quartile3], ret[:Max]=statistics
	ret
end #variableSummary
def pairSummary(x,y)
	variableSummary(x)
	variableSummary(y)
	show_plot(x,y)
end #pairSummary
def glm(model)
	@session.eval("glm(#model}, data=#{@name}").as_doubles
end #glm
module Examples
Loopback_channel2_filename=File.expand_path('test/data_sources/loopback_channel2.csv')
Loopback_4_channels_filename=File.expand_path('test/data_sources/loopback_4_channels.csv')
Loopback=DataFrames.new(:loopback)
Default_Session.eval("loopback_channel2 <-read.table('#{Loopback_channel2_filename}',sep=',',fill=TRUE)")
#	Loopback.csv_import([:ain,:aout_value], Loopback_4_channels_filename)

Default_Session.eval('save.image()')


end #Examples


end # DataFrames module