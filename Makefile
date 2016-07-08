rspec_script: 
	bundle exec rake
karma_script:
	node_modules/.bin/karma start karma.conf.js --no-auto-watch --single-run --reporters=dots --browsers=Firefox
protractor_script:
	node_modules/.bin/protractor e2e-tests/protractor.conf.js --browser=firefox
