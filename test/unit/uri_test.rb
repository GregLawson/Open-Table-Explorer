###########################################################################
#    Copyright (C) 2011-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative 'test_environment'
require_relative '../../app/models/unit.rb'
require_relative '../../app/models/test_environment_test_unit.rb'
#require_relative '../../app/models/default_test_case.rb'
require_relative '../../app/models/uri.rb'
class URITest < TestCase
#  include DefaultTests2
  module Examples
		File_URI = URI.parse('file://' + File.expand_path($PROGRAM_NAME))
		Relative_path_URI = URI.parse('file:' + $PROGRAM_NAME)
		Port_URI = URI.parse('http:localhost:80')
		Path_URI = URI.parse('http:localhost/directory/file.html')
		Query_URI = URI.parse('http://localhost?cat+fish=dog&mouse=bird')
		Fragment_URI = URI.parse('http:localhost/directory/file.html#anchor')
		Doc_URI = URI.parse('http://foo.com/posts?id=30&limit=5#time=1305298413')

		All_URI = URI.parse('http://user@localhost:80/directory/file.html?cat=dog+mouse=bird#anchor')
		All_split = ["http", "user", "localhost", "80", nil, "/directory/file.html", nil, "cat=dog+mouse=bird", "anchor"]
		Shell_URI = URI.parse('shell:pwd')
		Registry_URI = URI.parse('generic:///registry')
		Opaque_URI = URI.parse('mailto:opaque@example.com')
		Longer_opaque_URI = URI.parse('generic:foo@foo.org?cat=fish#anchor')
#		include URI::RFC2396_REGEXP::PATTERN
  end #  Examples
  include Examples
	
	def test_FILE_open
			uri = File_URI
			refute_nil(uri)
			refute_nil(uri.open, uri.inspect)
			opened = if uri.respond_to?(:open)
				uri.open
			else
			end # if
			assert_equal(opened.read, File.open(uri.path).read)
		assert_instance_of(File, File_URI.open)
		assert_instance_of(File, Relative_path_URI.open, Relative_path_URI.explain)
	end # FILE_open
		
		def test_SHELL_open
			uri = Shell_URI
			assert_equal(['pwd'], Shell_URI.select(:opaque), Shell_URI.inspect)
			assert_equal('pwd', Shell_URI.opaque, Shell_URI.inspect)
			assert_equal(['pwd'], Shell_URI.select(:opaque), Shell_URI.inspect)
			assert_equal({scheme: 'shell', opaque: 'pwd'}, Shell_URI.uriHash, Shell_URI.explain)
			refute_nil(uri)
			refute_nil(uri.open, uri.inspect)
			opened = if uri.respond_to?(:open)
				uri.open
			else
			end # if
			assert_instance_of(Shell::Command, opened)
			assert_respond_to(opened, :output)
#			assert_respond_to(opened, :read)
			assert_equal(opened.output, ShellCommands.new(uri.opaque).output)
			uri_string = 'shell:ls+*'
			uri = URI.parse(uri_string)
			assert_equal({scheme: 'shell', opaque: 'ls+*'}, uri.uriHash, uri.explain)
			assert_instance_of(Shell::Command, uri.open)
			refute(uri.open.success?, uri.inspect)
			assert_empty(uri.open.output, uri.open.inspect)
		end # open

		def test_scheme_list
			assert_includes(URI.scheme_list, 'HTTP')
			assert_includes(URI.scheme_list, 'FILE')
			assert_includes(URI.scheme_list, 'SHELL')
		components = {}
		URI.scheme_list.values.map do |klass|
			components.merge!({klass => klass::COMPONENT})
		end # map
		assert_equal(components['HTTP'], components['HTTPS'], components.inspect) # all unique
		assert_equal(components['RSYNC'], components['FILE'], components.inspect) # all unique
		assert_equal(components['FILE'], components['SHELL'], components.inspect) # all unique
