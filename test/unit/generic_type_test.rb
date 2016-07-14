###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative 'test_environment'
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/unit.rb'
require_relative '../assertions/generic_type_assertions.rb'
require_relative '../../app/models/method_model.rb'
class GenericType # < ActiveRecord::Base
  include RailsishRubyUnit::Executable.model_class?::Examples
include GenericTypeAssertions
extend GenericTypeAssertions::ClassMethods
end #class GenericType < ActiveRecord::Base

class GenericTypeTest < TestCase
  def test_GenericType_Dry

		example = GenericType.new(name:  :name,
														data_regexp: 'data_regexp',
														generalize: :generalize,
														rails_type: 'rails_type',
														ruby_conversion: 'ruby_conversion',
										age: '21'
													)

		assert_equal(:name, example.name, example.inspect)
	end # GenericType
	
	include RubyAssertions
	
	module Examples
		Text=GenericType::Text
		Ascii=GenericType::Ascii
		Alpha=GenericType.find_by_name('alpha')
		Alnum=GenericType.find_by_name('alnum')
		Digit=GenericType.find_by_name('digit')
		Lower=GenericType.find_by_name('lower')
		Upper=GenericType.find_by_name('upper')
		Xdigit=GenericType.find_by_name('xdigit')
		Print=GenericType.find_by_name('print')
		Graph =GenericType.find_by_name('graph')
		Punct =GenericType.find_by_name('punct')
		Word =GenericType.find_by_name('word')
		Blank = GenericType.find_by_name('blank')
		Space=GenericType.find_by_name('space')
		Cntrl = GenericType.find_by_name('cntrl')
		Macaddr=GenericType.find_by_name('Macaddr_Column')
		Integer=GenericType.find_by_name('Integer_Column')
		VARCHAR_Column=GenericType.find_by_name('VARCHAR_Column')
	end #  Examples
	include Examples
	
		def test_primary_key_index
			message = MethodModel.ancestor_method_names(GenericType, instance: false).inspect
#			message = MethodModel.ancestor_method_names(NoDB::ClassMethods, instance: false).inspect
			assert_includes(NoDB::ClassMethods.instance_methods(false), :data_source_yaml, message)
			assert_includes(NoDB::ClassMethods.instance_methods(true), :data_source_yaml, message)
#			assert_includes(NoDB.methods(true), :data_source_yaml, message)

			assert_includes(GenericType.methods(true), :data_source_yaml, message)
			yaml_table_name = 'generic_types'
#			unit_data_source_directory = RailsishRubyUnit::Executable.data_sources_directory?
#      unit_data_source_directory + "/#{yaml_table_name}.yml"
			data_source_file = 'test/fixtures/' + yaml_table_name + '.yml'
      yaml = YAML.load(File.open(data_source_file))

#			yaml = GenericType.data_source_yaml('generic_types')
			message = yaml.inspect
			assert_instance_of(Hash, yaml, message)
			assert_includes(yaml.keys, 'Text_Column', message)
			ret = {}
			yaml.each_pair do |key, value|
				message = key + '=>' + value.inspect
				assert_equal(key, value['import_class'], message)

				assert_instance_of(Symbol, value['import_class'].to_sym, message)
				assert_instance_of(Regexp, Regexp.new(value['data_regexp']), message) 
#				assert_instance_of(GenericType, value['generalize'], message) 
#				refute_nil(value['rails_type'], value.inspect) 
#				assert_instance_of(Symbol, value['rails_type'].to_sym, message) 
#				assert_instance_of(GenericColumn, value['import_class'], message) 
				assert_instance_of(String, value['ruby_conversion'], message) 

				name = value['import_class'].to_sym
				ret[name] = GenericType.new(name: name,
														data_regexp: Regexp.new(value['data_regexp']),
														generalize: value['generalize'].to_sym,
														rails_type: value['rails_type'],
														ruby_conversion: value['ruby_conversion'] 
													)
				refute_nil(ret[name].name, ret[name].inspect)
				ret[name].assert_pre_conditions
			end # each_pair
			ret.each_pair do |key, value|
				value.assert_pre_conditions
			end # each_pair
			refute_nil(ret[:Text_Column].name, ret.inspect)
			assert_equal(GenericType.primary_key_index.keys, ret.keys, yaml.inspect)
			assert_equal(GenericType.primary_key_index, ret, yaml.inspect)
		end # primary_key_index

  def test_GenericType_DefinitionalConstants
  end # DefinitionalConstants

		def test_all
			refute_includes(GenericType.all.map(&:name), nil, GenericType::DefinitionalConstants::Primary_key_index.inspect)
			GenericType.all.each do |generic_type|
				generic_type.assert_pre_conditions
			end # each_pair
			assert_includes(GenericType.all, Text, GenericType::DefinitionalConstants::Primary_key_index.inspect)
		end # all

