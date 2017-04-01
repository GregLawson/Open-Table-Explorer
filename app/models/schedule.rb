###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'virtus'
require_relative '../../app/models/interactive_bottleneck.rb'
class Resource
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
		Cpu_info_header_regexp = /cpu cores\t: /
		Cpu_info_number_regexp = /[0-9]+/.capture(:cores)
		Cpu_info_regexp = Cpu_info_header_regexp * Cpu_info_number_regexp
	end # DefinitionalConstants
  include DefinitionalConstants

  module DefinitionalClassMethods
  include DefinitionalConstants

	def sample_resources
		[StatResource.new, MemoryResource.new, LoadAverageResource.new, SchedulingResource.new]
	end # resources
	
	def saturated?
		sample_resources.any? do |resource|
			resource.saturated?
		end # any?
	end # saturated?
	
	def cores
		line = ShellCommands.new('grep cores /proc/cpuinfo').output.split("\n").uniq[0]
		line.capture?(DefinitionalConstants::Cpu_info_regexp).output[:cores].to_i
	end # cores

  end # DefinitionalClassMethods

	def saturated?
		metric.enumerate(:any?) do |m|
			m >= saturation
		end # enumerate(:any?)
	end # saturated?
	
end # Resource

class StatResource < Resource
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
		Cpu_info_number_regexp = /[0-9]+/.capture(:cores)
	end # DefinitionalConstants

	def acquisition
		IO.read('/proc/stat')
	end # acquisition
		
	def metric
		acquisition.split("\n")
	end # metric
	
	def saturation
		cores
	end # saturation
end # StatResource

class MemoryResource < Resource
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
		Acquisition =	IO.read('/proc/meminfo')
		Cpu_info_number_regexp = /[0-9]+/.capture(:cores)
	end # DefinitionalConstants
	
	def acquisition
		IO.read('/proc/meminfo')
	end # acquisition
		
	def header_regexp
		/cpu cores\t: /
	end # header_regexp
	
	def metric
			Acquisition.split("\n")
	end # metric
	
	def saturation
	end # saturation
end # MemoryResource

class LoadAverageResource < Resource
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
		Acquisition =	IO.read('/proc/meminfo')
		Cpu_info_number_regexp = /[0-9]+/.capture(:cores)
	end # DefinitionalConstants
	
	def acquisition
		IO.read('/proc/meminfo')
	end # acquisition
		
	def metric
		Acquisition.split(" ")
	end # metric
	
	def saturation
		cores - 0.5
	end # saturation
end # LoadAverageResource

class DiskResource < Resource
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
		Acquisition =	IO.read('/proc/meminfo')
		Cpu_info_number_regexp = /[0-9]+/.capture(:cores)
	end # DefinitionalConstants
	
	def acquisition
		IO.read('/proc/diskstats')
	end # acquisition
		
	def saturation
	end # saturation
end # DiskResource

class Schedule
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
		Slowest_priority = 1
		Slower_priority = Slowest_priority + 1
		Regression_priority = Slower_priority + 1
		Interactive_priority = Regression_priority + 1
	end # DefinitionalConstants
  include DefinitionalConstants
  module DefinitionalClassMethods
  include DefinitionalConstants
	def saturated?
		if idle_cpus == 0
			true
		elsif load_average >= cores - 0.5
			true
		elsif free_memory = 0
			true
		else
			false
		end # if
	end # saturated?
	
	def load_average
		IO.read('/proc/loadavg').split(" ")
	end # idle_cpus

	def cpus
		IO.read('/proc/stat').split("\n")
	end # cpus

	def memory
			ShellCommands.new('grep Free /proc/meminfo').split("\n")
	end # memory

		def change_working_directory(new_directory)
			cleanup
		end # change_working_directory
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods
  include Virtus.value_object
  values do
		attribute :thread, Thread
    attribute :priority, Fixnum
    attribute :terminal, Pathname, default: Pathname.new('/dev/pts/1')
    attribute :branch, Branch, :default => nil # nil == multi-branch? or current branch/ repo
  end # values

	def scheduler
		
	end # scheduler
	
	def change_working_directory
		cleanup
	end # change_working_directory

	def find_trouble
	end # find_trouble

	def push
	end # push

	def cleanup
    TestInteractiveBottleneck.clean_directory
	end # cleanup
	
	def pull
	end # pull

	def run_slower_tests
	end # run_slower_tests
	
	def run_slowest_tests
	end # run_slowest_tests
	
  module Constructors # such as alternative new methods
    include DefinitionalConstants
  end # Constructors
  extend Constructors
  module ReferenceObjects # constant objects of the type (e.g. default_objects)
    include DefinitionalConstants
#		DefaultSchedule = S
  end # ReferenceObjects
  include ReferenceObjects
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
    include ReferenceObjects
  end # Examples
end # Minimal
