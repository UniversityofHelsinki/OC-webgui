describe('color', function () {
  beforeEach(function () {
    browser.addMockModule('httpBackendMock', function () {
      angular.module('httpBackendMock', ['ngMockE2E'])
        .run(function ($httpBackend) {
          var loggedIn = false;

          $httpBackend.whenPOST('api/login').respond(function () {
            loggedIn = true;
            return [200, { id: 1, username: 'jooseppi' }];
          });

          $httpBackend.whenDELETE('api/logout').respond(function () {
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
      element(by.linkText('Asetukset')).click();
      element(by.linkText('Värit')).click();

      var bgInput = browser.element(by.model('colors.colors.background'));
      bgInput.evaluate('colors.colors.background = "#ff0000";');
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

    it('changes font color from color settings', function () {
      element(by.linkText('Asetukset')).click();
      element(by.linkText('Värit')).click();

      var fontInput = browser.element(by.model('colors.colors.font'));
      fontInput.evaluate('colors.colors.font = "#00ff00";');
      browser.element(by.buttonText('Tallenna')).click();

      var message = browser.element(by.tagName('h1'));
      expect(message.getCssValue('color')).toBe('rgba(0, 255, 0, 1)');
    });

    it('changes underline color from color settings', function () {
      element(by.linkText('Asetukset')).click();
      element(by.linkText('Värit')).click();

      var fontInput = browser.element(by.model('colors.colors.font'));
      fontInput.evaluate('colors.colors.font = "#00ff00";');
      browser.element(by.buttonText('Tallenna')).click();

      var message = browser.element(by.tagName('h3'));
      expect(message.getCssValue('border-bottom-color')).toBe('rgba(0, 255, 0, 1)');
    });
  });
});