def test_logical_primary_key
#	first=GenericType.first
    assert_equal([:name], GenericType.logical_primary_key)
end #logical_primary_key

  def test_find_by_name
    macro_name = :lower
		macro_generic_type = GenericType::DefinitionalConstants::Primary_key_index[macro_name.to_sym]
		message = "GenericType.find_by_name('#{macro_name}')=#{GenericType.find_by_name(macro_name)} should be in #{GenericType.all.map(&:name).inspect}"
		message += "\n\n" + macro_generic_type.inspect
    refute_nil(macro_generic_type, message)
    assert_equal(macro_name, macro_generic_type.name, message)
    assert_equal(macro_name.to_sym, macro_generic_type.name, message)
    macro_generic_type = GenericType.find_by_name(macro_name)
    refute_nil(macro_generic_type, message)
    assert_equal(macro_name.to_sym, macro_generic_type.name, message)
		refute_nil(Text.name, GenericType::DefinitionalConstants::Primary_key_index.inspect)
end #find_by_name

  def test_GenericType_ReferenceObjects

		refute_nil(Text.name, Text.inspect)
		refute_nil(Ascii.name, Text.inspect)
  end # ReferenceObjects

	def test_generalizations
		assert_equal(GenericType::Most_general.generalize.to_sym, GenericType::Most_general.name)
		assert_equal([], GenericType::Most_general.generalizations)
		assert(GenericType.all.any? {|g| g.generalizations.empty?})
		assert(GenericType.all.any? {|g| !g.generalizations.empty?})
		assert_instance_of(GenericType, Digit)
		assert_equal(false, Digit.most_general?)
		assert_equal([Text], VARCHAR_Column.generalizations)
		assert_equal([Text, VARCHAR_Column], Integer.generalizations([Text, VARCHAR_Column]))
		assert_equal([VARCHAR_Column, Text], Integer.generalizations)
#    assert_equal(%w(Text_Column VARCHAR_Column ascii print graph word alnum xdigit), digit_generic_type.generalizations.map(&:name))
    assert_includes(GenericType.find_by_name('Integer_Column').generalizations.map(&:name), :VARCHAR_Column)
    assert_includes(GenericType.find_by_name('Integer_Column').generalizations.map(&:name), :Text_Column)
		
		refute_empty(Word.generalizations)
		refute_empty(Graph.generalizations)
		refute_empty(Print.generalizations)
		refute_empty(Ascii.generalizations)
		GenericType.all.each do |t|
			assert_instance_of(GenericType, t)
#			assert_instance_of(Array, t.generalizations)
#     unless t.generalizations.empty?
#        assert_instance_of(GenericType, t.generalizations[0])
#      end # if
    end # each
