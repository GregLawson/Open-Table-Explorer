require 'open3'
module Parse
LINES=/([^\n]*)(?:\n([^\n]*))*/
WORDS=/([^\s]*)(?:\s([^\s]*))*/
CSV=/([^,]*)(?:,([^,]*?))*?/
# A delimiter is generally not at the end (like commas)
def Parse.delimiter_regexp(delimiter)
	raise "delimiters must be single characters not #{delimiter.inspect}." if delimiter.length!=1
	/([^#{delimiter}]*)(?:#{delimiter}([^#{delimiter}]*))*/
end #delimiter_regexp
# A terminator is a delimiter that is at the end (like new line)
def Parse.terminator_regexp(delimiter)
	raise "delimiters must be single characters not #{delimiter}." if delimiter.length!=1
	/([^#{delimiter}]*)(?:#{delimiter}([^#{delimiter}]*))*/
end #terminator_regexp
def parse_string(string, pattern=LINES)
	ret=string.match(pattern)
	ret[1..-1] # return matched subexpressions
end #parse_string
def parse_array(string_array, pattern=WORDS)
	string_array.map do |string|
		parse(string,pattern)
	end #map
end #parse_array
# parse takes an input string or possibly nested array of strings and returns an array of regexp captures per string.
# The array of captures replacing the input strings adds one additional layer of Array nesting.
def parse(string_or_array, pattern=WORDS)
	if string_or_array.instance_of?(String) then
		parse_string(string_or_array, pattern)
	elsif string_or_array.instance_of?(Array) then
		parse_array(string_or_array, pattern)
	else
		nil
	end #if
end #parse
def default_name(index, prefix='Col_')
	prefix+index.to_s
end #
def parse_name_values(array, pairs, new_names, pattern)
	ret={}
	next_pair=pairs.pop
	next_name=new_names.pop
	array.each_index do |string, i|
		if i==next_pair then
			ret[array[next_pair].to_sym]=array[next_pair+1]
			next_pair=pairs.pop
		else
			matchData=string.match(pattern)
			if matchData then
				ret[matchData[1].to_sym]=matchData[2]			
			else
				if next_name.nil? then
				else
					ret[next_name.to_sym]=string			
					next_name=new_names.pop
				end #if
			end #if
		end #if
	end #map
end #parse_name_values
end #Parse
class ShellCommands
attr_reader :command_string, :output, :errors, :exit_status, :pid
include Parse
# execute same command again (also called by new.
def repeat
	@output, @errors, @exit_status, @pid=system_output(command_string)
end #repeat
def initialize(command_string)
	@command_string=command_string
	repeat # do it first time, then repeat
end #initialize
def system_output(command_string)
	ret=[] #make method scope not block scope so it can be returned
	Open3.popen3(command_string) {|stdin, stdout, stderr, wait_thr|
		stdin.close  # stdin, stdout and stderr should be closed explicitly in this form.
		output=stdout.read
		stdout.close
		errors=stderr.read
		stderr.close
		exit_status = wait_thr.value  # Process::Status object returned.
		pid = wait_thr.pid # pid of the started process.
		exit_status = wait_thr.value # Process::Status object returned.
		ret=[output, errors, exit_status, pid]
	}
	ret
end #system_output
def rows_and_columns(column_pattern=Parse::WORDS, row_pattern=Parse::LINES)
	parse(@output, row_pattern).map  do |row| 
		parse(row, column_pattern)
	end #map
end #rows_and_columns
def inspect
	ret=''
	if @errors!='' || @exit_status!=0 then
		ret+="@command_string=#{@command_string.inspect}\n"
	end #if
	if @errors!='' then
		ret+="@errors=#{@errors.inspect}\n"
	end #if
	if @exit_status!=0 then
		ret+="@exit_status=#{@exit_status.inspect}\n"
		ret+="@pid=#{@pid.inspect}\n"
	end #if
	rows_and_columns.each do |row|
		ret+=row.join(',')+"\n" unless row.nil?
	end #each
	ret
end #inspect
module Assertions
include Test::Unit::Assertions
extend Test::Unit::Assertions
def assert_post_conditions
	assert_empty(@errors)
	assert_equal(0, @exit_status)
end #assert_post_conditions
end #Assertions
include Assertions
module Examples
Hello_world=ShellCommands.new('echo "Hello World"')

COMMAND_STRING='echo "1 2;3 4"'
EXAMPLE=ShellCommands.new(COMMAND_STRING)

end #Examples
include Examples
end #ShellCommands
class NetworkInterface
IFCONFIG=ShellCommands.new('/sbin/ifconfig')
#puts IFCONFIG.inspect
end #NetworkInterface
