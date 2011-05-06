 date --rfc-3339='date'|awk -F" |-" '{OFS="";print "wget -nv http://User:sma@192.168.1.251/DATA/",$1,"/",$2,"-",$3,"-",substr($1,3,2),".csv ";}'|bash -x
 awk 'NR>4 { print gensub("-",";","g",gensub(".csv","",1,FILENAME)),";",$0; }' 20*.csv >cat.csv
 awk ' BEGIN {ORS="\r\n";} {print $0;} ' cat.csv >catCrLf.csv