#    assert_equal_sets(%w(VARCHAR_Column Text_Column), GenericType.find_by_name('Integer_Column').generalizations.map(&:name))
  end # generalizations

  def test_most_general?
		message = GenericType::Most_general.inspect
    assert_equal(:Text_Column, GenericType::Most_general.generalize, message)
    assert_equal(GenericType::Most_general.generalize.to_sym, GenericType::Most_general.name, message)
    assert(GenericType::Most_general.generalize.to_sym == GenericType::Most_general.name, message)
    assert(GenericType::Most_general.generalize == :Text_Column, message)
    refute(GenericType::Most_general.generalize.nil?, message)
    assert(GenericType::Most_general.most_general?, message)
		GenericType.all.each do |generic_type|
			unless generic_type == Text
				refute_nil(generic_type.generalize, generic_type.inspect)
				refute(generic_type.most_general?, generic_type.inspect)
			end # unless
		end # each
  end # most_general?

	def test_specialize
		assert_equal([VARCHAR_Column], GenericType::Most_general.specialize)
		assert(GenericType.all.any? {|g| g.specialize.empty?})
		assert(GenericType.all.any? {|g| !g.specialize.empty?})
		assert_instance_of(GenericType, Digit)
		assert_equal(false, Digit.most_general?)
		assert_equal_sets([:Integer_Column, :Float_Column, :Macaddr_Column, :Time_Column, :Timestamp_Column, :NULL_Column, :Boolean_Column, :Inet_Column, :Byte], VARCHAR_Column.specialize.map(&:name))
		assert_equal([], Integer.specialize.map(&:name))
		assert_equal([Digit], Xdigit.specialize)
		assert_equal([[]], Xdigit.specialize.map{|s| s.specialize})
		assert_equal_sets([Alpha, Xdigit], Alnum.specialize)
		assert_equal_sets([Cntrl, Print, Space], Ascii.specialize)
    assert_equal_sets([:graph, :blank], Ascii.specialize.map{|s| s.specialize}.flatten.map(&:name))
		assert_equal([[], [Graph], [Blank]], Ascii.specialize.map{|s| s.specialize})
		assert_equal_sets([Graph, Blank], Ascii.specialize.map{|s| s.specialize}.flatten.uniq)
	end # specialize
	
	def test_unspecialized
	#	assert_empty(Digit.specialize)
		refute(Xdigit.unspecialized?)
		assert(Digit.unspecialized?)
		refute_empty(GenericType::Most_general.specialize)
		refute(GenericType::Most_general.unspecialized?)
		all_unspecialized = GenericType.all.select do |generic_type|
			generic_type.unspecialized?
		end # select
		assert_equal_sets([:Integer_Column, :Float_Column, :Macaddr_Column, :Time_Column, :Timestamp_Column, :NULL_Column, :Boolean_Column, :Inet_Column, :blank, :cntrl, :digit, :lower, :punct, :upper], all_unspecialized.map(&:name), all_unspecialized.inspect)
		refute(Alnum.unspecialized?)
		assert(Digit.unspecialized?)
	end # unspecialized?

	def test_one_level_specializations
		assert(GenericType.all.any? {|t| !t.one_level_specializations.empty?})
		GenericType.all.each do |t|
			assert_instance_of(GenericType, t)
			assert_instance_of(Array, t.one_level_specializations)
			unless t.one_level_specializations.empty?
				assert_instance_of(GenericType, t.one_level_specializations[0])
			end #if
		end #each
		assert_includes(VARCHAR_Column.one_level_specializations.map(&:name), :Integer_Column)
		refute_includes(Text.one_level_specializations.map(&:name), :Integer_Column)
		refute_includes(Text.one_level_specializations.map(&:name), :Text_Column)
		assert_equal([:cntrl, :print, :space], Ascii.one_level_specializations.map(&:name))
		assert_equal([Digit], Xdigit.one_level_specializations)
		assert_equal_sets([Alpha, Xdigit], Alnum.one_level_specializations)
    assert_equal([:cntrl, :print, :space], Ascii.one_level_specializations.map(&:name))
	end # one_level_specializations

	def test_recursive_specializations
		GenericType.all.each do |generic_type|
			if generic_type.unspecialized?
				assert_equal([], generic_type.recursive_specializations) 
			end # if
		end # each
		
		assert_equal([], Xdigit.specialize.map{|s| s.recursive_specializations}.flatten.uniq)
		assert_equal([Digit], (Xdigit.specialize.map{|s| s.recursive_specializations}.flatten.uniq + Xdigit.one_level_specializations).uniq - [Xdigit])
		assert_equal([Digit], Xdigit.recursive_specializations)

		assert_equal_sets([[Lower, Upper], [Digit]], Alnum.specialize.map{|s| s.specialize})
