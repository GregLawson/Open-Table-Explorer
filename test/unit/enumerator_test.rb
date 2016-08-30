###########################################################################
#    Copyright (C) 2014-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/stream_tree.rb'
class EnumeratorTest < TestCase
  # include DefaultTests
  # include RailsishRubyUnit::Executable.model_class?::Examples
	module Array
		module Examples
			Trivial_array = [0].freeze
			Flat_array = [0].freeze
			Example_array = [1, 2, 3].freeze
			Nested_array = [1, [2, [3], 4], 5].freeze
			Inspect_node_root = '[1, [2, [3], 4], 5]'.freeze
		end # Examples
	end # Array
	include Array::Examples
	include Hash::Examples
  def test_values
    assert_equal(Example_array, Example_array.values)
  end # values

  def test_keys
    assert_equal([0, 1, 2], Array::Examples::Example_array.keys)
  end # keys

  def test_to_hash
    assert_equal(Array::Examples::Example_array, Array::Examples::Example_array.to_hash.to_a.values)
    assert_instance_of(Hash, Array::Examples::Example_array.to_hash)
#    assert_equal(Array::Examples::Example_array, Array::Examples::Example_array.to_hash.to_a.values)
  end # to_hash

  def test_to_hash_from_to_a
  end # to_hash_from_to_a

  def test_map_pair
  end # map_pair
	
  def test_each_with_index
  end # each_with_index

  def test_map_pair_Hash
    tree = Flat_hash
    idenity_map = tree.class::Constants::Identity_map_pair
    assert_equal(tree, tree.map_pair(&idenity_map))
  end # map_pair

  def test_hash_minus
    assert_equal({}, {} - {})
    assert_equal({}, { cat: 1 } - { cat: 1 })
    assert_equal({ cat: 1 }, { cat: 1 } - { dog: 1 })
    assert_equal({ cat: 1 }, { cat: 1 } - { cat: 2 })
    assert_equal({ cat: 1 }, { cat: 1, dog: 3 } - { cat: 2, dog: 3 })
    assert_equal({ cat: 1, dog: { fish: 5 } }, { cat: 1, dog: { fish: 5, bird: 6 } } - { cat: 2, dog:  { bird: 6 } })
  end # -

  def test_operator
    assert_equal({}, {}.operator({}))
    assert_equal({ lhs_key: :lhs_value }, { lhs_key: :lhs_value }.operator(rhs_key: :rhs_value) { |key, lhs, _rhs| lhs[key] })
    assert_equal({ common_key: :lhs_value }, { common_key: :lhs_value }.operator(common_key: :rhs_value) { |key, lhs, _rhs| lhs[key] })
    assert_equal({ common_key: :rhs_value }, { common_key: :lhs_value }.operator(common_key: :rhs_value) { |key, _lhs, rhs| rhs[key] })
    assert_equal({}, { lhs_key: :lhs_value }.operator(rhs_key: :rhs_value) { |key, _lhs, rhs| rhs[key] })

    operator_lambda = lambda do |key, lhs, rhs|
      assert_instance_of(Symbol, key)
      assert_instance_of(Hash, lhs)
      assert_instance_of(Hash, rhs)
      refute_nil(lhs[key])
      if rhs[key].nil? || lhs[key] != rhs[key]
        lhs[key]
      end # if
    end # lambda
    assert_equal({}, {}.operator({}, &operator_lambda))

    assert_equal({ cat: 1 }, { cat: 1 }.operator({ dog: 1 }, &operator_lambda))
    assert_equal({ cat: 1 }, { cat: 1 }.operator({ cat: 2 }, &operator_lambda))
    assert_equal({ cat: 1 }, { cat: 1, dog: 3 }.operator({ cat: 2, dog: 3 }, &operator_lambda))
    assert_equal({ fish: 5 }, { fish: 5, bird: 6 }.operator({ bird: 6 }, &operator_lambda))
#    assert_equal({ cat: 1, dog: { fish: 5 } }, { cat: 1, dog: { fish: 5, bird: 6 } }.operator({ cat: 2, dog:  { bird: 6 } }, &operator_lambda))
    assert_equal({ cat: 1 }, { cat: 1 }.operator({ dog: 2 }, &operator_lambda))
    assert_equal({ cat: 1 }, { cat: 1 }.operator({ dog: 1 }, &operator_lambda))

    assert_equal({ cat: 1 }, { cat: 1 }.operator(dog: 2) { |key, lhs, _rhs| lhs[key] })
#    assert_equal({ cat: nil }, { cat: 1 }.operator(dog: 1) { |key, _lhs, rhs| rhs[key] })
#    assert_equal({ cat: 1 }, { cat: 1 }.operator(dog: 1) { |key, lhs, rhs| lhs[key] - rhs[key] })
#    assert_equal({ cat: 1 }, { cat: 1 }.operator(cat: 2) { |key, lhs, rhs| lhs[key] - rhs[key] })
#    assert_equal({ cat: 1 }, { cat: 1, dog: 3 }.operator(cat: 2, dog: 3) { |key, lhs, rhs| lhs[key] - rhs[key] })
#    assert_equal({ cat: 1, dog: { fish: 5 } }, { cat: 1, dog: { fish: 5, bird: 6 } }.operator(cat: 2, dog:  { bird: 6 }) { |key, lhs, rhs| lhs[key] - rhs[key] })
#    assert_equal({ cat: 0 }, { cat: 1 }.operator({ cat: 1 }, &operator_lambda))
  end # operator

  def test_intersection
    assert_equal({}, {} & {})
    assert_equal({ cat: 1 }, { cat: 1 } & { cat: 1 })
#    assert_equal({}, { cat: 1 } & { dog: 1 })
#    assert_equal({ cat: 1 }, { cat: 1 } & { cat: 2 })
#    assert_equal({ dog: { bird: 6 } }, { cat: 1, dog: { fish: 5, bird: 6 } } & { cat: 2, dog:  { bird: 6 } })
  end # intersection


	def inspect_lines
	end # inspect_lines

  def test_enumerate_single
    atom = /5/
    single = atom.enumerate_single(:map) { |e| e }
    refute_nil(single)
    assert_equal(5, 5.enumerate_single(:map) { |e| e })
    assert_equal(5, 5.enumerate_single(:select) { |e| e == 5 })
    assert_equal(nil, 5.enumerate_single(:select) { |e| e == 6 })
    assert_equal(false, 5.enumerate_single(:all?) { |e| e == 6 })
    assert_equal(true, 5.enumerate_single(:all?) { |e| e == 5 })
  end # enumerate_single

  def test_enumerate
    atom = [/5/]
    single = atom.enumerate(:map) { |e| e }
    refute_nil(single)
    assert_equal([5], [5].enumerate(:map) { |e| e })
    assert_equal([5], [5].enumerate(:select) { |e| e == 5 })
    assert_equal([], [5].enumerate(:select) { |e| e == 6 })
    assert_equal(false, [5].enumerate(:all?) { |e| e == 6 })
    assert_equal(true, [5].enumerate(:all?) { |e| e == 5 })
  end # enumerate
end # Stream
