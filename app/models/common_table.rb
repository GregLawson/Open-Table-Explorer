###########################################################################
#    Copyright (C) 2011-2013 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/global.rb'
require_relative '../../app/models/generic_table_html.rb' # in test_helper?
require_relative '../../app/models/generic_grep.rb' # in test_helper?
require_relative '../../app/models/column_group.rb'
require 'yaml'
require 'active_support/all'
# Methods in common bettween ActiveRecord::Base and NoDB
module Common
  # require 'app/models/IncludeModuleClassMethods.rb'
  module ClassMethods
    include GenericTableHtml::ClassMethods
    include GenericGrep::ClassMethods
    include ColumnGroup::ClassMethods
    def class_of_name(name)
      return name.to_s.constantize
    rescue
      return nil
    end # class_of_name

    def is_generic_table?(model_class_name)
      return false if model_class_name =~ /_ids$/
      if is_ActiveRecord_table?(model_class_name)
        model_class = eval_constant(model_class_name.classify)
        model_class.module_included?(Generic_Table)
      else
        return false
      end # if
    end # def

    def table_exists?(table_name)
      TableSpec.connection.table_exists?(table_name)
    end # table_exists

    def rails_MVC_class?(table_name)
      CodeBase.rails_MVC_classes.map(&:name).include?(table_name.to_s.classify)
    end # rails_MVC_class

    def is_generic_table_name?(model_file_basename, directory = 'app/models/', extention = '.rb')
      if File.exist?(directory + model_file_basename + extention)
        return true
      else
        #		puts "File.exists?(\"#{directory+model_file_basename+extention})\")=#{File.exists?(directory+model_file_basename+extention)}"
        return false
      end # if
    end # is_generic_table_name

    def activeRecordTableNotCreatedYet?(obj)
      (obj.class.inspect =~ /^[a-zA-Z0-9_]+\(Table doesn\'t exist\)/) == 0
    end # activeRecordTableNotCreatedYet
  end # ClassMethods
  include GenericTableHtml
  include GenericGrep
  include ColumnGroup
  def updates(variableHashes)
    #	Global::log.info("variableHashes.inspect=#{variableHashes.inspect}")
    variableHash = {} # merge into single hash
    variableHashes.each do |vhs|
      vhs.each do |vh|
        variableHash.merge(vh)
      end # each
    end # each
    #	Global::log.info("variableHash.inspect=#{variableHash.inspect}")
    if exists?(variableHash)
      @@log.debug('record already exists')
    else
      row = new
      #		Global::log.info( "variableHash['khhr_observation_time_rfc822']=#{variableHash['khhr_observation_time_rfc822']}")
      reportNull(variableHash)
      row.update_attributes(variableHash)
      now = Time.new
      if row.has_attribute?('created_at')
        row.update_attribute('created_at', now)
      end # if
      if row.has_attribute?('updated_at')
        row.update_attribute('updated_at', now)
      end # if
      # update_attribute("id","NULL")
    end # if else
    end # def

  def process(acquisitionData)
    acqClasses = Generic_Acquisitions.parse_classes(m)
    acqClasses.each map do |ac|
      variableHashes = ac.parse(acquisitionData)
    end # each
    row.updates(variableHashes)
    row.save
    row
  end

  def log
    begin
      acquire
      wait
    end until false
  end # method log

  def monitor(keys) # update continously
    #	Global::log.info("in monitor self.name=#{self.name}")
    whoAmI
    # generic_acquisitions
    begin
      acquisitionData = acquire
      if acquisitionsUpdated?(acquisitionData)
        row = find_or_initialize(keys)
        row.process(acquisitionData)
        row.printLog
      end

      wait
    end until false
  end # method monitor

  def acquire
    @acqClasses = Generic_Acquisitions.parse_classes(m)
    @acqClasses.map do |_ac|
      @acquisitionData = acquire
    end # map
    @acquisitionData.each do |ad|
      if acquisitionUpdated?(ad)
        row = create
        row = process(ad)
        row.printLog
      else
        puts ad
      end
    end
  end

  def updateMaxTypeNum(maxTypeNums)
    adaptiveAcquisition
    values = getValues
    values.each_index do |i|
      maxTypeNums[i] = [Import_Column.firstMatch(values[i]), maxTypeNums.fetch(i, -1)].max
    end
    maxTypeNums
  end # def

  def column_Definitions
    adaptiveAcquisition
    names = getNames
    #	Global::log.debug("names=#{names}")
    typeNums = [] # make it array, so array functons can be used
    numSamples = 0
    begin
      typeNums = updateMaxTypeNum(typeNums)
      numSamples += 1
    end until streamEnd || numSamples > 10
    @sqlTypes = []
    ret = []
    names.each_index do |i|
      @sqlTypes.push(Import_Column.row2ImportType(typeNums[i]))
      #		Global::log.info("#{names[i]} #{@sqlTypes[i]} \"#{@sqlValues[i]}\" #{typeNums[i]}")
      ret.push([names[i], @sqlTypes[i]])
      #		Global::log.info("ret=#{ret}")
    end
    #	Global::log.info("ret=#{ret}")
    ret
  end

  def adaptiveAcquisition
    notModifieds = 0
    done = false
    begin
      @acquisitionData = acquire
      if acquisitionsUpdated?
        done = true
      else
        notModifieds += 1
        if notModifieds.modulo(10) == 0
          #				Global::log.info("notModifieds=#{notModifieds}")
          #				Global::log.info("@acquisitionData=#{@acquisitionData}")
        end
      end
      # sleep self[:interval]
      wait
    end until done
    #	Global::log.info("notModifieds=#{notModifieds}")
    @acquisitionData
  end

  def find_or_initialize(findCriteria)
    records = find(:all, findCriteria)
    if records.empty?
      ret = new(findCriteria)
      return ret
    elsif records.size == 1
      return records[0]
    else
      @@log.debug("criteria not unque; records=#{records.inspect}")
      raise
    end
  end

  def display(exp)
    puts "#{exp}="
    puts eval(exp).to_s
    puts "#{exp}=#{eval(exp)}"
  end

  def Require_Table(tableName = to_s)
    #	Global::log.info("in Require_Table self.class=#{self.class}")
    #	Global::log.info("in Require_Table self.to_s=#{self.to_s}")
    #	Global::log.info("in Require_Table tableName=#{tableName}")
    if pg_table_exists?
    # return new
    else
      puts "Table #{tableName} does not exist. Enter following command in rails to create:"
      # puts Generic_Columns.scaffold(Generic_Columns.column_Definitions)
      puts scaffold(column_Definitions)
      #		puts scaffold(self.column_Definitions)
    end
  end

  def scaffold(columnDefs)
    #	Global::log.info("singularTableName=#{singularTableName}")
    #	Global::log.info("in scaffold singularTableName=#{singularTableName}")
    rails = "script/generate scaffold #{singularTableName} "
    columnDefs.each do |col|
      rails = "#{rails} #{col[0]}:#{col[1]}"
      # puts rails
    end
    rails
  end

  def singularTableName
    #	Global::log.info("in singularTableName self.class=#{self.class}")
    #	Global::log.info("in singularTableName self.to_s=#{self.to_s}")
    to_s.chop
  end

  def addColumn(name, type)
    sql = "ALTER TABLE  #{@table_name} ADD COLUMN #{name.downcase} #{type};"
    errorMessage = DB.execute(sql)
    errorMessage
  end

  def requireColumn(name, type)
    #	Global::log.info("self.class=#{self.class}")
    #	Global::log.info("name=#{name}")
    if has_attribute?(name)
      return ''
    else
      puts "Column #{name} to be created with #{type}" if $VERBOSE
      return addColumn(name, type)
    end
  end

  def pg_table_exists?(tableName = to_s.downcase)
    sql = "select table_name from information_schema.tables where table_schema='public' AND table_name='#{tableName}';"
    #	Global::log.debug("sql=#{sql}")
    res = find_by_sql(sql)
    #	Global::log.info("res.size=#{res.size}")
    # puts "res=#{res}"
    !res.empty?
  end

  def addPrefix(variableHash, prefix)
    ret = {}
    variableHash.each_pair do |key, value|
      ret["#{prefix}#{key}"] = value
    end
    ret
  end

  def exclude(variableHash, exclusionList = [])
    ret = {}
    variableHash.each_pair do |key, value|
      ret[key] = value unless exclusionList.include?(key)
    end
  end

  def initFail
    puts 'Table does not exist. Enter following command in rails to create:'
    puts self.class.scaffold
    exit
  end

  def rubyClassName(model_class_name)
    model_class_name = model_class_name[0, 1].upcase + model_class_name[1, model_class_name.length - 1] # ruby class names are constants and must start with a capital letter.
    # remainng case is unchanged to allow camel casing to separate words for model names.
    model_class_name
  end # def

  def classDefiniton(model_class_name)
    "class #{rubyClassName(model_class_name)}  < ActiveRecord::Base\ninclude Generic_Table\nend"
  end # def

  def classReference(model_class_name)
    rubyClassName = rubyClassName(model_class_name)
    model_class_eval = eval("#{classDefiniton(rubyClassName)}\n#{rubyClassName}")
    model_class_eval
  end # def

  def table2yaml(table_name = self.class.name.tableize)
    i = 0 # "000"
    limit = 100 # too long slow all tests, too short give poor test coverage
    sql = "SELECT * FROM %s LIMIT #{limit}"
    File.open("test/fixtures/#{table_name}.yml.gen", 'w') do |file|
      data = self.class.limit(limit).all
      #		puts "data.inspect=#{data.inspect}"
      file.write '# Read about fixtures at http://ar.rubyonrails.org/classes/Fixtures.html'
      file.write data.inject({}) { |hash, model_instance|
                   i += 1
                   fixture_attributes = model_instance.attributes
                   fixture_attributes.delete('created_at')  # automatically regenerated
                   fixture_attributes.delete('updated_at')  # automatically regenerated
                   if sequential_id?
                     primaryKeyValue = i
                     fixture_attributes['id'] = i # automatically regenerated
                   else
                     primaryKeyValue = model_instance.logical_primary_key_value
                     fixture_attributes.delete('id') # automatically regenerated
                   end
                   #			puts "fixture_attributes.inspect=#{fixture_attributes.inspect}"
                   #			puts "fixture_attributes.to_yaml.inspect=#{fixture_attributes.to_yaml.inspect}"
                   hash[primaryKeyValue] = fixture_attributes
                   hash
                 }.to_yaml
    end # file open
  end # def

  def self.db2yaml
    skip_tables = %w(schema_info tedprimaries weathers)
    (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
      table2yaml(table_name)
    end # each
  end # def

  # Display attribute or method value from association even if association is nil
  def association_state(association_name)
    case self.class.association_arity(association_name)
    when :to_one
      foreign_key_value = foreign_key_value(association_name)
      if foreign_key_value.nil? # foreign key uninitialized
        return "Foreign key #{association_name}_id defined as attribute but has nil value."
        # ~ elsif foreign_key_value.empty? then # foreign key uninitialized
        # ~ return "Foreign key #{association_name.to_s}_id defined as attribute but has empty value."
      else
        ass = send(association_name)
        if ass.nil?
          return "Foreign key #{association_name}_id has value #{foreign_key_value.inspect} but the association returns nil."
        else
          return "Foreign key #{association_name}_id has value #{foreign_key_value.inspect},#{ass.inspect} and returns type #{ass.class.name}."
        end
      end
    when :to_many
      ass = send(association_name)
      associations_foreign_key_name = (self.class.name.tableize.singularize + '_id').to_sym
      if ass.nil?
        return "Association #{association_name}'s foreign key #{associations_foreign_key_name} has value #{ass[self.class.name.to_s + '_id']} but the association returns nil."
      elsif ass.empty?
        ret = "Association #{association_name} with foreign key #{associations_foreign_key_name} is empty; "
        case self.class.association_class(association_name).association_macro_type(self.class.name.tableize.singularize)
        when :has_many
          return ret + 'but has many.'
        when :belongs_to
          return ret + 'but belongs_to.'
        when :neither_has_many_nor_belongs_to
          return ret + 'because neither_has_many_nor_belongs_to.'
        else
          return "New return value from #{self.class.name}.association_macro_type(#{association_name})=#{self.class.association_macro_type(association_name)}."
        end # case
      else
        associations_foreign_key_values = ass.map { |a| a.send(associations_foreign_key_name) }.uniq.join(',')
        return "Association #{association_name}'s foreign key #{associations_foreign_key_name} has value #{associations_foreign_key_values},#{ass.inspect} and returns type #{ass.class.name}."
      end

    when :not_generic_table
      return "#{self.class.name} does not recognize #{association_name} as a generic table."
    when :not_an_association
      return "#{self.class.name} does not recognize #{association_name} as association."
    else
      return "New return value from #{self.class.name}.association_arity(#{association_name})=#{self.class.association_arity(association_name)}."
    end # if
  end # def

  def Match_and_strip(regexp = /=$/)
    matching_methods(regexp).map do |m|
      m.sub(regexp, '')
    end
  end # def

  def eval_constant(constant_name)
    constant_name.constantize
  rescue NameError
    return nil
  end # def

  def is_table?(table_name)
    raise 'table_name must include only [A-Za-z0-9_].' if (table_name =~ /^[A-Za-z0-9_]+$/).nil?
    if table_exists?(table_name)
      return true
    # ~ elsif table_exists?(table_name.tableize) then
    # ~ return true
    else
      return false
    end # if
  end # def

  def is_ActiveRecord_table?(model_class_name)
    if is_table?(model_class_name.tableize)
      model_class = eval_constant(model_class_name.classify)
      model_class.new.is_a?(ActiveRecord::Base)
    else
      return false
    end # if
  end # def

  def display_full_time(time)
    time.rfc2822
  end # def
end # CommonTable