#		assert_equal([[Digit], [Lower, Upper]], Alnum.specialize.map{|s| s.recursive_specializations})
		assert_equal_sets([Lower, Upper, Digit], Alnum.specialize.map{|s| s.recursive_specializations}.flatten.uniq)
		assert_equal_sets([Lower, Upper, Digit], (Alnum.specialize.map{|s| s.recursive_specializations}.flatten.uniq + Xdigit.one_level_specializations).uniq - [Xdigit])
		assert_equal_sets([Lower, Upper, Digit, Alpha, Xdigit], Alnum.recursive_specializations)

		refute_empty(Text.recursive_specializations)
		refute_empty(Alpha.recursive_specializations)
		refute_empty(Alnum.recursive_specializations)
		assert_empty(Digit.recursive_specializations)
		assert_empty(Lower.recursive_specializations)
		assert_empty(Upper.recursive_specializations)
		refute_empty(Xdigit.recursive_specializations)
		assert_empty(Punct.recursive_specializations)
		assert_empty(Blank.recursive_specializations)
		refute_empty(Space.recursive_specializations)
		assert_empty(Cntrl.recursive_specializations)
		assert_empty(Macaddr.recursive_specializations)
		assert_empty(Integer.recursive_specializations)
		refute_empty(VARCHAR_Column.recursive_specializations)

		refute_empty(Word.recursive_specializations)
		refute_empty(Graph.recursive_specializations)
		refute_empty(Print.recursive_specializations)
		refute_empty(Ascii.recursive_specializations)

		assert_equal([:digit,  :lower, :upper,  :xdigit,  :alpha,  :alnum, :punct,  :word, :graph,  :blank,  :cntrl,  :print,  :space], Ascii.recursive_specializations.map(&:name))

		single_specializations = GenericType.all.select do |generic_type|
			generic_type.specialize.size == 1
		end # select
		assert_equal_sets([:Text_Column, :print, :space, :xdigit, :word, :Byte], single_specializations.map(&:name), single_specializations.inspect)
		single_specializations.each do |single_specialization|
			assert_includes(single_specialization.one_level_specializations.map(&:name), single_specialization.specialize[0].name)
#			assert_equal([:punct, :word], single_specialization.specialize.map{|s| s.specialize}.flatten.map(&:name), single_specialization.inspect)

#			assert_equal_sets([:punct, :word], single_specialization.recursive_specializations.flatten.map(&:name), single_specialization.inspect)
#			assert_equal_sets([:punct, :word], single_specialization.specialize.map{|s| s.recursive_specializations}.flatten.map(&:name), single_specialization.inspect)
#			assert_includes(single_specialization.recursive_specializations.map(&:name), single_specialization.specialize[0].name)
		end # each
		
		GenericType.all.select do |generic_type|
#			assert([], generic_type.recursive_specializations) 
		end # select
    assert_equal_sets(%w(lower upper digit alpha xdigit alnum word punct graph blank cntrl print space), Ascii.recursive_specializations.map(&:name).map(&:to_s))
#	assert_equal(["lower", "upper", "digit", "alpha", "xdigit", "alnum", "word", "punct", "graph", "blank", "cntl", "print", "space"], GenericType.find_by_name('Text_Column').recursive_specializations.map{|g| g.name})

#	assert_equal(["lower", "upper", "digit", "alpha", "xdigit", "alnum", "word", "punct", "graph", "blank", "cntl", "print", "space"], GenericType.find_by_name('Text_Column').recursive_specializations.map{|g| g.name})
	GenericType.all.each do |g|
		assert_instance_of(Array, g.recursive_specializations)
	end #each
	end # recursive_specializations

  def test_expansion_termination
    regexp = Xdigit[:data_regexp]
    assert_regexp(regexp)
#    parse = RegexpTree.new(regexp)[0]
#    macro_name = RegexpTree.macro_call?(parse)
#    assert_instance_of(String, macro_name)
#    assert_equal(Xdigit.name, macro_name)
#    assert(Xdigit.expansion_termination?, "Xdigit=#{Xdigit.inspect}.\n regexp=#{regexp}, parse=#{parse.inspect}\n macro_name=#{macro_name}")
  end # expansion_termination

  def test_expand
    regexp = Macaddr[:data_regexp]
    assert_regexp(regexp)
#    parse = RegexpTree.new(regexp)
#    macro_name = RegexpTree.macro_call?(parse)
#    refute_equal(macro_name, Macaddr.name)
#    expansion = parse.map_branches do |branch|
#      macro_name = branch.macro_call?
#      if macro_name
#			refute_empty(macro_name, "macro_name=#{macro_name} should be in #{GenericType.all.map{|t| t.name}.inspect}")
			all_macro_names= GenericType.all.map{|t| t.name}
#        assert_includes(macro_name, all_macro_names)
#        macro_generic_type = GenericType.find_by_name(macro_name)
#        refute_nil(macro_generic_type, "GenericType.find_by_name('#{macro_name}')=#{GenericType.find_by_name(macro_name)} should be in #{all_macro_names.inspect}")
#        macro_call = macro_generic_type[:data_regexp]
#        refute_nil(macro_call, '')
#        refute_equal(macro_call, regexp)
#        assert_equal(macro_name, macro_generic_type.name)
#        assert_equal(branch, macro_generic_type.expand, "macro_name=#{macro_name},\n")
#        macro_generic_type.expand
#      else
#        branch
#      end # if
#    end # map_branches
#    assert_equal(expansion, parse.map_branches { |branch| branch })
  end # expand

  def test_match
