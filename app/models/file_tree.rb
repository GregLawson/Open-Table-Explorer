###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class FileTree # < ActiveRecord::Base
module Constants
end #Constants
include Constants
module ClassMethods
def file_type(file)
	ret = File.ftype(file).to_sym
	if ret == :file then
		if File.zero?(file)then
			:zero_length
		elsif File.file?(file) then
			:data
		else
			ret
		end # if
	else
		ret
	end # if
end # file_type
def recurse?(file)
	file_type(file) == :directory # not link (can cause infinite loops)
end # recurse?
def data_hash(file)
	file_contents = IO.read(file).chomp
	net_device_status = {File.basename(file).to_sym => file_contents}
rescue StandardError => exception_raised
	{File.basename(file).to_sym => exception_raised}
end # data_hash
def path_hash(path)
	if file_type(path) == :directory then
		{File.basename(path).to_sym => FileTree.directory_hash(path + '/*')}
	elsif file_type(path) == :link then # not link (can cause infinite loops)
		{}
	else
		data_hash(path)
	end # if
end # path_hash
def directory_hash(directory)
	ret = {}
	Dir[directory + '/*'].each do |file|
		if recurse?(file) then
			ret = ret.merge({File.basename(file).to_sym => FileTree.file_tree(file + '/*')})
		elsif File.file?(file) && !File.zero?(file)then
			ret = ret.merge(data_hash(file))
		end # if
	end # each
	ret
end # directory_hash
def file_tree(directory)
	directory_hash(directory)
end # file_tree
end # ClassMethods
extend ClassMethods
module Assertions
module ClassMethods
def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions(message='')
end #assert_pre_conditions
def assert_post_conditions(message='')
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
Net_directory = '/sys/class/net'
include Constants
end #Examples
end # FileTree