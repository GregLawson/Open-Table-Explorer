def globSearch(tool,glob)
	if glob.is_a?(Symbol) then
		return `#{tool} #{glob}*`
	else
		return `#{tool} #{glob}`
	end #if
end #def
def pkgstatus(package,packageType=nil)
	puts globSearch('which',package)
	puts globSearch('type',package)
	puts globSearch('whatis',package)
	if packageType.nil? then
		pkgstatus(package,:dpkg)
		pkgstatus(package,:gem)
	elsif packageType==:dpkg then
		puts globSearch('dpkg -l', package)
	elsif packageType==:gem
		puts "gem=#{`ls ~/.rvm/gem/*/#{package}*`}"
	else
		puts "unknown packageType=#{packageType}"
	end #if
end #def
def envStatus
	path=`echo $PATH`.split(':')
	puts "path=#{path}"
	#~ rvmQuery=`type rvm` 
	#~ puts "rvmQuery=#{rvmQuery.inspect}"
		list=`rvm list`
		puts "list=#{list}"
	rvmQuery=`type rvm | head -1` 
	puts "rvmQuery=#{rvmQuery.inspect}"
	if rvmQuery=='rvm is a function' then
	else
		puts "rvm is not installed"
		system "grep rvm ~/.*profile --no-messages"
		system "grep rvm ~/.bashrc  --no-messages"
	end #if

end #def
pkgstatus(:zlib)
pkgstatus('rubygems[1-9]*')
pkgstatus(:rails)
pkgstatus('sqlite3')
#~ ruby -v
#~ sudo apt-get install rubygems
#~ sudo apt-get install rails
#~ sudo apt-get install sqlite3
#~ apt-get autoremove
#~ sudo apt-get autoremove
#~ bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)
#~ sudo apt-get install curl wget
#~ bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)
#~ sudo apt-get install ruby-1.9
#~ sudo aptitude
#~ gem install refinerycms
#~ sudo gem install refinerycms
#~ rails -v
#~ sudo bundle install
#~ gem psych
#~ gem install psych
#~ sudo gem install psych
#~ type rvm | head -1
#~ sudo bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)
#~ less .profile 
#~ less .bashrc 
#~ nano .profile 
#~ echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function' >> ~/.profile
#~ source ~/.profile
#~ type rvm | head -1
#~ rvm notes
#~ bash -v
#~ rvm list
#~ rvm known
#~ rvm list known
#~ type rvm | head -1
#~ gem install psych
#~ rvm use 1.9.2
#~ gem install psych
#~ sudo bundle install
#~ gem install psych
#~ gem install rest-client -v 1.6.6
#~ gem install gherkin -v 2.4.15
#~ rvm list known
#~ sudo rvm pkg install zlib
#~ rvm pkg install zlib
#~ gem install psych
#~ gem install gherkin -v 2.4.15
#~ gem install rest-client -v 1.6.6
#~ echo $rvm_path
#~ echo $rvm_path/usr
#~ ls $rvm_path/usr
#~ rvm remove 1.9.2
#~ $ rvm install 1.9.2 --with-zlib-dir=$rvm_path/usr
#~ rvm install 1.9.2 --with-zlib-dir=$rvm_path/usr
#~ gem install psych
#~ sudo bundle install
#~ gem install rest-client -v 1.6.6
#~ sudo bundle install
#~ gem install gherkin -v 2.4.15
#~ sudo bundle install
#~ history
#~ ls
#~ cd git
#~ ls
#~ refinerycms rickrockstar
#~ sudo gem install refinerycms
#~ refinerycms rickrockstar
#~ ls
#~ cd Open-Table-Explorer/
#~ ls
#~ git checkout master
#~ git-cola
#~ refinerycms rickrockstar
#~ gem install refinerycms
#~ refinerycms rickrockstar
#~ rails -v
#~ sudo bundle install
#~ rails -v
#~ sudo bundle install rake
#~ ruby -v
#~ rvm list known
#~ rvm install 1.8.7
#~ rvm use 1.8.7
#~ ls
#~ rails server
#~ sudo bundle install
#~ sudo apt-get install libxml
#~ sudo aptitude
#~ sudo bundle install
#~ sudo aptitude
#~ sudo bundle install
#~ # ruby developer packages
#~ sudo apt-get install ruby1.8-dev ruby1.8 ri1.8 rdoc1.8 irb1.8
#~ sudo apt-get install libreadline-ruby1.8 libruby1.8 libopenssl-ruby
#~ # nokogiri requirements
#~ sudo apt-get install libxslt-dev libxml2-dev
#~ sudo bundle install
#~ sudo aptitude
#~ sudo bundle install
#~ sudo apt-get install sqlite3-ruby 
#~ sudo aptitude
#~ sudo bundle install
#~ sudo aptitude
#~ man dpkg
#~ dpkg -S sqlite.h
#~ dpkg -L sqlite.h
#~ dpkg --contents
#~ dpkg --contents *
#~ man dpkg-cache
#~ man dpkg-scanpackages 
#~ man dpkg-query 
#~ sudo apt-get install libsqlite-devel
#~ sudo aptitude
#~ sudo bundle install
#~ refinerycms rickrockstar
#~ gem install refinerycms
#~ rvm use 1.9.2
#~ sudo bundle install
#~ refinerycms rickrockstar
#~ rails -v
#~ sudo bundle install
#~ sudo apt-get install libsqlite-devel
#~ sudo bundle install
#~ refinerycms rickrockstar
#~ refinerycms rickrockstar >log.err
#~ cat log.err
#~ less log.err
#~ od log.err 
#~ od log.err -A
#~ od log.err -a
#~ rm log.err
#~ refinerycms rickrockstar 
#~ sudo apt-get install rake
#~ refinerycms rickrockstar  --rails-version 3.0
#~ rails -v
#~ gem install rails
#~ sudo bundle install
#~ rails -v
#~ gem remove psych
#~ man gem
#~ gem help
#~ gem help commands
#~ gem uninstall psych
#~ rails -v
#~ gem install rake
#~ rails -v
#~ sudo bundle install
#~ rails -v
#~ sudo bundle install
  #~ 646* gem install rake