#    regexp = Regexp.new(Text.expand.join)
#    assert_regexp(regexp)
#    string_to_match = '123'
#    assert_match(regexp, string_to_match)
#	refute_nil(Text.match_exact?(string_to_match))
  end # match

  def test_match_Start
  end # match_start

  def test_match_end
  end # match_end

  def test_match_any
  end # match_any

  def test_specializations_that_match
    regexp = Regexp.new(Text[:data_regexp])
    assert_regexp(regexp)
    string_to_match = '123'
    message = "Text=#{Text}, Text.match_exact?(string_to_match)=#{Text.match_exact?(string_to_match)}"
    assert(Text.match_exact?(string_to_match), message)
    ret = Text.one_level_specializations.map do |specialization|
      assert(specialization.match_exact?(string_to_match))
      if specialization.match_exact?(string_to_match)
        [specialization, specialization.specializations_that_match?(string_to_match)]
      end # if
    end.compact.uniq # map
    assert_equal(ret, ret.compact)
    assert(Lower.unspecialized?)
    assert(!Alpha.unspecialized?)
    assert(!Xdigit.unspecialized?)
#    Ascii.assert_specializations_that_match([[:alpha, [:lower, :xdigit]]], 'c')
    Alnum.assert_specializations_that_match([:alpha, [:lower], :xdigit], 'c')
    Alnum.assert_specializations_that_match([:alpha, [:lower], :xdigit], 'c')
#    assert_equal([:alpha, [:lower], :xdigit], Alnum.specializations_that_match?('c').map { |s| s.name.to_sym }, Alnum.specializations_that_match?('c').map { |s| s.name.to_sym }.inspect)
#    assert_equal([:print, [:graph, [:word, [:alnum, [:alpha, [:lower], :xdigit]]]]], Ascii.specializations_that_match?('c').map { |s| s.name.to_sym }, Ascii.specializations_that_match?('c').map { |s| s.name.to_sym }.inspect)
#    assert_equal([:VARCHAR_Column, [:Integer_Column]], Text.specializations_that_match?(string_to_match).map { |s| s.name.to_sym }, Text.specializations_that_match?(string_to_match).map { |s| s.name.to_sym }.inspect)
  end # specializations_that_match

  def test_possibilities
    common_matches = Ascii.common_matches?('c')
    assert_kind_of(Array, common_matches)
    assert_kind_of(Array, common_matches[1])
    message = "common_matches=#{common_matches.inspect}"
    alternatives = [[Lower, Xdigit]]
    assert_equal(alternatives, Ascii.possibilities?(alternatives))
    tail = [Alpha, [Lower]]
    assert_equal([:lower], Ascii.possibilities?(tail).map { |s| s.name.to_sym })
    fork = [Alpha, [Lower], Xdigit]
    assert_equal([:lower, :xdigit], Ascii.possibilities?(fork).map { |s| s.name.to_sym })
    ambiguity = [Alnum, [Alpha, [Lower], Xdigit]]
    assert_equal([:lower, :xdigit], Ascii.possibilities?(ambiguity).map { |s| s.name.to_sym })
#    assert_equal([:print, [:graph, [:word, [:alnum, [:alpha, [:lower], :xdigit]]]]], Ascii.specializations_that_match?('c').map { |s| s.name.to_sym }, Ascii.specializations_that_match?('c').map { |s| s.name.to_sym }.inspect)
#    assert_equal([:alpha, [:lower], :xdigit], Alnum.specializations_that_match?('c').map { |s| s.name.to_sym }, Alnum.specializations_that_match?('c').map { |s| s.name.to_sym }.inspect)
#    assert_equal([:lower, :xdigit], Ascii.possibilities?(common_matches).map { |p| p.name.to_sym }, message)
#    assert_equal([:lower, :xdigit], Ascii.possibilities?(common_matches[1]).map { |p| p.name.to_sym }, message)
#    assert_equal([:lower, :xdigit], Ascii.possibilities?(common_matches).map { |p| p.name.to_sym }, message)
    Ascii.assert_possibilities([:lower, :xdigit], 'c')
    Lower.assert_possibilities([:lower], 'c')
    Ascii.assert_possibilities([:digit], '9')
    Lower.assert_possibilities([:digit], '9')
    Digit.assert_possibilities([:xdigit], 'c')
  end # possibilities

  def test_most_specialized
    Lower.assert_common_matches([:lower], 'l')
    Lower.assert_most_specialized([:lower], 'l')
    Digit.assert_common_matches([:xdigit], 'c')
    Digit.assert_most_specialized([:xdigit], 'c')
    Ascii.assert_common_matches([:ascii, [:print, [:graph, [:word, [:alnum, [:alpha, [:lower], :xdigit]]]]]], 'c')
    common_matches = Ascii.common_matches?('c')
    assert_kind_of(Array, common_matches)
