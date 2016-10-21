###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/regexp.rb'
class Regexp
  require_relative '../../test/assertions.rb'
  module Examples
    include DefinitionalConstants
    Ip_number_pattern = /\d{1,3}/
    Escape_string = '\d'.freeze
    Back_reference = ((/[aeiou]/.capture(:vowel) * /./).back_reference(:vowel) * /./).back_reference(:vowel)
    Regexp_exception = Regexp.regexp_error('[')
  end # Examples
end #Regexp