#		assert_equal(components.keys.size, components.values.uniq.size, components.inspect) # all unique
		end # scheme_list
		
		def test_component_hash
			ret = {}
			URI.scheme_list.values.map do |klass|
				ret.merge!({klass => klass::COMPONENT})
			end # map
			
		assert_equal(ret, URI.component_hash)
		assert_equal(URI.component_hash['HTTP'], URI.component_hash['HTTPS'], URI.component_hash.inspect) # all unique
		assert_equal(URI.component_hash['RSYNC'], URI.component_hash['FILE'], URI.component_hash.inspect) # all unique
		assert_equal(URI.component_hash['FILE'], URI.component_hash['SHELL'], URI.component_hash.inspect) # all unique
		end # component_hash
		
	def test_opaque_schemes
		assert_includes(URI.component_hash.values.flatten, :registry)
		assert_equal([URI::FILE, URI::SHELL], URI.opaque_schemes)
		URI.component_hash.each_pair do |scheme_capitalized, components|
#			refute_includes(components, :registry, scheme_capitalized)
		end # each
	end # opaque_schemes
	
	def test_registry_schemes
		assert_includes(URI.component_hash.values.flatten, :opaque)
		assert_equal([URI::FILE, URI::SHELL], URI.registry_schemes)
	end # registry_schemes

  def test_uriComponent
    uri = File_URI
		componentName = :scheme
		ret = uri.select(componentName)
    if ret.class == Array
			assert_instance_of(Array, File_URI.select(componentName))
    else
			assert_instance_of(String, File_URI.select(componentName))
    end
		assert_equal(['file'], File_URI.select(componentName))
		assert_equal(Array, File_URI.select(componentName).class)
		assert_equal('file', File_URI.uriComponent(componentName), File_URI.explain)

		assert_equal([80], Port_URI.select(:port) ,Port_URI.inspect)
		assert_equal(['time=1305298413'], Doc_URI.select(:fragment), Doc_URI.inspect)
		assert_equal(['cat+fish=dog&mouse=bird'], Query_URI.select(:query), Query_URI.inspect)
		assert_equal(['anchor'], Fragment_URI.select(:fragment), Fragment_URI.inspect)
		assert_equal(['pwd'], Shell_URI.select(:opaque), Shell_URI.inspect)

		assert_equal([nil], File_URI.select(:userinfo))
		UriParse::Optional_uri_components.each do |component_name|
			assert_equal(nil, File_URI.uriComponent(component_name), component_name)
		end # each

		assert_equal([File.expand_path($PROGRAM_NAME)], File_URI.select(:path), File_URI.explain)
		assert_equal("/home/greg/Desktop/src/Open-Table-Explorer/test/unit/uri_test.rb", File_URI.uriComponent(:path))
#		assert_equal(['directory/file.html'], Path_URI.select(:path), Path_URI.explain)
  end # uriComponent

  def test_uriHash
		assert_equal({scheme: "http", userinfo: 'user', host: "localhost", port: 80, path: "/directory/file.html", query: "cat=dog+mouse=bird", fragment: 'anchor'}, All_URI.uriHash, All_URI.explain)
  end # uriHash

	def test_parse_class
		assert_equal(URI::RFC3986_Parser, File_URI.parser.class)
		assert_equal(URI::RFC3986_Parser, Query_URI.parser.class)
		assert_equal(URI::RFC3986_Parser, Doc_URI.parser.class)
		assert_equal(URI::RFC3986_Parser, All_URI.parser.class)
		assert_equal(URI::RFC3986_Parser, Registry_URI.parser.class)
		assert_equal(URI::RFC3986_Parser, Opaque_URI.parser.class)
		assert_equal(URI::RFC3986_Parser, Longer_opaque_URI.parser.class)
		assert_equal(URI::RFC3986_Parser, Path_URI.parser.class)
		assert_equal(URI::RFC3986_Parser, Fragment_URI.parser.class)
		assert_equal(URI::RFC3986_Parser, Shell_URI.parser.class)
		assert_equal(URI::RFC3986_Parser, Port_URI.parser.class)
		assert_equal(URI::RFC3986_Parser, Opaque_URI.parser.class)
	end # parse_class
	
	def test_URI_state
		assert_instance_of(Hash, All_URI.state)
		assert_equal(false, Opaque_URI.state[:opaque_include], Opaque_URI.explain)
		assert_equal(true, Longer_opaque_URI.state[:opaque_include], Longer_opaque_URI.explain)