#    assert_kind_of(Array, common_matches[1])
#    assert_equal([:lower, :xdigit], Ascii.possibilities?(common_matches).map { |p| p.name.to_sym })
#    most_specialized = Ascii.most_specialized?('c', common_matches[1])
#    assert_kind_of(Array, most_specialized)
#    assert_equal([:lower, :xdigit], most_specialized.map { |p| p.name.to_sym })
#    assert_equal([:lower, :xdigit], Ascii.possibilities?(most_specialized).map { |p| p.name.to_sym })
    Ascii.assert_most_specialized([:lower, :xdigit], 'c')
    Lower.assert_common_matches([:alnum, [:xdigit, [:digit]]], '9')
    Lower.assert_most_specialized([:digit], '9')
#    assert_equal([Digit], Lower.most_specialized?('9'))
#    assert_equal([Lower, Xdigit], Text.most_specialized?('c'), Text.most_specialized?('c').map(&:name).inspect) # ambiguous
    refute_empty(Digit.most_specialized?('c'))
#    assert_equal([Xdigit], Digit.most_specialized?('c'))
    Digit.assert_most_specialized([:xdigit], 'c')
  end # most_specialized

  def test_common_matches
    regexp = Regexp.new(Text[:data_regexp])
    assert_regexp(regexp)
    string_to_match = '123'
    assert_match(regexp, string_to_match)
    common_matches = if Text.match_exact?(string_to_match)
                       Text.specializations_that_match?(string_to_match)
                     else
                       Text.generalize.common_matches?(string_to_match)
    end # if
    assert_instance_of(Array, common_matches)
#    assert_equal([VARCHAR_Column, [Integer]], common_matches)
    assert_instance_of(Array, Text.common_matches?('123'))
#    assert_equal([Text, [VARCHAR_Column, [Integer]]], Text.common_matches?('123'))
    mac_example = '12:34:56:78'
    regexp = Macaddr[:data_regexp]
    mac_match = mac_example.capture?(regexp)
#    assert_equal([Text, [VARCHAR_Column, [Macaddr]]], Text.common_matches?(mac_example))
    Digit.assert_common_matches([:xdigit], 'c')
  end # common_matches

  def test_generalize
		integer = GenericType.find_by_name('Integer_Column')
		varchar = GenericType.find_by_name(integer.generalize)
    assert_equal(:VARCHAR_Column, varchar.name)
    GenericType.all.each do |t|
#      refute_equal(t[:generalize_id], 0, "t=#{t.inspect}")
    end # each

    assert(GenericType.all.any? { |t| !t.generalize.nil? })
    GenericType.all.each do |t|
      assert_instance_of(GenericType, t)
      unless t.generalize.nil?
        assert_instance_of(GenericType, GenericType.find_by_name(t.generalize))
      end # if
    end # each
  end # generalize

  def test_assert_specialized_examples
    regexp = GenericType.find_by_name('word')[:data_regexp]
#    assert_equal(2, regexp.size)
#    assert_equal('\w', regexp)
#    assert_equal(/\w/, Regexp.new(regexp))
    #	assert_equal('\w', RegexpTree.string_of_matching_chars(/\w/))
    assert_match(Regexp.new(regexp), 'd')
    GenericType.all.each(&:assert_specialized_examples) # each
  end # assert_specialized_examples

  def test_id_equal
