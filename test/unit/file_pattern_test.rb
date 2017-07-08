###########################################################################
#    Copyright (C) 2012-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# require_relative 'test_environment' # avoid recursive requires
require_relative '../../app/models/test_environment_test_unit.rb'
# require_relative '../../app/models/default_test_case.rb'
# require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../app/models/file_pattern.rb'
class PatternTest < TestCase
		def test_new_from_prefix_suffix
			Pattern::Patterns.map do |hash|
				pattern = Pattern.new_from_prefix_suffix(hash)
				capture = MatchCapture.new(string: hash[:example_file], regexp: Regexp.new(pattern.path_regexp))
#!				capture.assert_refinement(:exact)
#!				assert_equal(capture.output.keys, hash.keys, capture.priority_refinements.inspect)
			end # map
		end # new_from_prefix_suffix
		
		def test_railsish_patterns
			assert_instance_of(Array, Pattern.railsish_patterns)
		end # railsish_patterns

	def test_parse
	end # parse
	
end # PatternTest

class FilePatternTest < TestCase
  include RubyAssertions
  # include DefaultTests2
  # include DefaultTests0    #less error messages
  include FilePattern::DefinitionalConstants
  include FilePattern::ReferenceObjects
  include FilePattern::Examples
  # include FilePattern::Assertions
  # include FilePattern::Assertions::KernelMethods
  extend FilePattern::Assertions::ClassMethods
  def test_DefinitionalConstants
    Executable.assert_pre_conditions
    Library.assert_pre_conditions
    refute_nil(Library, Library.inspect)
    refute_nil(Library.project_root_dir, Library.inspect)
    assert_match(Basename_character_regexp, Library.project_root_dir)
    assert_match(Directory_delimiter, Library.project_root_dir)
    assert_match(Basename_character_regexp, Library.project_root_dir)
    assert_match(Basename_regexp, Library.project_root_dir)
    assert_match(Pathname_character_regexp, Library.project_root_dir)
    # either	assert_match(Absolute_pathname_regexp, $0)
    assert_match(Relative_directory_regexp, Patterns[0][:prefix])
    assert_match(Absolute_directory_regexp, Library.project_root_dir)
    #	assert_match(Relative_pathname_regexp, )
    Patterns.each do |pattern|
      path = Pathname.new(pattern[:example_file])
      next if File.exist?(path)
      message = "\n\nIt is best for example files to actually exist. But "
      message += "\n" + pattern[:name].to_s + ' file ' + path.to_s + ' does not exist.'
      message += "\n" + pattern.inspect
      puts message
      # if
    end # each
  end # DefinitionalConstants

  def test_executing_path?
    squirrely_string = $PROGRAM_NAME
    class_name = self.class.name.to_s
    test_name = 'test_executing_path?'
    extra_at_end = ' ' + class_name + '#' + test_name
    extra_length = extra_at_end.length
    # NewTestClass	assert_equal(37, extra_length, extra_at_end.inspect)
    #	assert_equal(extra_at_end, squirrely_string[-extra_length..-1], squirrely_string)
    #	assert_pathname_exists(squirrely_string[0..-(extra_length+2)], squirrely_string)
    #	assert_pathname_exists(FilePattern.executing_path?, FilePattern.executing_path?)
  end # executing_path?

  def test_path2model_name
    path = 'test/slowest/rebuild_test.rb'
    #	FilePattern.new(Patterns[expected_match]).assert_naming_convention_match(path)
    assert_equal(:Rebuild, FilePattern.path2model_name?(path))
    assert_equal(:MatchData, FilePattern.path2model_name?('app/models/match_data.rb'))
  end # path2model_name

  def test_unit_base_name
    path = File.expand_path($PROGRAM_NAME)
	extension=File.extname(path)
	assert_equal('.rb', extension)
	basename=File.basename(path)
	assert_equal('file_pattern_test.rb', basename)
	expected_match=1
	assert_includes(FilePattern.included_modules, FilePattern::Assertions)
	assert_includes(FilePattern.methods, :assert_pre_conditions)
	assert_respond_to(FilePattern, :assert_pre_conditions)
	assert_equal(:minimal4, FilePattern.unit_base_name?(Path4))
