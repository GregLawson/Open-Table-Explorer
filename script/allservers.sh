pkill -9 -f  "/usr/bin/ruby1.8 script/rails server -e"
rails server -e development -p 3002&
rails server -e  test -p 3001 &
rails server -e production -p 3000 &
ps -C ruby1.8 -o pid,args