#    assert(!model_class?.sequential_id?, "model_class?=#{model_class?}, should not be a sequential_id.")
#    assert_test_id_equal
  end # id_equal

  def test_GenericType_assert_pre_conditions
		GenericType.assert_pre_conditions
  end # assert_pre_conditions

  def test_GenericType_assert_post_conditions
  end # assert_post_conditions

  def assert_pre_conditions
  end # assert_pre_conditions

  def assert_post_conditions
  end # assert_post_conditions
	
	def test_assert_no_generalize_cycle
		assert_equal(GenericType::Most_general.generalize.to_sym, GenericType::Most_general.name)
		assert_equal([], GenericType::Most_general.assert_no_generalize_cycle)
		assert(GenericType.all.any? {|g| g.assert_no_generalize_cycle.empty?})
		refute(GenericType.all.all? {|g| g.assert_no_generalize_cycle.empty?})
		assert_instance_of(GenericType, Digit)
		assert_equal(false, Digit.most_general?)
		assert_equal([], Text.assert_no_generalize_cycle)
		assert_equal([Text], VARCHAR_Column.assert_no_generalize_cycle)
		assert_equal([VARCHAR_Column, Text], Integer.assert_no_generalize_cycle)
#		assert_equal([Text, VARCHAR_Column], Integer.assert_no_generalize_cycle([Text, VARCHAR_Column]))
#    assert_equal(%w(Text_Column VARCHAR_Column ascii print graph word alnum xdigit), digit_generic_type.assert_no_generalize_cycle.map(&:name))
    assert_includes(GenericType.find_by_name('Integer_Column').assert_no_generalize_cycle.map(&:name), :VARCHAR_Column)
    assert_includes(GenericType.find_by_name('Integer_Column').assert_no_generalize_cycle.map(&:name), :Text_Column)
		
		refute_empty(Word.assert_no_generalize_cycle)
		refute_empty(Graph.assert_no_generalize_cycle)
		refute_empty(Print.assert_no_generalize_cycle)
		refute_empty(Ascii.assert_no_generalize_cycle)
		GenericType.all.each do |t|
			assert_instance_of(GenericType, t)
#			assert_instance_of(Array, t.assert_no_generalize_cycle)
#     unless t.assert_no_generalize_cycle.empty?
#        assert_instance_of(GenericType, t.assert_no_generalize_cycle[0])
#      end # if
    end # each
#    assert_equal_sets(%w(VARCHAR_Column Text_Column), GenericType.find_by_name('Integer_Column').assert_no_generalize_cycle.map(&:name))
		refute_empty(Word.assert_no_generalize_cycle)
		refute_empty(Graph.assert_no_generalize_cycle)
		refute_empty(Print.assert_no_generalize_cycle)
		refute_empty(Ascii.assert_no_generalize_cycle)
		end # assert_no_generalize_cycle

  def test_GenericType_Examples
  end # Examples
end #GenericType

class GenericTypeRepoTest < TestCase
  def test_GenericType_Dry
		example = GenericTypeRepo::Generic_type_repo.create(name:  'name',
														data_regexp: 'data_regexp',
														generalize: 'generalize',
														rails_type: 'rails_type',
														ruby_conversion: 'ruby_conversion',
													)

		assert_equal('name', example.name, example.inspect)
	end # GenericType
	
	module Examples
		Text=GenericType::Text
		Ascii=GenericType::Ascii
		Alpha=GenericType.find_by_name('alpha')
		Alnum=GenericType.find_by_name('alnum')
		Digit=GenericType.find_by_name('digit')
		Lower=GenericType.find_by_name('lower')
		Upper=GenericType.find_by_name('upper')
		Xdigit=GenericType.find_by_name('xdigit')
		Print=GenericType.find_by_name('print')
		Graph =GenericType.find_by_name('graph')
		Punct =GenericType.find_by_name('punct')
		Word =GenericType.find_by_name('word')
		Blank = GenericType.find_by_name('blank')
		Space=GenericType.find_by_name('space')
		Cntrl = GenericType.find_by_name('cntrl')
		Macaddr=GenericType.find_by_name('Macaddr_Column')
		Integer=GenericType.find_by_name('Integer_Column')
		VARCHAR_Column=GenericType.find_by_name('VARCHAR_Column')
	end #  Examples
	include Examples
	
	def test_rom_sql
		GenericTypeRepo::Config.register_relation GenericTypeRepo::Relations::GenericTypes
		GenericTypeRepo::Container.gateways[:default].tap do |gateway|
			migration = gateway.migration do
				change do
					create_table :generic_type do
						primary_key :id
						column :name, String
						column :data_regexp, String
						column :generalize, String
				#		column :generalize, GenericType
						column :rails_type, String
						column :ruby_conversion, String
					end # create_table
				end # change
			end # migration
			migration.apply gateway.connection, :up
		end # gateway
		container = ROM::container(:sql, 'sqlite:memory') do |conf|
			conf.default.create_table(:generic_types) do
				primary_key :id
				column :name, String
				column :data_regexp, String
				column :generalize, String
		#		column :generalize, GenericType
				column :rails_type, String
				column :ruby_conversion, String
			end # create_table
		end # container
