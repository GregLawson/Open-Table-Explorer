class Frequency < ActiveRecord::Base
has_many :table_specs
def logical_primary_key
	return :frequency_name
end #def
def intervalString(seconds)
#	assert_operator(seconds,:>,0.0)
#	assert_operator(seconds,:<,365*24*3600)
	days=(seconds/(24*3600))
	dayString=("%3i"%days)
	timeString=Time.at(seconds).getutc.strftime("%H:%M:%S")
	fractionalString="%04i"%((10000*seconds)%10000)
	dayString+'d '+timeString+"."+fractionalString
end #def
 def initialize(params=nil)
	@frozen=false
	@thawLength=0
	@freezeLength=0
	@previousThaw=0
	@previousFreeze=0
 
	super(params)	

	if self[:shortest_update].nil? then
		self[:shortest_update]=100*365*24*3600
	end
	if self[:longest_no_update].nil? then
		self[:longest_no_update]=0
	end

end
def assert_model_counters
	assert_not_nil(@frozen)
	assert_not_nil(@thawLength)
	assert_not_nil(@freezeLength)
	assert_not_nil(@previousThaw)
	assert_not_nil(@previousFreeze)
end #def
def sleepRange
	ret="#{intervalString(self[:min_seconds])}   "
	assert_operator(self[:shortest_update],:>,0.0)
	ret+= "#{intervalString(self[:shortest_update])} "
	ret+= "#{intervalString(self[:interval])}   "
	ret+= "#{intervalString(self[:longest_no_update])}  "
	ret+= "#{intervalString(self[:max_seconds])}  "
	ret+= "sd=#{@@scheduling_delay}"
	return ret
end #def
def checkFreeze(acquisitionsUpdated=acquisitionsUpdated?)
	if acquisitionsUpdated then
		if @frozen then #begin thaw
			@frozen=false
			@previousThaw=@thawLength	
			@thawLength=1
		else 
			@thawLength+=1
		end
	else
		if @frozen then
			@freezeLength+=1
		else
			@frozen=true
			@previousFreeze=@freezeLength
			@freezeLength=1
		end
	end
	return @freezeLength
	
end
def freezeMetric
	if @freezeLength > @previousFreeze then
		if @thawLength > @previousThaw
			return @freezeLength/(@freezeLength+@thawLength)
		else
			return @freezeLength/(@freezeLength+@previousThaw)
		end
	else
		if @thawLength > @previousThaw
			return @previousFreeze/(@previousFreeze+@thawLength)
		else
			return @previousFreeze/(@previousFreeze+@previousThaw)
		end
	end
end
@@TargetUpdates=0.9
@@a=@@TargetUpdates
@@b=(1.0-@@TargetUpdates)
def firstUpdateAfterInterruption?
	if @thawLength==1 then
		return true
	else
		return false
	end #if
end #def
def acquisitionUpdated
		if firstUpdateAfterInterruption? then
			self[:longest_no_update]=[self[:interval],self[:longest_no_update]].max
			self[:interval]=[self[:shortest_update],self[:min_seconds]].min
		else
			self[:interval]=@@a*self[:shortest_update]+@@b*self[:longest_no_update]
			self[:shortest_update]=[Time.now-self[previous_update],self[:shortest_update]].min
			self[:longest_no_update]=[Time.now-self[previous_update],self[:longest_no_update]].max
		end #if
		self[previous_update]=Time.now
end #def
def acquisitionNotUpdated
	noUpdateInterval=Time.now-self[previous_update]
	longestWait=[self[:max_seconds],self[:longest_no_update]].min
	self[:longest_no_update]=[noUpdateInterval,self[:longest_no_update]].max		
		self[:interval]=@@b*self[:shortest_update]+@@a*self[:longest_no_update]
		assert_operator(self[:interval],:<,365*24*3600)
		assert_not_nil(@freezeLength)
		assert_operator(self[:shortest_update],:>,0.0)
		@@log.debug(sleepRange)
end #def
def updateSleepInterval(acquisitionsUpdated=acquisitionsUpdated?)
	assert_model_counters
	checkFreeze(acquisitionsUpdated)
	assert_model_counters
	if acquisitionsUpdated then # might be too long; decrease interval, too_long, and too_short
		assert_not_nil(@thawLength)
		assert_operator(@thawLength,:>,0)
		if firstUpdateAfterInterruption? then
			self[:longest_no_update]=[self[:interval],self[:longest_no_update]].max
			self[:interval]=[self[:shortest_update],self[:min_seconds]].min
		else
			self[:interval]=@@a*self[:shortest_update]+@@b*self[:longest_no_update]
		end #if
		assert_operator(self[:longest_no_update],:<,365*24*3600)
		assert_operator(self[:interval],:>,0.0)
		assert_operator(self[:interval],:<,365*24*3600)
		assert_operator(self[:shortest_update],:>,0.0)
		assert_operator(self[:max_seconds],:>,0.0)
		self[:shortest_update]=[self[:interval],self[:shortest_update]].min
	else 
		self[:interval]=@@b*self[:shortest_update]+@@a*self[:longest_no_update]
		assert_operator(self[:interval],:<,365*24*3600)
		assert_not_nil(@freezeLength)
		self[:longest_no_update]=@@a*self[:longest_no_update]+@@b*self[:max_seconds]*@freezeLength
		assert_operator(self[:shortest_update],:>,0.0)
		@@log.debug(sleepRange)
	end
	assert_operator(self[:interval],:>,0.0)
	assert_operator(self[:interval],:<,365*24*3600)
	assert_operator(self[:shortest_update],:>,0.0)
	blockUnderflow # postgresql doesn't like float underflow
	return self[:interval] # result of most interest, other results are instance variables
end
end #class
