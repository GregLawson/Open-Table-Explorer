pkill -9 -f  "/usr/bin/ruby1.8 script/rails server -e"
export RAILS_ENV=development
rails server -e development -p 3002&
export RAILS_ENV=production
rails server -e production -p 3000 &
export RAILS_ENV=test # last so interactive is test
rails server -e  test -p 3001 &
ps -C ruby1.8 -o pid,args
