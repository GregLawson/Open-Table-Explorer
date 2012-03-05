###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'app/models/global.rb'
class String
# Low level single line match. Called by nested_grep
def single_grep(context, pattern)
	regexp=Regexp.new(pattern)
	matchData=regexp.match(self)
	if matchData then
		ActiveSupport::HashWithIndifferentAccess.new(:context => context, :matchData => matchData)
	else
		nil #don't select line for return
	end #if
end #single_grep
end #String
module Enumerable
# Upgrade core grep with optional context
# If argument missing act just like core grep
# if context argument prsent, return it in a hash with answer
# Allows behavior like Unix command line grep with file glob,
# except now allows regexp with is more powerful.
# Chainable grep of enumeration
def nested_grep(pattern, context)
	map do |e|
		e.single_grep(context, pattern)
	end.compact #map
end #nested_grep
# grep through multiple files
# Enumeration is list of filenames to grep (e.g. Dir[*.rb])
# files opened
def files_grep(pattern, delimiter="\n")
	map do |p|
		IO.read(p).split(delimiter).nested_grep(pattern, p)
	end.flatten #map
end #files_grep
end #Enumerable
module GenericGrep
module ClassMethods
def grep_command(content_regexp_string, filename_regexp_string='-r {app/models/,test/unit/}*.rb', redirection='')
	if redirection.empty? then
		return "grep \"#{content_regexp_string}\" #{filename_regexp_string}"
	else
		return "grep \"#{content_regexp_string}\" #{filename_regexp_string} #{redirection}"
	end #if
end #grep_command
def model_grep_command(model_regexp_string)
	if !Generic_Table.rails_MVC_class?(self.name) then
		raise "#{self.name}.model_grep only works on Rails MVC."
	end #if
	return "grep \"#{model_regexp_string}\" #{model_file_name} &>/dev/null"
end #model_grep_command
def model_grep(model_regexp_string)
	return `#{model_grep_command(model_regexp_string)}`
end #model_grep
def association_grep_pattern(model_regexp_string,association_name)
	return "#{model_regexp_string}:#{association_name}" # no end of line $, so that polymorphic associations are found.
end #association_grep_command
ASSOCIATION_MACRO_LETTERS='[has_manyoneblgtd]'
ASSOCIATION_MACRO_PATTERN="^[hb]#{ASSOCIATION_MACRO_LETTERS}*\s\s*"
def grep_all_associations_command
	return grep_command(ASSOCIATION_MACRO_PATTERN, 'app/models/*.rb')
end #grep_all_associations_command
def all_associations
	regexp='([a-z_.]*):('+ASSOCIATION_MACRO_PATTERN[1..-1]+')(.*)'
	return `#{grep_all_associations_command}`.split("\n").map do |l| 
		Regexp.new(regexp).match(l)[1..-1]
		end #map
end #all_associations
def association_macro_type(association_name)
	hits=association_grep(ASSOCIATION_MACRO_PATTERN, association_name)
	if hits.empty? then
		return nil
	else
		return hits.match("(#{ASSOCIATION_MACRO_PATTERN})")[1].sub(/\s*$/, '').to_sym
	end #if
end #association_macro_type
def association_grep(model_regexp_string,association_name)
	return model_grep(association_grep_pattern(model_regexp_string,association_name))
end #association_grep
def has_many_association?(association_name)
	return association_grep('has_many',association_name)
end #has_many_association
# expects a singular association name
def belongs_to_association?(association_name)
	return association_grep('^belongs_to ',association_name)!=''
end #belongs_to_association
def has_one_association?(association_name)
	return association_grep('^has_one',association_name)
end #has_one_association
# concatenate association_arity and association_macro_type
def association_type(association_name)
	return (association_arity(association_name).to_s+'_'+association_macro_type(association_name).to_s).to_sym
end #association_type
end #GenericGrep::ClassMethods
end #GenericGrep

