nvm use 4.0
psql -c 'create database ocwebgui_test;' -U postgres
export DISPLAY=:99.0
"/sbin/start-stop-daemon --start --pidfile /tmp/custom_xvfb_99.pid --make-pidfile --background --exec /usr/bin/Xvfb -- :99 -ac -screen 0 1920x1080x16"
bundle exec rails server -p 3000 & 
sleep 5
