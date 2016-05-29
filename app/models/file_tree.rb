###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class FileTree # < ActiveRecord::Base
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
  end # DefinitionalConstants
  include DefinitionalConstants
  module ClassMethods
    include DefinitionalConstants
    def file_type(file)
      ret = File.ftype(file).to_sym
      if ret == :file
        if File.zero?(file)
          :zero_length
        elsif File.file?(file)
          :data
        else
          ret
        end # if
      else
        ret
      end # if
    rescue StandardError => exception_raised
      exception_raised
    end # file_type

    def recurse?(file)
      file_type(file) == :directory # not link (can cause infinite loops)
    end # recurse?

    def data_hash(file)
      file_contents = IO.read(file).chomp
      net_device_status = { File.basename(file).to_sym => file_contents }
    rescue StandardError => exception_raised
      { File.basename(file).to_sym => exception_raised }
    end # data_hash

    def path_hash(path)
      if file_type(path) == :directory
        { File.basename(path).to_sym => FileTree.directory_hash(path + '/*') }
      elsif file_type(path) == :link # not link (can cause infinite loops)
        {}
      else
        data_hash(path)
      end # if
    end # path_hash

    # terminates for link files to avoid recursion
    def directory_hash(directory)
      ret = {}
      Dir[directory + '/*'].each do |file|
        if (block_given? && yeild) || recurse?(file)
          ret = ret.merge(File.basename(file).to_sym => FileTree.path_hash(file + '/*'))
        elsif File.file?(file) && !File.zero?(file)
          ret = ret.merge(data_hash(file))
        end # if
      end # each
      ret
    end # directory_hash

    # provide path around termination condition for links
    def file_tree(directory)
      ret = {}
      Dir[directory + '/*'].each do |file|
        directory_hash(directory)
        if recurse?(file) || file_type(directory) == :link # can cause infinite loops
          ret = ret.merge(File.basename(file).to_sym => FileTree.file_tree(file + '/*'))
        elsif File.file?(file) && !File.zero?(file)
          ret = ret.merge(data_hash(file))
        end # if
      end # each
      ret
    end # file_tree
  end # ClassMethods
  extend ClassMethods
  module Constants # constant objects of the type (e.g. default_objects)
    include DefinitionalConstants
  end # Constants
  include Constants
  require_relative '../../app/models/assertions.rb'
  module Assertions
    module ClassMethods
      def assert_pre_conditions(message = '')
        message += "In assert_pre_conditions, self=#{inspect}"
        #	asset_nested_and_included(:ClassMethods, self)
        #	asset_nested_and_included(:Constants, self)
        #	asset_nested_and_included(:Assertions, self)
        self
      end # assert_pre_conditions

      def assert_post_conditions(message = '')
        message += "In assert_post_conditions, self=#{inspect}"
        self
      end # assert_post_conditions
    end # ClassMethods
    def assert_pre_conditions(message = '')
      message += "In assert_pre_conditions, self=#{inspect}"
      self
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
      message += "In assert_post_conditions, self=#{inspect}"
      self
    end # assert_post_conditions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # self.assert_pre_conditions
  module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
    include DefinitionalConstants
    include Constants
    Net_directory = '/sys/class/net'.freeze
    Lo_hash = FileTree.directory_hash(Net_directory + '/lo')
    Net_file_tree_hash = FileTree.directory_hash(Net_directory)
  end # Examples
end # FileTree