#		assert_equal('opaque@example.com', Opaque_URI_parse.state[:opaque_split], Opaque_URI_parse.explain)
#		assert_equal('foo@foo.org?cat=fish', Longer_opaque_URI_parse.state[:opaque_split], Longer_opaque_URI_parse.explain)
#		assert_equal(false, Opaque_URI_parse.state[:opaque_include], Opaque_URI_parse.explain)
#		assert_equal(true, Longer_opaque_URI_parse.state[:opaque_include], Longer_opaque_URI_parse.explain)
#		assert_equal(nil, Opaque_URI_parse.state[:opaque_select], Opaque_URI_parse.explain)
#			assert_equal(['foo@foo.org?cat=fish'], Longer_opaque_URI_parse.state[:opaque_split], Longer_opaque_URI_parse.explain)

#		assert_equal(nil, Opaque_URI_parse.state[:registry_select], Opaque_URI_parse.explain)
#		assert_equal(nil, Longer_opaque_URI_parse.state[:registry_select], Longer_opaque_URI_parse.explain)

	end # state

end # URI

class UriParseTest < TestCase
  module Examples
		File_URI_parse = UriParse.new(initialization_string: 'file://' + File.expand_path($PROGRAM_NAME))
		Port_URI_parse = UriParse.new(initialization_string: 'http:localhost:80')
		Path_URI_parse = UriParse.new(initialization_string: 'http:localhost/directory/file.html')
		Query_URI_parse = UriParse.new(initialization_string: 'http://localhost?cat+fish=dog&mouse=bird')
		Fragment_URI_parse = UriParse.new(initialization_string: 'http:localhost/directory/file.html#anchor')
		Doc_URI_parse = UriParse.new(initialization_string: 'http://foo.com/posts?id=30&limit=5#time=1305298413')

		All_URI_parse = UriParse.new(initialization_string: 'http://user@localhost:80/directory/file.html?cat=dog+mouse=bird#anchor')
		All_split = ["http", "user", "localhost", "80", nil, "/directory/file.html", nil, "cat=dog+mouse=bird", "anchor"]
		Shell_URI_parse = UriParse.new(initialization_string: 'shell:pwd')
		Registry_URI_parse = UriParse.new(initialization_string: 'generic:///registry')
		Opaque_URI_parse = UriParse.new(initialization_string: 'mailto:opaque@example.com')
		Longer_opaque_URI_parse = UriParse.new(initialization_string: 'generic:foo@foo.org?cat=fish#anchor')
#		include URI::RFC2396_REGEXP::PATTERN
  end #  Examples
  include Examples

  def test_uri
		assert_instance_of(URI::HTTP, All_URI_parse.uri)
  end # uri
	
	def test_component_names
	end # component_names
	
	def test_state
		assert_instance_of(Hash, All_URI_parse.state)
		assert_equal('opaque@example.com', Opaque_URI_parse.state[:opaque_split], Opaque_URI_parse.explain)
		assert_equal('foo@foo.org?cat=fish', Longer_opaque_URI_parse.state[:opaque_split], Longer_opaque_URI_parse.explain)
		assert_equal(nil, Opaque_URI_parse.state[:opaque_select], Opaque_URI_parse.explain)
#			assert_equal(['foo@foo.org?cat=fish'], Longer_opaque_URI_parse.state[:opaque_split], Longer_opaque_URI_parse.explain)

		assert_equal(nil, Opaque_URI_parse.state[:registry_select], Opaque_URI_parse.explain)
		assert_equal(nil, Longer_opaque_URI_parse.state[:registry_select], Longer_opaque_URI_parse.explain)

	end # state
	
	def test_explain
