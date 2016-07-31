describe('personal', function () {
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
              status: 'Vapaa',
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
              status: 'Puhelu',
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
              name: 'Vapaa',
              filter: true
            },
            {
              name: 'Puhelu',
              filter: true
            },
            {
              name: 'Tauko',
              filter: true
            }
          ]);
          $httpBackend.whenGET('queue.json').respond([
            {
              created_at: new Date(baseTime - (3 * 60 + 22) * 1000),
              team: 'Helpdesk',
              language: 'Finnish'
            }
          ]);
          $httpBackend.whenGET('personal.json').respond(
            {
              answered_calls: 7,
              average_call_duration: 476,
              average_after_call_duration: 182
            }
          );
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
            }
          };
        });
    });
    browser.addMockModule('ocWebGui.login', function () {
      angular.module('ocWebGui.login', [])
        .factory('User', function () {
          return {
            getUserData: function () {
              return { agent_id: 1234 };
            }
          };
        });
    });


    browser.get('#/personal');
  });

  it('should display queue length', function () {
    expect(element(by.className('queue-length')).getText()).toBe('1');
  });
  it('should display own call stats', function () {
    expect(element(by.id('answered-calls')).getText()).toBe('7');
    expect(element(by.id('avg-call-duration')).getText()).toBe('07:56');
    expect(element(by.id('avg-after-call')).getText()).toBe('03:02');
  });
  it('should display own status color', function () {
    var el = element(by.id('own-status-color'));
    expect(el.getAttribute('class')).toBe('agent-status-color agent-status-color-free');
    expect(el.getCssValue('background-color')).toBe('rgba(55, 200, 55, 1)');
  });
  it('should display active agents except the current with status colors', function () {
    var agents = element.all(by.id('agent-name'));
    expect(agents.count()).toBe(2);
    expect(agents.get(0).getText()).toBe('Aallotar K');
    expect(agents.get(1).getText()).toBe('Tuomas A');
  });
  it('should display status color for each agent in agents list', function () {
    var agents = element.all(by.id('agent-status-color'));

    expect(agents.get(0).getAttribute('class')).toBe('color-square agent-status-color-call');
    expect(agents.get(0).getCssValue('background-color')).toBe('rgba(255, 255, 77, 1)');

    expect(agents.get(1).getAttribute('class')).toBe('color-square agent-status-color-busy');
    expect(agents.get(1).getCssValue('background-color')).toBe('rgba(255, 51, 51, 1)');
  });
});
