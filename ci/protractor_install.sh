bundle install --jobs=3 --retry=3 --without=development --deployment
rm -rf ~/.nvm && git clone https://github.com/creationix/nvm.git ~/.nvm && (cd ~/.nvm && git checkout `git describe --abbrev=0 --tags`) && . ~/.nvm/nvm.sh && nvm install $TRAVIS_NODE_VERSION
npm install
npm run update-webdriver