#~ sudo bundle install
#~ gem list
#~ rails -v
#~ gem install rails
#~ rails -v
#~ sudo bundle install
#~ gem list
#~ rails -v
#~ sudo bundle install
#~ refinerycms rickrockstar
#~ refinerycms rickrockstar  --rails-version 3.0
#~ gem install refinerycms
#~ refinerycms rickrockstar
#~ refinerycms rickrockstar  --rails-version 3.1
#~ refinerycms rickrockstar  --rails-version 3.0.10
#~ ruby -v
#~ rvm list known
#~ rvm install 1.9.3
#~ rvm list known
#~ rvm install 1.8.7-head
#~ sudo apt-get install bison
#~ sudo apt-get purge rake
#~ gem install rake
#~ sudo bundle install
#~ rails -v
#~ gem uninstall rake
#~ gem uninstall rack
#~ rails -v
#~ gem uninstall rack
#~ gem install rails
#~ rails -v
#~ whereis bundle
#~ sudo nano /usr/local/bin/bundle
#~ ls -l /usr/bin/env
#~ sudo nano /usr/local/bin/bundle
#~ rails -v
#~ sudo bundle install
#~ rails -v
#~ whereis rails
#~ /usr/local/bin/rails -v
#~ ls
#~ rails -v
#~ what rails
#~ whatis rails
#~ whatis rvm
#~ sudo rvm pkg install zlib
#~ rvm list
#~ type rvm | head -1
#~ type rvm 
#~ man type
#~ man bash
#~ type rvm -a
#~ type -a rvm 
#~ type -a rails
#~ whatis rails
#~ what rails
#~ /usr/local/bin/rails -v
#~ /home/greg/.rvm/gems/ruby-1.9.2-p290/bin/rails -v
#~ rvm use 1.8.7
#~ rails -v
#~ whatis rails
#~ type -a rails
#~ /usr/local/bin/rails -v
#~ rvm list
#~ rvm use 1.9.3
#~ type -a rails
#~ rails -v
#~ /usr/local/bin/rails -v
#~ gem install rails
#~ sudo rvm pkg install zlib
#~ rvm pkg install zlib
#~ /usr/local/bin/rails -v
#~ ls -l /usr/local/bin/rails
#~ ls
#~ rvm pkg install rails
#~ gem install rails
#~ rvm pkg install zlib

