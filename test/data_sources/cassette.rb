#  /
puts "ARGV=#{ARGV.inspect}"
Album=ARGV[0]
Tape=ARGV[1]
Side=ARGV[2]
Directory=ARGV[3]
BaseName=Directory+'/'+Album+'/'+'T'+Tape+'S'+Side
Duration='2700' # seconds
#ef cassette()
	arCommand="arecord --device=default:CARD=Controller --duration=#{Duration} --format=cd "
	system arCommand+' "'+BaseName+'.wav"'
	lameCommand="lame \"#{BaseName}.wav\" \"#{BaseName}.mp3\""
	system lameCommand
#ls -l
#	splitCommand="mp3splt -s T1S1.mp3 -p nt=3"
#mv T1S1_silence_* /media/VN8100PC/RECORDER/FOLDER_D/
#ls -l
#mp3splt -s T1S1.mp3 -p nt=3
#mv T1S1_silence_* /media/VN8100PC/RECORDER/FOLDER_C/
#umount /media/VN8100PC 
#nd #cassette
