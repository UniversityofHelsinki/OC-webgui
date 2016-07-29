describe ('personal', function() {
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
              return { agent_id: 1234 }
            }
          };
        });
    });


    browser.get('#/personal');
  });

  it('should display queue length', function () {
    expect(element(by.className('queue-length')).getText()).toBe('1');
  });
  it('should display own call stats', function() {
    expect(element(by.className('answeredCalls')).getText()).toBe('7');
    expect(element(by.className('avgCallDuration')).getText()).toBe("07:56");
    expect(element(by.className('avgAfterCall')).getText()).toBe("03:02");
  });
  it('should display own status', function () {
    expect(element(by.className('ownStatus')).getText()).toBe('Vapaa');
  });
  it('should display active agents', function () {
    agents = element.all(by.className('agentName'));
    expect(agents.count()).toBe(2);
    expect(agents.get(0).getText()).toBe('Benjamin');
    expect(agents.get(1).getText()).toBe('Aallotar');
  });
});
