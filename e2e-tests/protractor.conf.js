exports.config = {
  allScriptsTimeout: 11000,
  specs: [
    '*.js'
  ],
  capabilities: {
    'browserName': 'chrome'
  },
  baseUrl: 'http://localhost:3000/',
  framework: 'jasmine2',
  jasmineNodeOpts: {
    defaultTimeoutInterval: 30000
  },
  onPrepare: function() {
    setTimeout(function() {
        browser.driver.executeScript(function() {
            return {
                width: window.screen.availWidth,
                height: window.screen.availHeight
            };
        }).then(function(result) {
            browser.driver.manage().window().setSize(result.width, result.height);
        });
    });
  }
};
