describe('color', function () {
  beforeEach(function () {
    browser.addMockModule('httpBackendMock', function () {
      angular.module('httpBackendMock', ['ngMockE2E'])
        .run(function ($httpBackend) {
          $httpBackend.whenGET('settings.json').respond({
            colors: {
              background: '#0000ff',
              font: '#000000',
              statuses: {
                free: '#00ff00',
                call: '#ffff00',
                busy: '#ff0000'
              }
            }
          });

          $httpBackend.whenPOST('settings.json').respond(function (method, url, data) {
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
    beforeAll(function () {
      browser.get('#/home');
      browser.actions().mouseMove(element(by.className('navbar'))).perform();
      element(by.className('navbar')).element(by.linkText('Kirjaudu sisään')).click();

      element(by.model('login.username')).sendKeys('jooseppi');
      element(by.model('login.password')).sendKeys('oikee');
      element(by.buttonText('Login')).click();
    });

    it('changes color from settings', function () {
      browser.get('#/color');

      var bgInput = browser.element(by.model('color.colors.background'));
      bgInput.evaluate('color.colors.background = "#ff0000";');
      browser.element(by.buttonText('Tallenna')).click();

      var message = browser.element(by.tagName('p'));
      expect(message.getText()).toBe('Kivat valinnat! Ne on nyt tallennettu!');

      var body = browser.element(by.tagName('body'));
      expect(body.getCssValue('background-color')).toBe('rgba(255, 0, 0, 1)');
    });
  });
});
