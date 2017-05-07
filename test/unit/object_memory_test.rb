require_relative 'test_environment'
require_relative '../../app/models/method_model.rb'
class ObjectMemoryTest < TestCase
  def test_method_query
    owner = ActiveRecord::ConnectionAdapters::ColumnDefinition
    m = :to_sql
    objects = 0
    ObjectSpace.each_object(owner) do |object|
      objects += 1
      begin
        theMethod = object.method(m.to_sym)
      rescue StandardError => exc
        puts "exc=#{exc}, object=#{object.inspect}"
      end # begin
      refute_nil(theMethod)
      assert_instance_of(Method, theMethod)
    end # each_object
    assert_operator(objects, :>, 0)
    method = ObjectMemory.method_query(m, owner)
    #	assert_equal(, )
    refute_nil(method)
    assert_instance_of(Method, method)
  end # method_query

  def test_all_methods
    assert_kind_of(Enumerator, ObjectSpace.each_object(Method))
    ret = []
    method_objects =	ObjectSpace.each_object(Method) do |m|
      ret << m
      assert_instance_of(Method, m)
      assert_respond_to(m, :name)
      #		assert_equal(m.name,m.inspect)	# varies
      refute_nil(m.name, m.inspect) # anonomous classes
      assert_instance_of(Symbol, m.name, ret.inspect)
    end # each_object
    assert_instance_of(Array, ret)
    assert_instance_of(Array, ObjectMemory.all_methods)
    assert_equal(ret, ObjectMemory.all_methods, ret.inspect)
    assert_instance_of(Array, ObjectMemory.all_methods)
    assert_operator(ObjectMemory.all_methods.size, :>=, 69, ObjectMemory.all_methods.uniq.inspect)
  end # methods

  def test_classes
    assert_equal('Enumerator', ObjectSpace.each_object(Module).class.name)
    assert_kind_of(Enumerator, ObjectSpace.each_object(Module))
    ret = []
    ObjectSpace.each_object(Class) do |c|
      ret << c
      assert_instance_of(Class, c)
      assert_respond_to(c, :name)
      #		refute_equal(c.name, c.inspect)	# varies
      #		refute_nil(c.name, c.inspect) # anonomous classes
      #		assert_instance_of(String, c.name, ret.inspect)
    end # each_object
    refute_nil(ret)
    refute_empty(ret)
    assert_instance_of(String, ret[0].inspect)
    comparison = ret[0].inspect <=> ret[1].inspect
    refute_nil(comparison)
    #	puts ret.map{|c| c.inspect}.sort # debug
    ret = ret.sort { |x, y| x.inspect <=> y.inspect }
    assert_instance_of(Array, ObjectMemory.classes)
    ObjectMemory.classes.each do |m|
      assert_instance_of(Class, m)
    end # each
    refute_equal('', ObjectMemory.classes[0])
    assert_equal(ObjectMemory.classes.size, ObjectMemory.classes.uniq.size)
    #	puts ObjectMemory.classes.inspect
    #	assert_empty(ObjectMemory.classes.map { |c| c.name}.sort-ObjectMemory.classes.map { |c| c.name}.sort.uniq)
    classNames = ObjectMemory.classes.map(&:inspect)
    uniqClasses = classNames.sort.uniq
    duplicates = 0 # found so far
    classNames.each_index do |i|
      if classNames[i].nil?
        puts "class name[#{i}] is nil, class=#{ObjectMemory.classes[i].inspect}"
      end # if
      if classNames[i].empty?
        puts "class name[#{i}] is empty, class=#{ObjectMemory.classes[i].inspect}"
      end # if
      if classNames[i + duplicates] != uniqClasses[i]
        puts "Duplicate class name[#{i}] = #{classNames[i + duplicates]}"
        duplicates += 1
      end # if
    end # each
    assert_includes(ObjectMemory.classes, String)
    #	assert_includes(ObjectMemory.classes, ActiveRecord::Base) # ActiveRecord dependancy avoided
  end # classes

  def test_modules
    #	assert_kind_of(Enumerator,ObjectSpace.each_object(Module))
    assert_instance_of(Array, ObjectMemory.modules)
    ObjectMemory.modules.each do |m|
      unless m.is_a?(Module)
        if ObjectMemory.classes.include?(m)
          puts "#{m} should be Module but is #{m.class}, included in classes."
        else
          puts "#{m} should be Module but is #{m.class}"
        end # if
      end # if
      assert_kind_of(Module, m)
    end # each
    ObjectMemory.modules.any? { |m| m.instance_of?(Module) }
    refute_equal('', ObjectMemory.modules[0])
    assert_equal(ObjectMemory.modules.size, ObjectMemory.modules.uniq.size)
    assert_empty(BasicObject.included_modules)
    refute_empty(Object.included_modules)
    refute_empty(ObjectMemory::Examples::EmptyClass.included_modules)
    assert_equal([BasicObject], BasicObject.ancestors)
    refute_empty(ObjectMemory::Examples::EmptyClass.ancestors)
    refute_includes(ObjectMemory.modules, ObjectMemory::Examples::EmptyClass)
    assert_includes(ObjectMemory.modules, ObjectMemory::ClassMethods)
  end # modules

  def test_classes_and_modules
    assert_operator(ObjectMemory.classes.size, :>, ObjectMemory.modules.size)
    assert_empty((ObjectMemory.modules - ObjectMemory.classes) & ObjectMemory.classes)
    refute_empty(ObjectMemory.classes_and_modules)
    refute_empty(ObjectMemory.classes_and_modules.find_all { |i| i.to_s == 'ActiveRecord::ConnectionAdapters::ColumnDefinition' })
    #	assert_equal([],ObjectMemory.classes_and_modules.find_all{|i| i.to_s=='ActiveRecord::ConnectionAdapters::ColumnDefinition'})
  end # classes_and_modules

  def test_all_instance_methods
    assert(ObjectMemory.classes.all? { |mr| mr.instance_of?(Class) })
    assert(ObjectMemory.modules.all? { |mr| mr.instance_of?(Module) })
    assert(ObjectMemory.all_instance_methods.any? { |mr| mr.instance_of?(ObjectMemory) })
    ObjectMemory.all_instance_methods.each do |mr|
      assert_instance_of(ObjectMemory, mr)
    end # each
  end # all_instance_methods

  def test_all_class_methods
    assert(ObjectMemory.classes.all? { |mr| mr.instance_of?(Class) })
    assert(ObjectMemory.modules.all? { |mr| mr.instance_of?(Module) })
    #	assert(ObjectMemory.classes.map { |c| c.methods(false).map { |m| new(m,c,:class) } }
    assert(ObjectMemory.all_class_methods.any? { |mr| mr.instance_of?(ObjectMemory) })
    ObjectMemory.all_class_methods.each do |mr|
      assert_instance_of(MethodModel, mr)
    end # each
  end # all_class_methods

  def test_all_singleton_methods
    assert(ObjectMemory.classes.all? { |mr| mr.instance_of?(Class) })
    assert(ObjectMemory.modules.all? { |mr| mr.instance_of?(Module) })
    assert(ObjectMemory.all_singleton_methods.any? { |mr| mr.instance_of?(ObjectMemory) })
    ObjectMemory.all_singleton_methods.each do |mr|
      assert_instance_of(ObjectMemory, mr)
    end # each
  end # all_singleton_methods

  def test_all
    all_records = ObjectMemory.all
    assert_instance_of(Array, all_records)
    assert_operator(69, :<=, all_records.size)
    all_records.each do |mr|
      assert_instance_of(ObjectMemory, mr)
      assert_includes(mr[:scope], [Class, Module, :instance, :class, :singleton])
    end # each
    assert(all_records.all? { |mr| mr[:name] })
    assert(all_records.all? { |mr| mr[:scope] })
    assert(all_records.many? { |mr| mr[:owner] })
    assert(all_records.all? { |mr| mr.key?(:singleton) })
    assert(all_records.all? { |mr| mr.key?(:protected) })
    assert(all_records.all? { |mr| mr.key?(:private) })
    assert(all_records.any? { |mr| mr[:method] })
    # ?	assert(all_records.any? {|mr| mr[:singleton]})
    # ?	assert(all_records.any? {|mr| mr[:protected]})
    # ?	assert(all_records.any? {|mr| mr[:private]})
    assert(all_records.any? { |mr| mr[:arity] })
    assert(all_records.any? { |mr| mr.key?(:instance_variable_defined) })
    # ?	assert(!all_records.any? {|mr| mr.has_key?(:exception)})
    assert(!all_records.any? { |mr| mr[:instance_variable_defined] })
    assert(!all_records.any? { |mr| mr[:source_location] })
    assert(!all_records.any? { |mr| mr[:parameters] })
    puts all_records.map(&:keys).uniq.inspect
    # why?	assert_equal(Set.new([4,6,10]),Set.new(all_records.map { |m| m.keys.size}.uniq))
    refute_empty(Set.new(all_records.map(&:keys).uniq))
  end # all

  def test_first
    all_records = ObjectMemory.all
    assert_instance_of(ObjectMemory, all_records[0])
    assert_equal(all_records.first, all_records[0])
    refute_nil(ObjectMemory.first)
    refute_nil(all_records[0])
    assert_equal(ObjectMemory.first, all_records[0])
    assert_instance_of(ObjectMemory, ObjectMemory.first)
    assert_instance_of(String, ObjectMemory.first[:owner].name)
  end # first

  def test_find_by_name
    to_sqls = ObjectMemory.all.select { |m| m[:name].to_sym == :to_sql }
    assert_equal(to_sqls, ObjectMemory.find_by_name(:to_sql))
    assert_equal(to_sqls, ObjectMemory.all.find_all { |i| i[:name].to_sym == :to_sql })
    assert_operator(0, :<, ObjectMemory.find_by_name(:to_sql).size)
    ObjectMemory.find_by_name(:to_sql).each do |mr|
      assert_equal(mr[:name], :to_sql)
      assert_equal(mr[:scope], :instance)
      #		assert_equal(mr[:protected], false)
      assert_equal(mr[:instance_variable_defined], false)
      # ?		assert_equal(mr[:private], false)
      # ?		assert_equal(mr[:singleton], false)
      # ?		refute_nil(mr[:owner])
      puts "#{mr[:owner]}:#{mr[:owner].object_id}"
    end # each
    to_sql_owners = to_sqls.map { |t| t[:owner] }
    # ?	assert_equal(to_sql_owners.uniq,to_sql_owners,"No duplicates, please.")
  end # find_by_name

  def test_owners_of
    method_name = :to_sql
    refute_empty(ObjectMemory.owners_of(method_name), "find_by_name(:#{method_name})=#{ObjectMemory.find_by_name(method_name)}")
  end # owners_of

  def test_constantized
    assert_equal(['Symbol'], Module.constants.map(&:objectKind).uniq)
    assert_includes('String', ObjectMemory.constantized.map(&:objectKind).uniq)
    assert_operator(1000, :>, Module.constants.size)
    assert_operator(ObjectMemory.constantized.size, :<, ObjectMemory.classes_and_modules.size)
    assert_operator(100, :<, ObjectMemory.constantized.size)
    #	puts "Module.constants=#{Module.constants.inspect}"
    method_list = Module.constants.map do |c|
      if c.objectKind == :class || c.objectKind == :module
        new(c)
      end # if
    end # map
    assert_operator(method_list.size, :<, 1000)
    assert_operator(100, :<, method_list.size)
    assert_includes('Class', ObjectMemory.constantized.map(&:objectKind).uniq)
    puts 'pretty print'
    # ~ pp ObjectMemory.all
    # ~ refute_nil(new('object_id',Object,:methods))
  end # constantized

  def test_ExclusionValidator
    ObjectSpace.each_object(Class) do |c|
      if c.name =~ /ExclusionValidator/
        p c.inspect
      end # if
    end # each_object
    # ~ puts "ExclusionValidator.inspect=#{ExclusionValidator.inspect}"
    # ~ puts " 'ExclusionValidator'.constantized.inspect=#{'ExclusionValidator'.constantized.inspect}"
  end # ExclusionValidator

  def test_matching_methods
    testClass = Unit
    assert_instance_of(Array, testClass.matching_class_methods(//))
    assert_instance_of(Array, testClass.matching_instance_methods(//))
  end # test

  def test_Generic_Table
    assert(Generic_Table.module?)
    assert(!FilePattern.module?)
    assert_includes('Generic_Table', FilePattern.ancestors.map(&:name))
    assert_equal([Generic_Table], Account.noninherited_modules)
    assert_equal([Generic_Table], FilePattern.noninherited_modules)
    assert(FilePattern.ancestors.map(&:name).include?('Generic_Table'), "Module not included in #{canonicalName} context.")
    assert(RubyAssertions.ancestors.map(&:name).include?('Generic_Table'), "Module not included in #{canonicalName} context.")
    testClass = Unit
    assert_equal([Generic_Table], testClass.ancestors - [testClass] - testClass.superclass.ancestors)
    assert_includes(Generic_Table, RubyAssertions.ancestors - [RubyAssertions])
    assert_equal([Generic_Table], RubyAssertions.ancestors - [RubyAssertions, RubyInterface] - RubyAssertions.superclass.superclass.ancestors)
    assert_equal([], RubyAssertions.noninherited_modules) # stI at work
  end # test

  def test_matching_methods_in_context
    testClass = Unit
    # error message too long	assert_instance_of(Array,testClass.matching_methods_in_context(//,2))
    # error message too long		assert_equal([testClass.canonicalName,testClass.matching_methods(//)],testClass.matching_methods_in_context(//)[0])
    # error message too long			assert_instance_of(Array,testClass.matching_methods_in_context(//,2))
  end # def

  def test_Acquisition_Stream_Spec_modules
    assert(Generic_Table.module?)
    assert(!FilePattern.module?)
    assert_equal([Generic_Table], FilePattern.noninherited_modules)
    assert(FilePattern.ancestors.map(&:name).include?('Generic_Table'), "Module not included in #{canonicalName} context.")
    assert_includes('Generic_Table', FilePattern.ancestors.map(&:name))
    assert(FilePattern.module_included?(:Generic_Table), "Module not included in #{canonicalName} context.")
    assert_module_included(FilePattern, :Generic_Table)
  end # test

  def test_Acquisition_Interface_modules
    assert(Generic_Table.module?)
    assert(RubyAssertions.ancestors.map(&:name).include?('Generic_Table'), "Module not included in #{canonicalName} context.")
    assert_equal([], RubyAssertions.noninherited_modules) # because of STI Generic_Table is not directly included
    assert_includes('Generic_Table', RubyAssertions.ancestors.map(&:name))
    assert(RubyAssertions.module_included?(:Generic_Table), "Module not included in #{canonicalName} context.")
    assert_module_included(RubyAssertions, :Generic_Table)
  end # test

  def test_attribute_ddl
    assert(@@default_connection.table_exists?(:stream_patterns))
    assert_equal([], ActiveRecord::ConnectionAdapters::ColumnDefinition.methods(false))
    assert_equal([], ObjectMemory.all.select { |m| m.owner == '' })
    assert_equal('integer', @@default_connection.type_to_sql(:integer))
    # private	assert_equal('',@@default_connection.default_primary_key_type)
    # 2 arguments	assert_equal([],@@default_connection.index_name)
    # too long	assert_equal([],@@default_connection.methods)
    assert_instance_of(ObjectMemory, ObjectMemory.all.first)
    assert_instance_of(ObjectMemory, ObjectMemory.first)
    assert_instance_of(Array, ObjectMemory.first.keys)
    assert_instance_of(Class, ObjectMemory.first[:owner])
    assert_equal([{ scope: :class, owner: ActiveRecord::ConnectionAdapters::ColumnDefinition },
                  { scope: :class, owner: ActiveRecord::ConnectionAdapters::TableDefinition },
                  { scope: :class, owner: ActiveRecord::Relation },
                  { scope: :class, owner: Arel::Nodes::Node },
                  { scope: :class, owner: Arel::TreeManager }], ObjectMemory.owners_of(:to_sql))
    table_sql = @@default_connection.to_sql
    refute_empty(table_sql)
    attribute_sql = table_sql.grep(attribute_name)
    refute_empty(attribute_sql)
  end # attribute_ddl

  def test_logical_attributes
    assert_equal(Set[{ name: 'float' },
                     { name: 'datetime' },
                     { name: 'decimal' },
                     'INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL',
                     { name: 'datetime' },
                     { name: 'blob' },
                     { name: 'boolean' },
                     { name: 'date' },
                     { name: 'time' },
                     { name: 'text' },
                     { name: 'integer' },
                     { name: 'varchar', limit: 255 }], Set.new(StreamPattern.connection.native_database_types.values))
    assert_equal(['name'], StreamPattern.logical_attributes)
  end # logical_attributes
end # ObjectMemory
