describe('color', function () {
  beforeEach(function () {
    browser.addMockModule('httpBackendMock', function () {
      angular.module('httpBackendMock', ['ngMockE2E'])
        .run(function ($httpBackend) {
          var loggedIn = false;

          $httpBackend.whenPOST('login').respond(function () {
            loggedIn = true;
            return [200, { id: 1, username: 'jooseppi' }];
          });

          $httpBackend.whenDELETE('logout').respond(function () {
            loggedIn = false;
            return [204];
          });

          $httpBackend.whenGET('api/settings').respond(function () {
            return [200, {
              colors: {
                background: loggedIn ? '#ff00ff' : '#0000ff',
                font: '#000000',
                statuses: {
                  free: '#00ff00',
                  call: '#ffff00',
                  busy: '#ff0000'
                }
              }
            }];
          });

          $httpBackend.whenPOST('api/settings').respond(function (method, url, data) {
            return [200, data];
          });
        });
    });
  });

  describe('not logged in', function () {
    it('default color', function () {
      browser.get('#/home');
      var body = browser.element(by.tagName('body'));
      expect(body.getCssValue('background-color')).toBe('rgba(0, 0, 255, 1)');
    });
  });

  describe('logged in', function () {
    beforeEach(function () {
      browser.get('#/home');
      element(by.className('navbar')).element(by.linkText('Kirjaudu sisään')).click();

      element(by.model('login.username')).sendKeys('jooseppi');
      element(by.model('login.password')).sendKeys('oikee');
      element(by.buttonText('Login')).click();
    });

    it('shows colors from previous user settings', function () {
      var body = browser.element(by.tagName('body'));
      expect(body.getCssValue('background-color')).toBe('rgba(255, 0, 255, 1)');
    });

    it('changes color from settings', function () {
      element(by.linkText('Säädä värejä')).click();

      var bgInput = browser.element(by.model('color.colors.background'));
      bgInput.evaluate('color.colors.background = "#ff0000";');
      browser.element(by.buttonText('Tallenna')).click();

      var message = browser.element(by.tagName('p'));
      expect(message.getText()).toBe('Kivat valinnat! Ne on nyt tallennettu!');

      var body = browser.element(by.tagName('body'));
      expect(body.getCssValue('background-color')).toBe('rgba(255, 0, 0, 1)');
    });

    it('reloads default settings on log out', function () {
      element(by.className('navbar')).element(by.linkText('Kirjaudu ulos')).click();
      var body = browser.element(by.tagName('body'));
      expect(body.getCssValue('background-color')).toBe('rgba(0, 0, 255, 1)');
    });
  });
});
