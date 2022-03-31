# Documentation

Additional documentation to support the `OCWEBGUI` documentation in helsinkifi wiki.

## Ruby 2.3.0 requirements

For newer Ubuntu versions, you might need libssl1.0-dev to compile Ruby 2.3.0

```
sudo apt update && apt-cache policy libssl1.0-dev
sudo apt-get install libssl1.0-dev
```

## Rbenv installation

Ruby-build needed and `rbenv rehash` is the key here.

```
rbenv install 2.3.0
rbenv global 2.3.0
rbenv rehash
```

**NB!** If error when installing that can't write shim, might help:
```
cd ~/.rbenv/shims/
mv .rbenv-shim .rbenv-shim-old.
rbenv rehash
rbenv install --list
rbenv global 2.3.0
which ruby
```

## If using NVM

```
nvm use (12)
npm install
```

## Installation history command for production

Best to run commands always with `bundle exec` prefix.

``` 
gem install bundler -v 1.12.5
bundle install
sudo apt-get install beanstalkd 
sudo systemctl start beanstalkd.socket
sudo apt install ruby-god
RAILS_ENV=production bundle exec rake db:create
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production OC_WEBGUI_PASSWORD=<password> bundle exec rake db:seed
RAILS_ENV=production bundle exec rake assets:precompile
```

`config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?`

Remember to set to `true`, if running locally a production environment and can't find assets, http 404, even though they are in public/assets

## Creating the admin user

Admin user login is needed so that the user interface looks pretty,
to create the first admin user as local production env run:
``` 
RAILS_ENV=production rails c
User.create(username: 'admin', password: 'admin', is_admin: true)
```

## Logging when god running

tail -f log/production.log
tail -f log/clockwork.log
tail -f log/backburner.log
