describe('login', function () {
  beforeEach(function () {
    browser.addMockModule('httpBackendMock', function () {
      angular.module('httpBackendMock', ['ngMockE2E'])
        .run(function ($httpBackend) {
          $httpBackend.whenPOST('login').respond(function (method, url, data) {
            var creds = angular.fromJson(data);
            if (creds.username === 'jooseppi') {
              if (creds.password !== 'oikee') {
                return [401, { error: 'wrong password' }];
              }
              return [200, { id: 1, username: 'jooseppi' }];
            }
            return [401, { error: 'invalid username' }];
          });
        });
    });
  });

  it('should fail with invalid user', function () {
    browser.get('#/login');

    element(by.model('login.username')).sendKeys('hax0r');
    element(by.model('login.password')).sendKeys('1337');
    element(by.buttonText('Login')).click();

    expect(element(by.className('error')).getText()).toBe('invalid username');
  });

  it('should fail with wrong password', function () {
    browser.get('#/login');

    element(by.model('login.username')).sendKeys('jooseppi');
    element(by.model('login.password')).sendKeys('eioo');
    element(by.buttonText('Login')).click();

    expect(element(by.className('error')).getText()).toBe('wrong password');
  });

  it('should redirect to /home with no history', function () {
    browser.get('#/login');

    element(by.model('login.username')).sendKeys('jooseppi');
    element(by.model('login.password')).sendKeys('oikee');
    element(by.buttonText('Login')).click();

    expect(browser.getLocationAbsUrl()).toMatch('/home');
  });

  it('should redirect back /home', function () {
    browser.get('#/home');
    browser.actions().mouseMove(element(by.className('navbar'))).perform();
    element(by.className('navbar')).element(by.linkText('Login')).click();

    element(by.model('login.username')).sendKeys('jooseppi');
    element(by.model('login.password')).sendKeys('oikee');
    element(by.buttonText('Login')).click();

    expect(browser.getLocationAbsUrl()).toMatch('/home');
  });

  it('should redirect back to protected route', function () {
    browser.get('#/stats');

    expect(browser.getLocationAbsUrl()).toMatch('/login');
    element(by.model('login.username')).sendKeys('jooseppi');
    element(by.model('login.password')).sendKeys('oikee');
    element(by.buttonText('Login')).click();

    expect(browser.getLocationAbsUrl()).toMatch('/stats');
  });
});
