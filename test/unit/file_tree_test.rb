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
  # include DefaultTests
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
    assert_equal({ null: '' }, FileTree.data_hash('/dev/null'))
    assert_equal({ dev_id: '0x0' }, FileTree.data_hash(Net_directory + '/lo/dev_id'))
    assert_equal('#<Errno::EISDIR: Is a directory @ io_fread - /sys/class/net>', FileTree.data_hash(Net_directory).values[0].inspect)
    #	assert_equal('#<Errno::EOPNOTSUPP: Operation not supported @ io_fread - /sys/class/net/lo/phys_port_id>', FileTree.data_hash(Net_directory + '/lo/phys_port_id').values[0].inspect)
    assert_equal('#<Errno::EINVAL: Invalid argument @ io_fread - /sys/class/net/lo/duplex>', FileTree.data_hash(Net_directory + '/lo/duplex').values[0].inspect)
    assert_equal('#<Errno::EISDIR: Is a directory @ io_fread - /sys/class/net/lo/subsystem>', FileTree.data_hash(Net_directory + '/lo/subsystem').values[0].inspect)
  end # data_hash

  def test_path_hash
    assert_equal({ null: '' }, FileTree.path_hash('/dev/null'))
    assert_equal({ dev_id: '0x0' }, FileTree.path_hash(Net_directory + '/lo/dev_id'))
    assert_includes(Lo_hash.keys, :statistics)
    assert_equal(0, Lo_hash[:statistics].size, Lo_hash.inspect)
    assert_equal('0x0', Lo_hash[:dev_id])
    assert_equal([:_errors], Lo_hash[:statistics].keys)
    assert_equal({}, FileTree.path_hash('/dev/null'))
    path = Net_directory
    assert_equal(:directory, FileTree.file_type(path))
    net_hash = FileTree.path_hash(path)
    assert_equal([:eth0], net_hash.keys, net_hash.inspect)
  end # path_hash

  def test_directory_hash
    #	assert_equal(31, Lo_hash.size)
    assert_equal('0x0', Lo_hash[:dev_id])
    assert_equal({}, FileTree.directory_hash('/dev/null'))
    directory = Net_directory
    ret = {}
    assert_includes(Dir[directory + '/*'], '/sys/class/net/lo')
    Dir[directory + '/*'].each do |file|
      if FileTree.recurse?(file)
        ret = ret.merge(File.basename(file).to_sym => FileTree.file_tree(file + '/*'))
        refute_empty(ret.keys, ret)
      elsif FileTree.file_type(file) == :link
        ret = ret.merge(File.basename(file).to_sym => File.readlink(file))
      elsif File.file?(file) && !File.zero?(file)
        ret = ret.merge(data_hash(file))
           end # if
    end # each
    assert_equal(ret.keys.size, Dir[directory + '/*'].size)
    refute_nil(ret)
    assert_instance_of(Hash, ret)
    assert_equal(Lo_hash, ret[:lo])
    assert_instance_of(Hash, ret[:lo])
    assert_equal([:lo, :eth0, :wlan0], ret.keys)
    assert_equal(3, ret.values.size, ret)
    assert_equal(ret[:wlan0].keys, ret[:eth0].keys, ret)
    ret = FileTree.file_tree('/sys/class/net/*')
    assert_instance_of(Hash, ret)
    assert_instance_of(Hash, ret[:lo])
    #	assert_equal([:lo, :eth0, :wlan0], ret.keys)
    #	assert_equal(3, ret.values.size, ret)
    #	assert_equal(ret[:wlan0].keys, ret[:eth0].keys, ret)
    #	assert_equal(ret[:wlan0].keys, ret[:lo].keys, ret)
  end # directory_hash

  def test_file_tree
    directory = Net_directory
    assert_equal(:directory, FileTree.file_type(directory), FileTree.file_type(directory))
    assert_equal(true, FileTree.recurse?(directory), FileTree.file_type(directory))
    #	assert_equal([:lo, :eth0, :wlan0], FileTree.directory_hash(directory).keys, FileTree.directory_hash(directory).inspect)
    file_tree = FileTree.file_tree(directory)
    assert_equal([:lo, :eth0, :wlan0], file_tree.keys, file_tree.inspect)
  end # file_tree
end # FileTree
