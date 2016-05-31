###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/stream_tree.rb'
class FileTree
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
  end # DefinitionalConstants
  include DefinitionalConstants
  module ClassMethods
    include DefinitionalConstants
    def file_type(file)
      if File.exist?(file)
        ret = File.ftype(file).to_sym
        if ret == :file
          if File.zero?(file)
            :zero_length
          elsif File.file?(file)
            :data
          else
            :file
          end # if
        else
          ret
        end # if
      else
        :nonexistant_path
      end # if
    rescue StandardError => exception_raised
      exception_raised
    end # file_type

    def recurse?(file)
      file_type(file) == :directory # not link (can cause infinite loops)
    end # recurse?

    def data_hash_value(file)
      file_type = file_type(file)
      case file_type
      when :data then IO.read(file).chomp
      when :link then File.readlink(file)
      else
        file_type
        end # if
    rescue StandardError => exception_raised
      exception_raised
    end # data_hash_value

    def path_hash_value(path)
      if file_type(path) == :directory
        directory_hash_value(path)
      else
        data_hash_value(path)
      end # if
    end # path_hash_value

    # terminates for link files to avoid recursion
    def directory_hash_value(directory)
      ret = {}
      Dir[directory + '/*'].each do |file|
        if (block_given? && yield(file)) || recurse?(file)
          ret = ret.merge(File.basename(file).to_sym => FileTree.directory_hash_value(file))
        else
          ret = ret.merge(File.basename(file).to_sym => FileTree.data_hash_value(file))
        end # if
      end # each
      ret
    end # directory_hash_value

    # provide path around termination condition for links
    def file_tree(directory)
      directory_hash_value(directory) { |file| recurse?(file) || file_type(directory) == :link }
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
    Lo_hash = FileTree.directory_hash_value(Net_directory + '/lo')
    Net_file_tree_hash = FileTree.file_tree(Net_directory)
  end # Examples
end # FileTree
