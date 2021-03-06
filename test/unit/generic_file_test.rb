###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# require_relative '../unit/test_environment'
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/default_test_case.rb'
require_relative '../../app/models/generic_file.rb'
#require_relative '../../app/models/open_tax_form_filler.rb'
class GenericJsonsTest < TestCase
#  include DefaultTests
  include RailsishRubyUnit::Executable.model_class?::Examples
  def test_raw_acquisitions # acquisition=next
    all_files = Dir[OpenTaxFormFiller::Definitions::Input_filenames]
    all = all_files.map do |filename|
      acquisition = IO.read(filename)
      OpenTaxFormFiller::Definitions.assert_json_string(acquisition)
      acquisition
    end.flatten # map no arrays by filename
    raw_acquisitions = OpenTaxFormFiller::Definitions.raw_acquisitions
    assert_instance_of(Array, raw_acquisitions, raw_acquisitions.inspect)
    assert_equal(9, OpenTaxFormFiller::Definitions.raw_acquisitions.size, raw_acquisitions.inspect)
  end # raw_acquisitions

  def test_coarse_filter
    refute_empty(OpenTaxFormFiller::Definitions.coarse_filter.compact, OpenTaxFormFiller::Definitions.coarse_filter.inspect)
    assert_operator(867, :==, OpenTaxFormFiller::Definitions.coarse_filter.size, OpenTaxFormFiller::Definitions.coarse_filter.inspect)
    assert_equal([:form, :year, :line, :type], OpenTaxFormFiller::Definitions.coarse_filter[0].keys, OpenTaxFormFiller::Definitions.coarse_filter.inspect)
    types = OpenTaxFormFiller::Definitions.coarse_filter.map do |otff|
      otff[:type]
    end.uniq # map
    assert_equal(%w(Amount Choice Text Number Integer Percent), types)
  end # coarse_filter

  def test_coarse_rejections
    OpenTaxFormFiller::Definitions.coarse_rejections.each do |acquisition|
      puts acquisition if Type_regexp.match(acquisition)
      puts acquisition if Description_regexp.match(acquisition)
    end # select
    assert_operator(0, :==, OpenTaxFormFiller::Definitions.coarse_rejections.size, OpenTaxFormFiller::Definitions.coarse_rejections.inspect)
  end # coarse_rejections

  def test_all_initialize
    assert_operator(867, :==, OpenTaxFormFiller::Definitions.all.size, OpenTaxFormFiller::Definitions.fine_rejections.inspect)
    OpenTaxFormFiller::Definitions.all.each do |ots|
      assert_instance_of(OpenTaxFormFiller::Definitions, ots)
      assert_instance_of(Hash, ots.attributes)
      assert_respond_to(ots.attributes, :values)
      #		assert_scope_path(:DefaultAssertions, :ClassMethods)
      #		assert_constant_instance_respond_to(:NoDB, :insert_sql)
      assert_includes(ots.class.included_modules, NoDB)
      #		assert_includes(NoDB.methods, :insert_sql)
      assert_includes(OpenTaxFormFiller::Definitions.methods, :insert_sql)
      #		explain_assert_respond_to(OpenTaxFormFiller::Definitions, :insert_sql)
      assert_respond_to(OpenTaxFormFiller::Definitions, :insert_sql)
      assert_instance_of(Array, ots.attributes.values)
      #		ots.assert_pre_conditions
      values = ots.insert_sql
    end # each
  end # all_initialize

  def test_fine_rejections
    OpenTaxFormFiller::Definitions.fine_rejections.each do |r|
    end # each
  end # fine_rejections

  def test_assert_json_string
    OpenTaxFormFiller::Definitions.assert_json_string(OpenTaxFormFiller::Definitions::Simple_acquisition)
  end # assert_json_string
end # GenericJson