#	FilePattern.assert_naming_convention_match(Patterns[expected_match], path)
	name_length=basename.size+extension.size-Patterns[expected_match][:suffix].size
	assert_equal(15, name_length, "basename.size=#{basename.size}, extension.size=#{extension.size}\n Patterns[expected_match]=#{Patterns[expected_match].inspect}\n Patterns[expected_match][:suffix].size=#{Patterns[expected_match][:suffix].size}, ")
	matched_pattern = FilePattern.find_all_from_path(path)
	matches=matched_pattern.reverse.map do |s| #reversed from rare to common
			name_length=basename.size-s[:suffix].size
			basename[0,name_length].classify.to_sym
	end #map
	refute_empty(matches)
	refute_empty(matches.compact)
	assert_equal(:FilePattern, matches.compact.last)
	
	path=File.expand_path(DCT_filename)
	extension=File.extname(path)
	basename=File.basename(path, extension)
	assert_equal('dct', basename)
	assert_equal('.rb', extension)
	expected_match=2
	name_length=basename.size+extension.size-Patterns[expected_match][:suffix].size
	assert_equal(3, name_length, "basename.size=#{basename.size}, extension.size=#{extension.size}\n Patterns[expected_match]=#{Patterns[expected_match].inspect}\n Patterns[expected_match][:suffix].size=#{Patterns[expected_match][:suffix].size}, ")
	expected_match=4
	path='test/slowest/rebuild_test.rb'
    assert_equal(:rebuild, FilePattern.unit_base_name?(path))
    assert_equal(:match_data, FilePattern.unit_base_name?('app/models/match_data.rb'))
  end # unit_base_name

  def test_repository_dir?
    path = $PROGRAM_NAME
    #	path='.gitignore'
    path = File.expand_path(path)
    assert_pathname_exists(path)
    dirname = if File.directory?(path)
                path
              else
                File.dirname(path)
              end # if
    assert_pathname_exists(dirname)
    begin
      git_directory = dirname + '/.git'
      #		assert_pathname_exists(git_directory)
      assert_operator(dirname.size, :>=, 2, dirname.inspect)
      if File.exist?(git_directory)
        done = true
      elsif dirname.size < 2
        dirname = nil
        done = true
      else
        assert_operator(dirname.size, :>, File.dirname(dirname).size)
        refute_equal(dirname, File.dirname(dirname))
        dirname = File.dirname(dirname)
        done = false
      end # if
      #		assert(done, 'first iteration.')
      puts 'path=' + path.inspect if $VERBOSE
      puts 'dirname=' + dirname.inspect if $VERBOSE
      puts 'git_directory=' + git_directory.inspect if $VERBOSE
      puts 'done=' + done.inspect if $VERBOSE
    end until done
    assert_pathname_exists(dirname)
    assert_pathname_exists(git_directory)
    assert_pathname_exists(FilePattern.repository_dir?('.gitignore'))
    refute_empty(FilePattern.project_root_dir?(File.expand_path($PROGRAM_NAME)))
    assert_equal(FilePattern.repository_dir?($PROGRAM_NAME), FilePattern.project_root_dir?(File.expand_path($PROGRAM_NAME)))
  end # repository_dir?

  def test_project_root_dir
    #	require 'optparse'
    assert(File.exist?($PROGRAM_NAME), $PROGRAM_NAME + ' does not exist.')
	path=File.expand_path($PROGRAM_NAME)
	refute_nil(path)
	refute_empty(path)
    assert(File.exist?(path), path + ' does not exist.')
	roots=FilePattern::Patterns.map do |p|
		path=File.expand_path(p[:example_file])
		matchData=Regexp.new(p[:prefix]).match(path)
		test_root=matchData.pre_match
		root=FilePattern.project_root_dir?(path)
		assert_equal(root, test_root)
		test_root
	end #map
	assert_equal(roots.uniq.size, 1, roots.inspect)
	refute_empty(FilePattern.project_root_dir?(path))
	assert_pathname_exists(FilePattern.project_root_dir?(path))
	path='.gitignore'
	path=File.expand_path(path)
	assert_pathname_exists(path)
	refute_empty(FilePattern.project_root_dir?(File.expand_path($PROGRAM_NAME)))
	refute_empty(FilePattern.project_root_dir?($0))
