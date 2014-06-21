require_relative "../../app/models/r.rb"
#R_Interface.psqlExport('ted_web_box_fulls')
R_Interface.importRelation('ted_web_box_fulls')
R_Interface.eval_R_shell("ted_web_box_fulls<-read.csv('/tmp/ted_web_box_fulls.csv')")
R_Interface.eval_R_shell("ted_web_box_fulls$created_at<-as.POSIXct(ted_web_box_fulls$created_at)")

R_Interface.eval_R_shell("start<-diff(unclass(ted_web_box_fulls$error))")

R_Interface.eval_R_shell('start[length(ted_web_box_fulls$error)]=NA')

puts R_Interface.eval_R_shell("tapply(ted_web_box_fulls$vacl1_v,start,summary)")
R_Interface.eval_R_shell("rle(as.vector(ted_web_box_fulls$error))")
R_Interface.pairSummary('ted_web_box_fulls$vacl2_v','ted_web_box_fulls$vacl1_v')