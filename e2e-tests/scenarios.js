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
  beforeEach(function () {
    browser.addMockModule('httpBackendMock', function () {
      angular.module('httpBackendMock', ['ngMockE2E'])
        .run(function ($httpBackend) {
          $httpBackend.whenGET('agents.json').respond([
            {
              id: 1,
              agent_id: 1234,
              name: 'Kekkonen Benjamin',
              team: 'Helpdesk',
              status: 'Tauko',
              time_in_status: 6485
            },
            {
              id: 2,
              agent_id: 4321,
              name: 'Kanerva Aallotar',
              team: 'Helpdesk',
              status: 'Vapaa',
              time_in_status: 1278
            },
            {
              id: 10,
              agent_id: 8754,
              name: 'Tuomas Ansala',
              team: 'Helpdesk',
              status: 'Tauko',
              time_in_status: 543
            },
            {
              id: 6,
              agent_id: 666,
              name: 'Jenni Ahola',
              team: 'Helpdesk',
              status: 'Tauko',
              time_in_status: 343
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
  });

  it('should something', function () {
    var agentCards = element.all(by.className('agent-card'));

    expect(agentCards.count()).toBe(4);

    expect(agentCards.get(0).element(by.className('agent-name')).getText()).toBe('Kekkonen Benjamin');
    expect(agentCards.get(0).element(by.className('agent-status')).getText()).toBe('Tauko');

    expect(agentCards.get(1).element(by.className('agent-name')).getText()).toBe('Kanerva Aallotar');
    expect(agentCards.get(1).element(by.className('agent-status')).getText()).toBe('Vapaa');

    expect(agentCards.get(2).element(by.className('agent-name')).getText()).toBe('Tuomas Ansala');
    expect(agentCards.get(2).element(by.className('agent-status')).getText()).toBe('Tauko');

    expect(agentCards.get(3).element(by.className('agent-name')).getText()).toBe('Jenni Ahola');
    expect(agentCards.get(3).element(by.className('agent-status')).getText()).toBe('Tauko');
  });

  it('Status color should match status text', function () {
    var agentCards = element.all(by.className('agent-card'));

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
    var agentCards;
    element(by.linkText('rajaa')).click();
    element(by.id('Tauko')).click();
    element(by.linkText('Show state screen')).click();
    agentCards = element.all(by.className('agent-card'));
    expect(agentCards.count()).toBe(1);
    expect(agentCards.get(0).element(by.className('agent-name')).getText())
      .toBe('Kanerva Aallotar');
    expect(agentCards.get(0).element(by.className('agent-status')).getText())
      .toBe('Vapaa');
  });
});

describe('queue', function () {
  beforeEach(function () {
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
  });

  it('should something', function () {
    var queue = element.all(by.className('queuer'));

    expect(queue.count()).toBe(2);

    expect(queue.get(0).element(by.className('queuer-time')).getText()).toBe('04:25');
    expect(queue.get(0).isElementPresent(by.className('queuer-flag-Fin'))).toBe(true);

    expect(queue.get(1).element(by.className('queuer-time')).getText()).toBe('01:13');
    expect(queue.get(1).isElementPresent(by.className('queuer-flag-Swe'))).toBe(true);
  });
});
