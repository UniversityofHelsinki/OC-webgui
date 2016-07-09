nvm use 4.0
psql -c 'create database ocwebgui_test;' -U postgres
bundle exec rails server -p 3000 & 
sleep 5
