###########################################################################
#    Copyright (C) 2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
    Log_glob = 'log/unit/2.2/2.2.3p173/silence/*.log'
    Log_paths = Dir[Log_glob]
    Log_read_returns = Reconstruction.read_all(Log_glob)
#!    Errors_seen = Log_read_returns.reject {|reconstruction| reconstruction.success? }
#!		Unique_error_messages = Errors_seen.map{|h| h[:errors]}.compact.uniq
