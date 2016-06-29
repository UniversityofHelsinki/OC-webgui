describe('homepage', function () {
  it('should automatically redirect to /home', function () {
    browser.get('');
    expect(browser.getLocationAbsUrl()).toMatch('/home');
  });
  it('should contain header', function () {
    browser.get('#/home');
    expect(element(by.tagName('h1')).getText()).toBe('Home');
  });
});

describe('screen', function () {
  var agentCards;

  beforeEach(function () {
    browser.addMockModule('httpBackendMock', function () {
      angular.module('httpBackendMock', ['ngMockE2E'])
        .run(function ($httpBackend) {
          $httpBackend.whenGET('agent_statuses.json').respond([
            {
              id: 1,
              agent_id: 1234,
              name: 'Kekkonen Benjamin',
              team: 'Helpdesk',
              status: 'Tauko',
              created_at: Date.now()
            },
            {
              id: 2,
              agent_id: 4321,
              name: 'Kanerva Aallotar',
              team: 'Helpdesk',
              status: 'Vapaa',
              created_at: Date.now()
            },
            {
              id: 10,
              agent_id: 8754,
              name: 'Ansala Tuomas',
              team: 'Helpdesk',
              status: 'Tauko',
              created_at: Date.now()
            },
            {
              id: 6,
              agent_id: 666,
              name: 'Ahola Jenni',
              team: 'Helpdesk',
              status: 'Tauko',
              created_at: Date.now()
            }
          ]);
          $httpBackend.whenGET('teams.json').respond([
            {
              name: 'Helpdesk',
              filter: true
            }
          ]);
          $httpBackend.whenGET('states.json').respond([
            {
              name: 'Tauko',
              filter: true
            }
          ]);
        });
    });
    browser.get('#/screen');
    agentCards = element.all(by.className('agent-card'));
  });

  it('should have agent cards', function () {
    expect(agentCards.count()).toBe(4);
  });

  it('should have agent names', function () {
    expect(agentCards.get(0).element(by.className('agent-name')).getText()).toBe('Benjamin K');
    expect(agentCards.get(1).element(by.className('agent-name')).getText()).toBe('Aallotar K');
    expect(agentCards.get(2).element(by.className('agent-name')).getText()).toBe('Tuomas A');
    expect(agentCards.get(3).element(by.className('agent-name')).getText()).toBe('Jenni A');
  });

  it('should have agent statuses', function () {
    expect(agentCards.get(0).element(by.className('agent-status')).getInnerHtml()).toBe('Tauko');
    expect(agentCards.get(1).element(by.className('agent-status')).getInnerHtml()).toBe('Vapaa');
    expect(agentCards.get(2).element(by.className('agent-status')).getInnerHtml()).toBe('Tauko');
    expect(agentCards.get(3).element(by.className('agent-status')).getInnerHtml()).toBe('Tauko');
  });

  it('should hide open status text', function() {
    expect(agentCards.get(0).element(by.className('agent-status-container')).getCssValue('visibility')).not.toBe('hidden');
    expect(agentCards.get(1).element(by.className('agent-status-container')).getCssValue('visibility')).toBe('hidden');
    expect(agentCards.get(2).element(by.className('agent-status-container')).getCssValue('visibility')).not.toBe('hidden');
    expect(agentCards.get(3).element(by.className('agent-status-container')).getCssValue('visibility')).not.toBe('hidden');
  });

  it('should have agent time in status', function () {
    // TODO: mock browser time
    // expect(agentCards.get(0).element(by.className('status-timer')).getText()).toBe('108:05');
    // expect(agentCards.get(1).isElementPresent(by.className('status-timer'))).toBe(false);
    // expect(agentCards.get(2).element(by.className('status-timer')).getText()).toBe('09:03');
    // expect(agentCards.get(3).element(by.className('status-timer')).getText()).toBe('05:43');
  });

  it('Status color should match status text', function () {
    expect(agentCards.get(0).element(by.className('agent-status-color')).getAttribute('class'))
      .toMatch('agent-status-color-red');
    expect(agentCards.get(1).element(by.className('agent-status-color')).getAttribute('class'))
      .toMatch('agent-status-color-green');
    expect(agentCards.get(2).element(by.className('agent-status-color')).getAttribute('class'))
      .toMatch('agent-status-color-red');
    expect(agentCards.get(3).element(by.className('agent-status-color')).getAttribute('class'))
      .toMatch('agent-status-color-red');
  });

  it('Sidebar status view should be correct', function () {
    var statusCount = element.all(by.className('agent-status-count'));

    expect(statusCount.get(0).element(by.className('green-count')).getText()).toBe('1');
    expect(statusCount.get(1).element(by.className('yellow-count')).getText()).toBe('0');
    expect(statusCount.get(2).element(by.className('red-count')).getText()).toBe('3');
  });

  it('should filter correctly', function () {
    element(by.linkText('rajaa')).click();
    element(by.id('Tauko')).click();
    element(by.linkText('Show state screen')).click();
    agentCards = element.all(by.className('agent-card'));
    expect(agentCards.count()).toBe(1);
    expect(agentCards.get(0).element(by.className('agent-name')).getText())
      .toBe('Aallotar K');
  });
});