end #project_root_dir

  def test_find_by_name
    FilePattern::Patterns.each do |p|
      assert_equal(p, FilePattern.find_by_name(p[:name]), p.inspect)
    end # each
  end # find_by_name

  def test_match_path
    path = 'test/unit/_assertions_test.rb'
    p = FilePattern.find_from_path(path)

    successes = Patterns.map do |pattern|
      path = Pathname.new(pattern[:example_file])
      pattern_match = pattern.dup
      pattern_match[:path] = path
      prefix = File.dirname(path)
      expected_prefix = pattern[:prefix][0..-2] # drops trailing /
      match_length = expected_prefix.size
      message = 'pattern=' + pattern.inspect
      message += "\nexpected_prefix=" + expected_prefix
      message += "\nprefix=" + prefix
      assert_operator(match_length, :<=, prefix.size, message)
      refute_nil(prefix[-match_length, match_length], message)
      assert_match(pattern[:prefix], path.to_s, message)
      pattern_match[:prefix_match] = Regexp.new(pattern[:prefix]).match(path.to_s)
      refute_nil(pattern_match[:prefix_match], message)
      #		assert_equal(prefix[-match_length,match_length], expected_prefix, message)
      #		assert_equal(prefix[-expected_prefix.size,expected_prefix.size], expected_prefix, message)
      assert(FilePattern.match_path(pattern, path))
    end # map
  end # match_path

  def test_match_all?
    match_all = FilePattern.match_all?(Path4)
    assert_equal(Patterns.size, match_all.size, '')
  end # match_all

  def test_find_all_from_path
    find_all_from_path = FilePattern.find_all_from_path(Path4)
    assert_equal(2, find_all_from_path.size, find_all_from_path)
  end # find_all_from_path

  def test_find_from_path
    assert_equal(:model, FilePattern.find_from_path(SELF_Model)[:name], "Patterns[0], 'app/models/'")
    assert_equal(:unit, FilePattern.find_from_path(SELF_Test)[:name], "Patterns[2], 'test/unit/'")
    assert_equal(:script, FilePattern.find_from_path(DCT_filename)[:name], "Patterns[1], 'script/'")
    assert_equal(:assertions, FilePattern.find_from_path('test/assertions/_assertions.rb')[:name], "(Patterns[3], 'test/assertions/'")
    path = 'test/unit/_assertions_test.rb'

    path = 'test/data_sources/tax_form/CA_540/CA_540_2012_example_out.txt'
    pattern = FilePattern.find_from_path(path)
    refute_nil(pattern, path)
    assert_equal(:data_sources_dir, pattern[:name])
    match_all = FilePattern.match_all?(Path4)
    assert_equal(:assertions_test, FilePattern.find_from_path(Path4)[:name], FilePattern.find_from_path(Path4).inspect)
  end # find_from_path

  def test_path?
  end # path?

  def test_pathnames
    assert_instance_of(Array, FilePattern.pathnames?('test'))
    assert_equal(Patterns.size, FilePattern.pathnames?('test').size)
    #	assert_array_of(FilePattern.pathnames?('test'), String)
  end # pathnames

  def test_new_from_path
    n = FilePattern.new_from_path($PROGRAM_NAME)
    n.assert_pre_conditions
    #	assert_equal(Executable, n)
    file_pattern = n
    assert(!file_pattern.pattern.keys.empty?, "file_pattern=#{file_pattern.inspect}")
    n.assert_pre_conditions
    assert_equal(:file_pattern, FilePattern.new_from_path(__FILE__).unit_base_name)
  end # new_from_path

  def test_initialize
		
    file_pattern = FilePattern.new(pattern: Patterns[0],
		unit_base_name: :'*',
		project_root_dir: Library.project_root_dir,
		repository_dir: FilePattern.repository_dir?($PROGRAM_NAME))

    file_pattern.assert_pre_conditions
    assert_equal(:file_pattern, Library.unit_base_name)
    assert_equal(:file_pattern, Executable.unit_base_name)
    Executable.assert_post_conditions
    Library.assert_post_conditions
    Executable.assert_pre_conditions
    Library.assert_pre_conditions
  end # initialize
  include FilePattern::Assertions
  extend FilePattern::Assertions::ClassMethods
  # def test_class_assert_invariant
  #	FilePattern.assert_invariant
  # end # class_assert_invariant
  def test_path
  end # path

  def test_parse_pathname_regexp
  end # parse_pathname_regexp

  def test_pathname_glob
  end # pathname_glob

  def test_relative_path
  end # relative_path

  def test_class_assert_pre_conditions
    #	FilePattern.assert_pre_conditions
  end # class_assert_pre_conditions

  def test_class_assert_post_conditions
    FilePattern.assert_post_conditions
  end # class_assert_post_conditions

  def test_assert_pattern_array
    array = FilePattern::Patterns
    successes = array.map do |p|
      p[:example_file].match(p[:prefix])
      p[:example_file].match(p[:suffix])
    end # map
    assert(successes.all?, successes.inspect + "\n" + array.inspect)
    FilePattern.assert_pattern_array(FilePattern::Patterns)
  end # assert_pattern_array

  def test_Examples
    assert_data_file(Data_source_example)
  end # Examples
end # FilePattern
