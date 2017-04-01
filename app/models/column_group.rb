###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# require 'app/models/global.rb'
module ColumnGroup
  module ClassMethods
    def defaulted_primary_logical_key?
      if methods(false).include?('logical_primary_key')
        return nil
      else
        return true
      end # if
    end # defaulted_primary_logical_key

    def default_logical_primary_key
      if logical_attributes.include?(:name)
        return [:name]
      else
        candidate_logical_primary_key = logical_attributes
        if !candidate_logical_primary_key.empty?
          return candidate_logical_primary_key
        else
          model_history_type = history_type?
          if model_history_type == []
            raise "Can't find a default primary logical key in #{inspect}."
          else
            return model_history_type[0..0] # first prioritized column
          end # if
          return [:id]
        end # if
        return logical_attributes
      end # if
    end # default_logical_primary_key

    # Override if default is wrong.
    def logical_primary_key
      default_logical_primary_key
    end # logical_primary_key

    def attribute_ddl(attribute_name)
      table_sql = to_sql
      attribute_sql = table_sql.grep(attribute_name)
      attribute_sql
    end # attribute_ddl

    def attribute_ruby_type(attribute_name)
      first[attribute_name].class
    end # attribute_ruby_type

    def attribute_rails_type(attribute_name)
      first[attribute_name].class
    end # attribute_rails_type

    def candidate_logical_keys_from_indexes
      indexes = connection.indexes(name.tableize)
      if indexes != []
        indexes.map(&:columns) # map
      else
        return nil
        end # if
    end # candidate_logical_keys_from_indexes

    # Is attribute an numerical (analog) (versus categorical (digital) value)
    # default logical primary keys ignore analog values
    # Statistical procedures will treat these attributes as continuous
    # override for specific classes
    # by default the following are considered analog:
    #  Float
    #  Time
    #  DateTime
    #  id for sequential_id?
    def numerical?(attribute_name)
      if %w(created_at updated_at).include?(attribute_name.to_s)
        return true
      elsif [Float, Bignum, DateTime, Time].include?(attribute_ruby_type(attribute_name))
        return true
      elsif categorical?(attribute_name)
        return false
      else
        return false
      end # if
    end # numerical

    def probably_numerical?(attribute_name)
      if [Date].include?(attribute_ruby_type(attribute_name))
        return true
      else
        return false
      end # if
    end # probably_numerical

    def categorical?(attribute_name)
      if [Symbol].include?(attribute_ruby_type(attribute_name))
        return true
      elsif foreign_key_names.include?(attribute_name.to_s)
        parent = association_class(foreign_key_to_association_name(attribute_name))
        return !parent.sequential_id?
      elsif defaulted_primary_logical_key?
        if attribute_name.to_sym == :id
          return logical_attributes == []
        else
          return false
        end # if
      else # overridden logical primary key
        if attribute_name.to_sym == :id
          return !sequential_id?
        else
          return logical_primary_key.include?(attribute_name)
        end # if
      end # if
    end # categorical

    def probably_categorical?(attribute_name)
      if [String, NilClass].include?(attribute_ruby_type(attribute_name))
        return true
      elsif attribute_name.to_sym == :id
        if defaulted_primary_logical_key?
          return logical_attributes == []
        else # overridden logical primary key
          return logical_primary_key.include?(:id)
        end # if
      else
        return false
      end # if
    end # probably_categorical

    def column_symbols
      column_names.map(&:to_sym)
    end # column_symbols

    def logical_attributes
      (column_symbols - History_columns).select { |name| !numerical?(name) } # avoid :id recursion
    end # logical_attributes

    def is_logical_primary_key?(attribute_names)
      quoted_primary_key
      if respond_to?(:logical_primary_key)
        if Set[logical_primary_key] == Set[attribute_names]
          return true
        end # if
      end # if
      attribute_names.each do |attribute_name|
        if attribute_name == 'id'
          return false
        elsif !column_names.include(attribute_name.to_s)
          return false
        end # IF
      end # each
      if count == count(distinct: true, select: attribute_names)
        return true
      else
        return false
      end # if
      true # if we get here
    end # logical_primary_key
    History_columns = [:updated_at, :created_at, :id].freeze
    def history_type?
      history_type = [] # nothing yet
      History_columns.each do |history_column|
        history_type << history_column if column_symbols.include?(history_column)
      end # each
      history_type
    end # history_type

    def sequential_id?
      history_types_not_in_logical_key = history_type? - logical_primary_key
      history_types_not_in_logical_key != history_type?
    end # sequential_id

    def logical_primary_key_recursive
      if sequential_id?
        return logical_primary_key
      else
        foreign_keys = logical_primary_key.map do |e|
          if is_foreign_key_name?(e)
            association_name = foreign_key_to_association_name(e)
            association = first.foreign_key_to_association(association_name)
            if association.nil?
              nil
            else
              association.class.logical_primary_key_recursive
            end # if
          else
            e.to_sym
          end # if
        end # map
        { name => foreign_keys }
      end # if
    end # logical_primary_key_recursive
  end # ClassMethods
end # ColumnGroup
