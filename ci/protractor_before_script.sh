psql -c 'create database ocwebgui_test;' -U postgres
export DISPLAY=:99.0
sh -e /etc/init.d/xvfb start
bundle exec rails server -p 3000 & 
sleep 5