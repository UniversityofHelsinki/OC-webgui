rspec_install:
	bundle install --jobs=3 --retry=3 --without=development --deployment
karma_install:
	rm -rf ~/.nvm && git clone https://github.com/creationix/nvm.git ~/.nvm && (cd ~/.nvm && git checkout `git describe --abbrev=0 --tags`) && source ~/.nvm/nvm.sh && nvm install 4
	npm install
protractor_install:
	bundle install --jobs=3 --retry=3 --without=development --deployment
	rm -rf ~/.nvm && git clone https://github.com/creationix/nvm.git ~/.nvm && (cd ~/.nvm && git checkout `git describe --abbrev=0 --tags`) && source ~/.nvm/nvm.sh && nvm install 4
	npm install
	npm run update-webdriver
rspec_before_script:
	psql -c 'create database ocwebgui_test;' -U postgres
karma_before_script:

protractor_before_script:
	psql -c 'create database ocwebgui_test;' -U postgres
	export DISPLAY=:99.0
	sh -e /etc/init.d/xvfb start
	bundle exec rails server -p 3000 & 
	sleep 5
rspec_script: 
	bundle exec rake
karma_script:
	node_modules/.bin/karma start karma.conf.js --no-auto-watch --single-run --reporters=dots --browsers=Firefox
protractor_script:
	node_modules/.bin/protractor e2e-tests/protractor.conf.js --browser=firefox