describe('queue', function () {
  it('should show 2 queuers', function () {
    browser.addMockModule('httpBackendMock', function () {
      angular.module('httpBackendMock', ['ngMockE2E'])
        .run(function ($httpBackend) {
          $httpBackend.whenGET('queue.json').respond([
            {
              line: 136,
              label: 'sssssssss',
              time_in_queue: 265
            },
            {
              line: 133,
              label: 'zzzzz',
              time_in_queue: 73
            }
          ]);
        });
    });
    browser.get('#/queue');

    var queue = element.all(by.className('queuer'));

    expect(queue.count()).toBe(2);

    expect(queue.get(0).element(by.className('queuer-time')).getText()).toBe('04:25');
    expect(queue.get(0).isElementPresent(by.className('queuer-flag-Fin'))).toBe(true);

    expect(queue.get(1).element(by.className('queuer-time')).getText()).toBe('01:13');
    expect(queue.get(1).isElementPresent(by.className('queuer-flag-Swe'))).toBe(true);

    expect(browser.isElementPresent(by.className('plus-5'))).toBe(false);
  });

  it('should show only 5 queuers and indicator of more', function () {
    browser.addMockModule('httpBackendMock', function () {
      angular.module('httpBackendMock', ['ngMockE2E'])
        .run(function ($httpBackend) {
          $httpBackend.whenGET('queue.json').respond([
            {
              line: 136,
              label: 'sssssssss',
              time_in_queue: 265
            },
            {
              line: 133,
              label: 'zzzzz',
              time_in_queue: 73
            },
            {
              line: 133,
              label: 'zzzzz',
              time_in_queue: 73
            },
            {
              line: 133,
              label: 'zzzzz',
              time_in_queue: 73
            },
            {
              line: 133,
              label: 'zzzzz',
              time_in_queue: 73
            },
            {
              line: 133,
              label: 'zzzzz',
              time_in_queue: 73
            }
          ]);
        });
    });
    browser.get('#/queue');

    var queue = element.all(by.className('queuer'));
    expect(queue.count()).toBe(5);
    expect(browser.isElementPresent(by.className('plus-5'))).toBe(true);
  });
});

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
    element(by.linkText('Login')).click();

    element(by.model('login.username')).sendKeys('jooseppi');
    element(by.model('login.password')).sendKeys('oikee');
    element(by.buttonText('Login')).click();

    expect(browser.getLocationAbsUrl()).toMatch('/home');
  });

  it('should redirect back to protected route', function () {
    browser.get('#/home');
    element(by.linkText('Show statistics screen')).click();

    expect(browser.getLocationAbsUrl()).toMatch('/login');
    element(by.model('login.username')).sendKeys('jooseppi');
    element(by.model('login.password')).sendKeys('oikee');
    element(by.buttonText('Login')).click();

    expect(browser.getLocationAbsUrl()).toMatch('/stats');
  });
});
