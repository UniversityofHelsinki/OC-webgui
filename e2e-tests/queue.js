describe('queue', function () {
  describe('queue', function () {
    it('should show 2 queuers', function () {
      browser.addMockModule('httpBackendMock', function () {
        angular.module('httpBackendMock', ['ngMockE2E'])
          .run(function ($httpBackend) {
            var baseTime = new Date(2013, 9, 23, 12, 0).getTime();
            $httpBackend.whenGET('teams.json').respond([
              {
                name: "Helpdesk",
                filter: true
              }
            ]);
            $httpBackend.whenGET('queue.json').respond([
              { team: 'Helpdesk', language: 'Finnish', created_at: new Date(baseTime - (4 * 60 + 25) * 1000) },
              { team: 'Helpdesk', language: 'Swedish', created_at: new Date(baseTime - 73 * 1000) }
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

      browser.get('#/queue');

      var queue = element.all(by.className('queuer'));

      expect(queue.count()).toBe(2);

      expect(queue.get(0).element(by.className('queuer-time')).getText()).toBe('04:25');
      expect(queue.get(0).isElementPresent(by.className('queuer-flag-Finnish'))).toBe(true);
      expect(queue.get(1).element(by.className('queuer-time')).getText()).toBe('01:13');
      expect(queue.get(1).isElementPresent(by.className('queuer-flag-Swedish'))).toBe(true);

      expect(browser.isElementPresent(by.className('plus-5'))).toBe(false);
    });

    it('should not show indicator with 5 queuers', function () {
      browser.addMockModule('httpBackendMock', function () {
        angular.module('httpBackendMock', ['ngMockE2E'])
          .run(function ($httpBackend) {
            $httpBackend.whenGET('teams.json').respond([
              {
                name: "Helpdesk",
                filter: true
              }
            ]);
            $httpBackend.whenGET('queue.json').respond([
              { team: 'Helpdesk', language: 'Finnish', created_at: new Date() },
              { team: 'Helpdesk', language: 'Swedish', created_at: new Date() },
              { team: 'Helpdesk', language: 'Finnish', created_at: new Date() },
              { team: 'Helpdesk', language: 'Finnish', created_at: new Date() },
              { team: 'Helpdesk', language: 'Finnish', created_at: new Date() }
            ]);
          });
      });
      browser.get('#/queue');

      var queue = element.all(by.className('queuer'));
      expect(queue.count()).toBe(5);
      expect(browser.isElementPresent(by.className('plus-5'))).toBe(false);
    });

    it('should show only 5 queuers and indicator of more', function () {
      browser.addMockModule('httpBackendMock', function () {
        angular.module('httpBackendMock', ['ngMockE2E'])
          .run(function ($httpBackend) {
            $httpBackend.whenGET('teams.json').respond([
              {
                name: "Helpdesk",
                filter: true
              }
            ]);
            $httpBackend.whenGET('queue.json').respond([
              { team: 'Helpdesk', language: 'Finnish', created_at: new Date() },
              { team: 'Helpdesk', language: 'Swedish', created_at: new Date() },
              { team: 'Helpdesk', language: 'English', created_at: new Date() },
              { team: 'Helpdesk', language: 'Finnish', created_at: new Date() },
              { team: 'Helpdesk', language: 'Finnish', created_at: new Date() },
              { team: 'Helpdesk', language: 'Finnish', created_at: new Date() }
            ]);
          });
      });
      browser.get('#/queue');

      var queue = element.all(by.className('queuer'));
      expect(queue.count()).toBe(5);
      expect(browser.isElementPresent(by.className('plus-5'))).toBe(true);
    });
  });

  describe('stats', function () {
    var rows;

    beforeEach(function () {
      browser.addMockModule('httpBackendMock', function () {
        angular.module('httpBackendMock', ['ngMockE2E'])
          .run(function ($httpBackend) {
            $httpBackend.whenGET('contacts/stats.json').respond({
              answered_calls: 11,
              average_call_duration: 2 * 60 + 15,
              average_after_call_duration: 60 + 5,
              calls_by_hour: [
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
              ],
              average_queue_duration_by_hour: [
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
              ]
            });

            $httpBackend.whenGET('queue/stats.json').respond({
              average_waiting_time: 100,
              queue_items_by_hour: [
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
              ]
            });
          });
      });
      browser.get('#/queue');
      var statsTable = element.all(by.className('queue-stats-table'));
      rows = statsTable.all(by.tagName('tr'));
    });

    it('should contain 5 rows', function () {
      expect(rows.count()).toBe(5);
    });

    it('should contain answered calls', function () {
      expect(rows.get(0).element(by.tagName('th')).getText()).toBe('%');
    });

    it('should contain calls (answered / all)', function() {
      expect(rows.get(1).element(by.tagName('th')).getText()).toBe('Puhelut:');
      expect(rows.get(1).element(by.tagName('td')).getText()).toBe('11 / 11');
    });
    
    it('should contain average call duration', function () {
      expect(rows.get(2).element(by.tagName('th')).getText()).toBe('Puheluiden ka:');
      expect(rows.get(2).element(by.tagName('td')).getText()).toBe('02:15');
    });

    it('should contain average call duration', function () {
      expect(rows.get(3).element(by.tagName('th')).getText()).toBe('Jälkikirjausten ka:');
      expect(rows.get(3).element(by.tagName('td')).getText()).toBe('01:05');
    });

// Testi sekoaa siitä, että yksi elementeistä ei näy pienellä resoluutiolla näytöllä.
    it('should contain average queue waiting duration', function () {
      expect(rows.get(4).element(by.tagName('th')).getText()).toBe('Jonotusten ka:');
    });    
  });
});