#		assert_operator(50, :>, Query_URI_parse.explain.size, Query_URI_parse.explain) 
#		assert_operator(50, :>, Doc_URI_parse.explain.size, Doc_URI_parse.explain) 
#		assert_operator(50, :>, Registry_URI_parse.explain.size, Registry_URI_parse.explain) 
#		assert_operator(50, :>, All_URI_parse.explain.size, All_URI_parse.explain) 
#		assert_operator(50, :>, File_URI_parse.explain.size, File_URI_parse.explain) 
		
		
		
		
		
		refute_nil(All_URI_parse.explain)
	end # explain
	
	def test_inspect
		assert_instance_of(String, All_URI_parse.explain)
	end # inspect

  def test_uriArray
		assert_equal('http', All_URI_parse.uriArray[0])
		assert_equal(All_split, URI.split(All_URI_parse.initialization_string))
		assert_equal(All_split, All_URI_parse.uriArray)
		assert_equal(File.expand_path($PROGRAM_NAME), File_URI_parse.uriArray[5], File_URI_parse.explain)
		assert_equal('opaque@example.com', Opaque_URI_parse.uriArray[6], Opaque_URI_parse.explain)
		refute_equal(All_URI_parse.uriArray, All_URI_parse.initialization_string.match(URI.regexp)[1..-1]) # verify regexp match
  end # uriArray


		def test_opaque?
			assert(Opaque_URI_parse.opaque?, Opaque_URI_parse.explain)
			assert(Longer_opaque_URI_parse.opaque?, Longer_opaque_URI_parse.explain)
    end # opaque?

		def test_registry?
#			assert(Opaque_URI_parse.registry?, Opaque_URI_parse.explain)
#			assert(Longer_opaque_URI_parse.registry?, Longer_opaque_URI_parse.registry_state.inspect)
    end # registry?
		
	def test_well_formed?
			assert_equal(Opaque_URI_parse.initialization_string, Opaque_URI_parse.uri.class.build(Opaque_URI_parse.uri.uriHash).to_s, Opaque_URI_parse.explain)
			assert(Opaque_URI_parse.well_formed?, Opaque_URI_parse.explain)
	end # well_formed?
		
  def test_UriParse_assert_pre_conditions
    UriParse.assert_pre_conditions
  end # assert_UriParse_pre_conditions

  def test_assert_pre_conditions
#    Test_URI_parse_record.assert_pre_conditions
			refute(File_URI_parse.frozen?, File_URI_parse.explain)
		Port_URI_parse.assert_pre_conditions
		Path_URI_parse.assert_pre_conditions
		Query_URI_parse.assert_pre_conditions
		Fragment_URI_parse.assert_pre_conditions
		Doc_URI_parse.assert_pre_conditions
		All_URI_parse.assert_pre_conditions
		Shell_URI_parse.assert_pre_conditions
		Registry_URI_parse.assert_pre_conditions
		Opaque_URI_parse.assert_pre_conditions
		Longer_opaque_URI_parse.assert_pre_conditions
		File_URI_parse.assert_pre_conditions
  end # assert_pre_conditions
		
	def test_refute_opaque
		File_URI_parse.refute_opaque
		Query_URI_parse.refute_opaque
		Doc_URI_parse.refute_opaque
		All_URI_parse.refute_opaque
		Registry_URI_parse.refute_opaque
	end # refute_opaque
		
	def test_assert_opaque
		Opaque_URI_parse.assert_opaque
		Longer_opaque_URI_parse.assert_opaque
		Path_URI_parse.assert_opaque
		Fragment_URI_parse.assert_opaque
		Shell_URI_parse.assert_opaque
		Port_URI_parse.assert_opaque
	end # assert_opaque
		
	def test_refute_registry
		File_URI_parse.refute_registry
		Query_URI_parse.refute_registry
		Doc_URI_parse.refute_registry
		All_URI_parse.refute_registry
		Registry_URI_parse.refute_registry
		Opaque_URI_parse.refute_registry
		Longer_opaque_URI_parse.refute_registry
		Path_URI_parse.refute_registry
		Fragment_URI_parse.refute_registry
		Shell_URI_parse.refute_registry
		Port_URI_parse.refute_registry
		Opaque_URI_parse.refute_registry
	end # refute_registry

	def test_assert_registry
	end # assert_registry

	def test_assert_well_formed
		Query_URI_parse.assert_well_formed
		Doc_URI_parse.assert_well_formed
		Opaque_URI_parse.assert_well_formed
		Longer_opaque_URI_parse.assert_well_formed
		Shell_URI_parse.assert_well_formed
#		All_URI_parse.assert_well_formed
	end # assert_well_formed

	def test_refute_well_formed
		File_URI_parse.refute_well_formed
		Registry_URI_parse.refute_well_formed
		Path_URI_parse.refute_well_formed
		Fragment_URI_parse.refute_well_formed
		Port_URI_parse.refute_well_formed
	end # refute_well_formed
end # URI_parse
