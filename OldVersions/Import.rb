#!/usr/bin/ruby
#   Copyright (C) 2009  Gregory Lawson
#  
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2.1 of the License, or
#   (at your option) any later version.
# 
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, a copy is available at
#   http://www.r-project.org/Licenses/

require 'table.rb'

#db=DB.new

table=File_Acquisition.new('Stations','/home/greg/localEdit/DTV stations.csv',"\t",1,"channel")

#table.createTable
table.import
table.scaffold

