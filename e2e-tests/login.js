describe('login', function () {
  beforeEach(function () {
    browser.addMockModule('httpBackendMock', function () {
      angular.module('httpBackendMock', ['ngMockE2E'])
        .run(function ($httpBackend) {
          var loggedIn = false;
          $httpBackend.whenPOST('login').respond(function (method, url, data) {
            var creds = angular.fromJson(data);
            if (creds.username === 'jooseppi') {
              if (creds.password !== 'oikee') {
                loggedIn = false;
                return [401, { error: 'wrong password' }];
              }
              loggedIn = true;
              return [200, { id: 1, username: 'jooseppi' }];
            }
            loggedIn = false;
            return [401, { error: 'invalid username' }];
          });
          $httpBackend.whenDELETE('logout').respond(function () {
            loggedIn = false;
            return [204];
          });
          $httpBackend.whenGET('user.json').respond(function () {
            if (!loggedIn) {
              return [401];
            }
            return [200, {
              id: 1,
              agent_id: null,
              username: 'jooseppi',
              is_admin: false
            }];
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
    element(by.className('navbar')).element(by.linkText('Kirjaudu sisään')).click();

    element(by.model('login.username')).sendKeys('jooseppi');
    element(by.model('login.password')).sendKeys('oikee');
    element(by.buttonText('Login')).click();

    expect(browser.getLocationAbsUrl()).toMatch('/home');

    element(by.className('navbar')).element(by.linkText('Kirjaudu ulos')).click();
  });

  it('should redirect back to protected route', function () {
    browser.get('#/stats/today');

    expect(browser.getLocationAbsUrl()).toMatch('/login');
    element(by.model('login.username')).sendKeys('jooseppi');
    element(by.model('login.password')).sendKeys('oikee');
    element(by.buttonText('Login')).click();

    expect(browser.getLocationAbsUrl()).toMatch('/stats');

    element(by.className('navbar')).element(by.linkText('Kirjaudu ulos')).click();
  });
});
