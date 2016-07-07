rspec: 
	bundle exec rake
karma:
	node_modules/.bin/karma start karma.conf.js --no-auto-watch --single-run --reporters=dots --browsers=Firefox
protractor:
	node_modules/.bin/protractor e2e-tests/protractor.conf.js --browser=firefox
