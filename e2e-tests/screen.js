describe('screen', function () {
  var agentCards;

  beforeEach(function () {
    browser.addMockModule('httpBackendMock', function () {
      angular.module('httpBackendMock', ['ngMockE2E'])
        .run(function ($httpBackend) {
          var baseTime = new Date(2013, 9, 23, 12, 0).getTime();
          $httpBackend.whenGET('agent_statuses.json').respond([
            {
              id: 1234,
              first_name: 'Benjamin',
              last_name: 'Kekkonen',
              status: 'Tauko',
              created_at: new Date(baseTime - (10 * 60 + 15) * 1000),
              lunch: false,
              team: {
                id: 1,
                name: 'Helpdesk'
              }
            },
            {
              id: 4321,
              first_name: 'Aallotar',
              last_name: 'Kanerva',
              status: 'Vapaa',
              created_at: new Date(baseTime - 45 * 1000),
              lunch: true,
              team: {
                id: 1,
                name: 'Helpdesk'
              }
            },
            {
              id: 8754,
              first_name: 'Tuomas',
              last_name: 'Ansala',
              status: 'Tauko',
              created_at: new Date(baseTime - 30 * 1000),
              lunch: false,
              team: {
                id: 1,
                name: 'Helpdesk'
              }
            },
            {
              id: 666,
              first_name: 'Jenni',
              last_name: 'Ahola',
              status: 'Tauko',
              created_at: new Date(baseTime - (1 * 60 + 5) * 1000),
              lunch: false,
              team: {
                id: 1,
                name: 'Helpdesk'
              }
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

    browser.addMockModule('ocWebGui.shared.time.service', function () {
      angular.module('ocWebGui.shared.time.service', [])
        .factory('CustomDate', function () {
          return {
            getDate: function () {
              return new Date(2013, 9, 23, 12, 0);
            }
          };
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
    expect(agentCards.get(0).element(by.className('status-timer')).getText()).toBe('10:15');
    expect(agentCards.get(1).element(by.className('status-timer')).getCssValue('visibility')).toBe('hidden');
    expect(agentCards.get(2).element(by.className('status-timer')).getText()).toBe('00:30');
    expect(agentCards.get(3).element(by.className('status-timer')).getText()).toBe('01:05');
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
    browser.actions().mouseMove(element(by.className('navbar'))).perform();
    element(by.className('navbar')).element(by.linkText('Filtteröi')).click();
    element(by.id('Tauko')).click();
    browser.actions().mouseMove(element(by.className('navbar'))).perform();
    element(by.className('navbar')).element(by.linkText('Status Screen')).click();
    agentCards = element.all(by.className('agent-card'));
    expect(agentCards.count()).toBe(1);
    expect(agentCards.get(0).element(by.className('agent-name')).getText())
      .toBe('Aallotar K');
  });

  it('should show who has had lunch', function() {
    agentCards = element.all(by.className('lunch'));
    expect(agentCards.count()).toBe(1);
    expect(agentCards.get(0).element(by.className('agent-name')).getText())
      .toBe('Aallotar K');
  });
});
