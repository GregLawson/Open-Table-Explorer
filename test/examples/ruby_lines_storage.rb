###########################################################################
#    Copyright (C) 2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
    Log_glob = 'log/unit/2.2/2.2.3p173/silence/*.log'
    Log_paths = Dir[Log_glob]
    Log_reads = Eval.read_all(Log_glob)
    Errors_seen = Eval.errors_seen(Log_glob)
		Unique_error_messages = Errors_seen.compact.uniq
