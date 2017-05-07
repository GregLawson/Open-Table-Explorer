require_relative 'test_environment'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class FrequencyTest < TestCase
  def setup
    define_model_of_test # allow generic tests
    assert_module_included(Unit::Executable.model_class?, Generic_Table)
    explain_assert_respond_to(Unit::Executable.model_class?, :sequential_id?, "#{@model_name}.rb probably does not include include Generic_Table statement.")
    assert_respond_to(Unit::Executable.model_class?, :sequential_id?, "#{@model_name}.rb probably does not include include Generic_Table statement.")
    define_association_names
  end # def

  def test_general_associations
    assert_general_associations(@table_name)
  end # test

  def test_id_equal
    if Unit::Executable.model_class?.sequential_id?
    else
      @my_fixtures.each_value do |ar_from_fixture|
        message = "Check that logical key (#{ar_from_fixture.logical_primary_key}) value (#{ar_from_fixture.logical_primary_key_value}) exactly matches yaml label for record."
        message += " identify != id. ar_from_fixture.inspect=#{ar_from_fixture.inspect} ar_from_fixture.logical_primary_key_value=#{ar_from_fixture.logical_primary_key_value}"
        assert_equal(Fixtures.identify(ar_from_fixture.logical_primary_key_value), ar_from_fixture.id, message)
      end
    end
  end # test

  def test_specific__stable_and_working
  end # test

  def test_aaa_test_new_assertions_ # aaa to output first
    assert_equal(Unit::Executable.model_class?.new.foreign_key_association_names - Unit::Executable.model_class?.new.Match_and_strip(/=$/).select { |a| Generic_Table.is_generic_table?(a) }, [])
    assert_matching_association(@table_name, 'table_specs')
  end # test
end # class
