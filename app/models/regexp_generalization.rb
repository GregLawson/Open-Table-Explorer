###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# Class methods
# For a fixed string compute parse tree or sub trees that match
class RegexpGeneralization < RegexpMatch #file context
attr_reader :dataToParse, :matched_data
# Normal new- 
#	regexp is a RegexpTree and 
#	dataToParse is a String that may or may not match
# Partial match
#	regexp is an Array of RegexpMatches that partially match dataToParse and 
#	dataToParse is the String union of that may or may not match
# better explanation needed here, see tests.
# Top level incremental match of regexp tree to data
# self - array of parsed tree to test for match
# calls match_data?, matchedTreeArray depending
def matchSubTree
	if empty? then
		return ['.','*']
	elsif RegexpMatch.match_data?(to_regexp, @dataToParse) then
		return self
	elsif kind_of?(Array) then 
		matchedTreeArray
	else
		raise "How did I get here?"
		return nil
	end #if
end #matchSubTree
# Combines match alternatives?
# returns a RegexpMatch parse tree that should match
# matches - array of Range matches
def mergeMatches(matches)
	if matches.size==0 then
		return RegexpMatch.new(['.', '*'], dataToParse)
	elsif matches.size==1 then
		return RegexpMatch.new(self[matches[0]], dataToParse)
	elsif matches[0].end>=matches[1].begin then #overlap
		prefix=matches[0].begin..matches[1].begin-1
		suffix=matches[0].end+1..matches[1].end
		overlap= matches[1].begin..matches[0].end
		return RegexpMatch.new(RegexpTree.new([self[prefix],[self[overlap], '|'],self[suffix],mergeMatches(matches[1..-1])]), dataToParse)
	elsif matches.size==2 then # no overlap w/2 matches
		return self[matches[0]]+[['.','*']]+self[matches[1]]
	else # no overlap w/ 3 or more matches
		puts "matches=#{matches.inspect}"
		 return self[matches[0]]+[['.','*']]+mergeMatches(matches[1..-1]) # recursive for >2 matches
	end #end	

end #mergeMatches
# accounts for arrays (subtrees) in parse tree
# returns RegexpMatch that should match
# calls consecutiveMatches to find matches
# calls mergeMatches to reduce multiple matches to one regexp string
def matchedTreeArray
	if self.class.PostfixOperators.index(self[0]) then
		return self.to_s
	else
		matches= consecutiveMatches(+1,0,0)
		if matches.nil? || matches.empty? then
			return ['.', '*']
		elsif matches.size==1 then
			return self[matches[0]]
		else
			return mergeMatches(matches)
		end #if
	end #if
end #matchedTreeArray
def generalize_characters(branch=self, data_to_match=@dataToParse)
end #generalize_characters
def generalize_sequence(branch=self, data_to_match=@dataToParse)
	match_map=branch.map do |sub_tree| # look at each character
		map_matches(sub_tree, data_to_match)
		# should shorten data_to_match!
	end #map
	ret=match_map.map do |sub_tree|
		if subtree[:matched_data] then
			sub_tree
		else
			sub_tree[:regexp].most_specialized(sub_tree[])	
		end #if
	end #map
	return ret
end #generalize_sequence
def generalize_repetition(branch=self, data_to_match=@dataToParse)
end #generalize_repetition
# Generalize RegexpTree branch so that it matches dataToMatch
# with as fewer generalizations as possible.
def generalize(branch=self, data_to_match=@dataToParse)
	if branch.kind_of?(Array) then
		branches=branch.map do |sub_tree| # look at each character
			map_matches(sub_tree, data_to_match)
			# should shorten data_to_match!
		end #map
		return 	RegexpMatch.new([branches, concise_repetion_node(branch.repetition_length[0], data_to_match.size)], data_to_match)
	else # not Array, probably single character Strings
		most_specialized=[GenericType.find_by_name('ascii')]
			data_to_match.each_char do |c|
				ret=most_specialized.each do |m|
					most_specialized=m.most_specialized?(c)
				end #
			end #each_char
		return 	RegexpMatch.new(['[[:print:]]', concise_repetion_node(branch.repetition_length[0], data_to_match.size)], data_to_match)
	end #if
end #generalize
# Apply block to each non-leaf or branching node
# Provides a prefix walk
# One pass:
#   Recursively visit branches, then descendants
# Desirable when result tree is constructed top-down
# Branching node block can ignore (or summarize)subtrees.
# Descendants have the block applied after they are reassembled into a tree.
def map_prefix(&visit_proc)
	ret=visit_proc.call(self) # end recursion
	if ret.nil? then
		return nil
	else
		if kind_of?(Array) then
			return self.map do |sub_tree| 
				self.class.new(sub_tree).map_prefix{|p| visit_proc.call(p)}
				end #map
		else
			visit_proc.call(self) # end recursion
		end #if
	end #map
end #map_prefix
end #RegexpMatch