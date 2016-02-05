###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/file_tree.rb'
class FileTreeTest < TestCase
#include DefaultTests
include RailsishRubyUnit::Executable.model_class?::Examples
def test_file_type
	assert_equal(:directory, FileTree.file_type(Net_directory))
	assert_equal(:link, FileTree.file_type(Net_directory + '/lo/subsystem'))
	assert_equal(:data, FileTree.file_type(Net_directory + '/lo/uevent'))
#	assert_equal(:unknown, FileTree.file_type(Net_directory + '/lo/phys_port_id'))
#	assert_equal(:zero_length, FileTree.file_type('/dev/null'))
#	assert_equal(:unknown, FileTree.file_type(Net_directory + '/lo/duplex'))
end # file_type
def test_recurse?
	assert(FileTree.recurse?(Net_directory))
	refute(FileTree.recurse?(Net_directory + '/lo/subsystem'), FileTree.file_type(Net_directory + '/lo/subsystem'))
	refute(FileTree.recurse?(Net_directory + '/lo/uevent'))
end # recurse?
def test_data_hash
	assert_equal({:null => ''}, FileTree.data_hash('/dev/null'))
	assert_equal({:dev_id => '0x0'}, FileTree.data_hash(Net_directory + '/lo/dev_id'))
	assert_equal('#<Errno::EISDIR: Is a directory @ io_fread - /sys/class/net>', FileTree.data_hash(Net_directory).values[0].inspect)
	assert_equal('#<Errno::EOPNOTSUPP: Operation not supported @ io_fread - /sys/class/net/lo/phys_port_id>', FileTree.data_hash(Net_directory + '/lo/phys_port_id').values[0].inspect)
	assert_equal('#<Errno::EINVAL: Invalid argument @ io_fread - /sys/class/net/lo/duplex>', FileTree.data_hash(Net_directory + '/lo/duplex').values[0].inspect)
	assert_equal('#<Errno::EISDIR: Is a directory @ io_fread - /sys/class/net/lo/subsystem>', FileTree.data_hash(Net_directory + '/lo/subsystem').values[0].inspect)
end # data_hash
def test_path_hash
	assert_equal({:null => ''}, FileTree.path_hash('/dev/null'))
	assert_equal({:dev_id => '0x0'}, FileTree.path_hash(Net_directory + '/lo/dev_id'))
	path = Net_directory + '/lo'
	assert_equal(:link, FileTree.file_type(path))
#	assert_equal({}, {File.basename(path).to_sym => FileTree.directory_hash(path + '/*')})
	lo_hash = FileTree.path_hash(path)
	assert_equal(0, lo_hash.size, lo_hash.inspect)
#	assert_equal('0x0', lo_hash[:dev_id])
#	assert_equal({}, FileTree.path_hash('/dev/null'))
end # path_hash
def test_directory_hash
	lo_hash = FileTree.directory_hash(Net_directory + '/lo')
	assert_equal(31, lo_hash.size)
	assert_equal('0x0', lo_hash[:dev_id])
	assert_equal({}, FileTree.directory_hash('/dev/null'))
end # directory_hash
def test_file_tree
	net_devices = {}
	net_devices_status = Dir[Net_directory].each do |net_file|
		net_device_status = {}
		Dir[net_file + '/*'].each do |file|
			if File.directory?(file) then
				net_device_status = net_device_status.merge({File.basename(file).to_sym => FileTree.file_tree(file + '/*')})
				refute_empty(net_device_status.keys, net_device_status)
			elsif File.file?(file) && !File.zero?(file)then
				begin
					file_contents = IO.read(file).chomp
	#				refute_empty(file_contents, file)
					net_device_status = net_device_status.merge({File.basename(file).to_sym => file_contents})
					refute_empty(net_device_status.keys, net_device_status)
				rescue
				end # begin
			end # if
		end # each
		net_devices = net_devices.merge({File.basename(net_file).to_sym => net_device_status})
		refute_nil(net_devices)
	end # each
	assert_instance_of(Hash, net_devices)
#	assert_instance_of(Hash, net_devices[:lo])
#	assert_equal([:lo, :eth0, :wlan0], net_devices.keys)
#	assert_equal(3, net_devices.values.size, net_devices)
#	assert_equal(net_devices[:wlan0].keys, net_devices[:eth0].keys, net_devices)
#	net_devices = FileTree.file_tree('/sys/class/net/*')
	assert_instance_of(Hash, net_devices)
#	assert_instance_of(Hash, net_devices[:lo])
#	assert_equal([:lo, :eth0, :wlan0], net_devices.keys)
#	assert_equal(3, net_devices.values.size, net_devices)
#	assert_equal(net_devices[:wlan0].keys, net_devices[:eth0].keys, net_devices)
#	assert_equal(net_devices[:wlan0].keys, net_devices[:lo].keys, net_devices)
end # file_tree
end # FileTree
