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
              created_at: new Date(baseTime - (10 * 60 + 15) * 1000).toISOString(),
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
              created_at: new Date(baseTime - 45 * 1000).toISOString(),
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
              created_at: new Date(baseTime - 30 * 1000).toISOString(),
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
              status: 'Chat',
              created_at: new Date(baseTime - (3600 + 1 * 60 + 5) * 1000).toISOString(),
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
          $httpBackend.whenGET('settings.json').respond({
            colors: {
              background: '#87aade',
              font: '#333333',
              statuses: {
                free: '#37c837',
                call: '#ffff4d',
                busy: '#ff3333'
              }
            }
          });
        });
    });

    browser.addMockModule('ocWebGui.shared.time.service', function () {
      angular.module('ocWebGui.shared.time.service', [])
        .factory('CustomDate', function () {
          return {
            getDate: function () {
              return new Date(2013, 9, 23, 12, 0);
            },

            niceFormatting: function (currentSeconds) {
              var pad2 = function (value) {
                return (value < 10 ? '0' : '') + value;
              };
              var seconds = Math.floor(currentSeconds % 60);
              var minutes = Math.floor(currentSeconds / 60);

              if (minutes > 60) {
                minutes = Math.floor(currentSeconds / 60 % 60);
                var hours = Math.floor(currentSeconds / 60 / 60);
                return pad2(hours) + ':' + pad2(minutes) + ':' + pad2(seconds);
              }

              return pad2(minutes) + ':' + pad2(seconds);
            }
          };
        });
    });

    browser.get('#/status');
    agentCards = element.all(by.className('agent-card'));
  });

  it('should have agent cards', function () {
    expect(agentCards.count()).toBe(4);
  });

  it('should have agent names', function () {
    expect(agentCards.get(0).element(by.className('agent-name')).getText()).toBe('Aallotar K');
    expect(agentCards.get(1).element(by.className('agent-name')).getText()).toBe('Benjamin K');
    expect(agentCards.get(2).element(by.className('agent-name')).getText()).toBe('Jenni A');
    expect(agentCards.get(3).element(by.className('agent-name')).getText()).toBe('Tuomas A');
  });

  it('should have agent statuses', function () {
    expect(agentCards.get(0).element(by.className('agent-status')).getInnerHtml()).toBe('Vapaa');
    expect(agentCards.get(1).element(by.className('agent-status')).getInnerHtml()).toBe('Tauko');
    expect(agentCards.get(2).element(by.className('agent-status')).getInnerHtml()).toBe('Chat');
    expect(agentCards.get(3).element(by.className('agent-status')).getInnerHtml()).toBe('Tauko');
  });

  it('should hide open status text', function() {
    expect(agentCards.get(0).element(by.className('agent-status-container')).getCssValue('visibility')).toBe('hidden');
    expect(agentCards.get(1).element(by.className('agent-status-container')).getCssValue('visibility')).not.toBe('hidden');
    expect(agentCards.get(2).element(by.className('agent-status-container')).getCssValue('visibility')).not.toBe('hidden');
    expect(agentCards.get(3).element(by.className('agent-status-container')).getCssValue('visibility')).not.toBe('hidden');
  });

  it('should have agent time in status', function () {
    expect(agentCards.get(0).element(by.className('status-timer')).getCssValue('visibility')).toBe('hidden');
    expect(agentCards.get(1).element(by.className('status-timer')).getText()).toBe('10:15');
    expect(agentCards.get(2).element(by.className('status-timer')).getText()).toBe('01:01:05');
    expect(agentCards.get(3).element(by.className('status-timer')).getText()).toBe('00:30');
  });

  it('Status color should match status text', function () {
    var el = agentCards.get(0).element(by.className('agent-status-color'));
    expect(el.getAttribute('class')).toMatch('agent-status-color-free');
    expect(el.getCssValue('background-color')).toBe('rgba(55, 200, 55, 1)');

    el = agentCards.get(1).element(by.className('agent-status-color'));
    expect(el.getAttribute('class')).toMatch('agent-status-color-busy');
    expect(el.getCssValue('background-color')).toBe('rgba(255, 51, 51, 1)');

    el = agentCards.get(2).element(by.className('agent-status-color'));
    expect(el.getAttribute('class')).toMatch('agent-status-color-busy');
    expect(el.getCssValue('background-color')).toBe('rgba(255, 51, 51, 1)');

    el = agentCards.get(3).element(by.className('agent-status-color'));
    expect(el.getAttribute('class')).toMatch('agent-status-color-busy');
    expect(el.getCssValue('background-color')).toBe('rgba(255, 51, 51, 1)');
  });

  it('Sidebar status view should be correct', function () {
    var statusCount = element.all(by.className('agent-status-count'));

    expect(statusCount.get(0).element(by.className('free-count')).getText()).toBe('1');
    expect(statusCount.get(1).element(by.className('call-count')).getText()).toBe('0');
    expect(statusCount.get(2).element(by.className('busy-count')).getText()).toBe('3');
  });

  it('should filter correctly', function () {
    browser.actions().mouseMove(element(by.className('navbar'))).perform();
    element(by.className('navbar')).element(by.linkText('Filtteröi')).click();

    element(by.name('state-Tauko')).click();
    var notification = element(by.className('alert'));
    expect(notification.getText()).toBe('Valintasi on tallennettu väliaikaisesti!');

    browser.actions().mouseMove(element(by.className('navbar'))).perform();
    element(by.className('navbar')).element(by.linkText('Statukset')).click();
    agentCards = element.all(by.className('agent-card'));
    expect(agentCards.count()).toBe(2);
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
