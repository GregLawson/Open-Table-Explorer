###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'virtus'
# require_relative '../../app/models/no_db.rb'
class ObjectMemory
  module ClassMethods
    # include DefinitionalConstants
    def method_query(m, owner)
      ObjectSpace.each_object(owner) do |object|
        next unless object.respond_to?(m.to_sym)
        begin
          theMethod = object.method(m.to_sym)
          return theMethod
        rescue ArgumentError, NameError => exc
          puts "exc=#{exc}, object=#{object.inspect}"
        end # begin
        # if
      end # each_object
      nil # no object found, new has side effects
    end # method_query

    def all_methods
      ret = []
      ObjectSpace.each_object(Method) do |m|
        ret << m
      end # each_object
      #	ret=ret.sort{|x,y| (x.name)<=>(y.name)}
      #	ret=ret.map {|method| new_from_method(method)}
      ret # .uniq
    end # methods

    def classes
      ret = []
      ObjectSpace.each_object(Class) do |c|
        ret << c
      end # each_object
      ret = ret.sort { |x, y| x.inspect <=> y.inspect } # for anonomous classes #name is nil
      ret
    end # classes

    def modules
      ret = []
      ObjectSpace.each_object(Module) do |mod|
        ret << mod
      end # each_object
      ret = ret.sort { |x, y| x.inspect <=> y.inspect }
      ret - classes
    end # modules

    def classes_and_modules
      @@CLASSES_AND_MODULES ||= classes + modules
    end # classes_and_modules

    def all_instance_methods
      classes_and_modules.map { |c| c.instance_methods(false).map { |m| new(m, c, :instance) } }.flatten
    end # all_instance_methods

    def all_class_methods
      classes_and_modules.map { |c| c.methods(false).map { |m| new(m, c, :class) } }.flatten
    end # all_class_methods

    def all_singleton_methods
      classes_and_modules.map { |c| c.singleton_methods(false).map { |m| new(m, c, :singleton) } }.flatten
    end # all_singleton_methods

    def all
      @@ALL ||= (all_methods + all_instance_methods + all_class_methods + all_singleton_methods)
      @@ALL
    end # all

    def first
      all.first
    end # first

    def find_by_name(name)
      all.find_all { |i| i[:name].to_sym == name.to_sym }
    end # find_by_name

    def owners_of(method_name)
      find_by_name(method_name).map { |i| { owner: i[:owner], scope: i[:scope] } }
    end # owners_of

    def constantized
      @@CONSTANTIZED ||= Module.constants.map do |c|
        begin
           c = c.constantize
         rescue
           puts "constant #{c.inspect} fails constanization"
           nil
         end # begin
      end # map
    end # constantized
  end # ClassMethods
  extend ClassMethods
  module Examples
    class EmptyClass
    end
  end # Examples
end # ObjectMemory
