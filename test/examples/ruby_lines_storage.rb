###########################################################################
#    Copyright (C) 2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
    Log_glob = 'log/unit/2.2/2.2.3p173/silence/*.log'
    Log_paths = Dir[Log_glob]
    Log_evals = Reconstruction.read_all(Log_glob)
    Errors_seen = Log_evals.reject {|eval| eval.success? }
		Unique_error_messages = Errors_seen.group_by{|eval| eval.reconstruction.error_group}