#			assert_equal(nil, GenericTypeRepo::Generic_type_repo.name)
		first_generic_type = GenericTypeRepo::Generic_type_repo.create(name: 'name')
		assert_equal('name', first_generic_type.name)
		assert_equal(first_generic_type.to_hash, GenericTypeRepo::Generic_type_repo.by_id(first_generic_type.id))
	end # rom_sql
		
	def test_GenericTypes
	end # GenericTypes

	def test_GenericCoercions
	end # GenericCoercions

	def test_GenericDBTypes
	end # GenericDBTypes
		
	def test_DefinitionalConstants

#			assert(false, GenericTypeRepo::Container.inspect)
  end # DefinitionalConstants
	
	def test_by_id
	end # by_id
	
	def test_by_name
	end # by_name

  def test_GenericTypeRepo_assert_pre_conditions
		GenericTypeRepo.assert_pre_conditions
  end # assert_pre_conditions

  def test_GenericTypeRepo_assert_post_conditions
		GenericTypeRepo.assert_post_conditions
  end # assert_post_conditions
	
  def test_assert_pre_conditions
		GenericTypeRepo.assert_pre_conditions
  end # assert_pre_conditions

  def test__assert_post_conditions
		GenericTypeRepo.assert_post_conditions
  end # assert_post_conditions

	def test_assert_no_generalize_cycle(previous_generalizations = [])
		assert_equal(GenericType::Most_general.generalize.to_sym, GenericType::Most_general.name)
		assert_equal([], GenericType::Most_general.assert_no_generalize_cycle)
		assert(GenericType.all.any? {|g| g.assert_no_generalize_cycle.empty?})
		refute(GenericType.all.all? {|g| g.assert_no_generalize_cycle.empty?})
		assert_instance_of(GenericType, Digit)
		assert_equal(false, Digit.most_general?)
		assert_equal([], Text.assert_no_generalize_cycle)
		assert_equal([Text], VARCHAR_Column.assert_no_generalize_cycle)
		assert_equal([VARCHAR_Column, Text], Integer.assert_no_generalize_cycle)
#		assert_equal([Text, VARCHAR_Column], Integer.assert_no_generalize_cycle([Text, VARCHAR_Column]))
#    assert_equal(%w(Text_Column VARCHAR_Column ascii print graph word alnum xdigit), digit_generic_type.assert_no_generalize_cycle.map(&:name))
    assert_includes(GenericType.find_by_name('Integer_Column').assert_no_generalize_cycle.map(&:name), :VARCHAR_Column)
    assert_includes(GenericType.find_by_name('Integer_Column').assert_no_generalize_cycle.map(&:name), :Text_Column)
		
		refute_empty(Word.assert_no_generalize_cycle)
		refute_empty(Graph.assert_no_generalize_cycle)
		refute_empty(Print.assert_no_generalize_cycle)
		refute_empty(Ascii.assert_no_generalize_cycle)
		GenericType.all.each do |t|
			assert_instance_of(GenericType, t)
#			assert_instance_of(Array, t.assert_no_generalize_cycle)
#     unless t.assert_no_generalize_cycle.empty?
#        assert_instance_of(GenericType, t.assert_no_generalize_cycle[0])
#      end # if
    end # each
#    assert_equal_sets(%w(VARCHAR_Column Text_Column), GenericType.find_by_name('Integer_Column').assert_no_generalize_cycle.map(&:name))
		refute_empty(Word.assert_no_generalize_cycle)
		refute_empty(Graph.assert_no_generalize_cycle)
		refute_empty(Print.assert_no_generalize_cycle)
		refute_empty(Ascii.assert_no_generalize_cycle)
	end # assert_no_generalize_cycle
end # GenericTypeRepo
