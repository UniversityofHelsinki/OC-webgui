describe('queue', function () {
  describe('queue', function () {
    it('should show 2 queuers', function () {
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
              { team: 'Helpdesk', language: 'Finnish', time_in_queue: 71 },
              { team: 'Helpdesk', language: 'Swedish', time_in_queue: 34 }
            ]);
            $httpBackend.whenGET('settings.json').respond({
              colors: {
                background: "#87aade",
                font: "#333333",
                statuses: {
                  free: "#37c837",
                  call: "#ffff4d",
                  busy: "#ff3333"
                }
              }, others: {
                sla: 300,
                working_day_start: 8,
                working_day_end: 18
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

      browser.get('#/queue');

      var queue = element.all(by.className('queuer'));

      expect(queue.count()).toBe(2);

      expect(queue.get(0).element(by.className('queuer-time')).getText()).toBe('01:11');
      expect(queue.get(0).isElementPresent(by.className('queuer-flag-Finnish'))).toBe(true);
      expect(queue.get(1).element(by.className('queuer-time')).getText()).toBe('00:34');
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
              { team: 'Helpdesk', language: 'Finnish' },
              { team: 'Helpdesk', language: 'Swedish' },
              { team: 'Helpdesk', language: 'Finnish' },
              { team: 'Helpdesk', language: 'Finnish' },
              { team: 'Helpdesk', language: 'Finnish' }
            ]);
            $httpBackend.whenGET('settings.json').respond({
              colors: {
                background: "#87aade",
                font: "#333333",
                statuses: {
                  free: "#37c837",
                  call: "#ffff4d",
                  busy: "#ff3333"
                }
              }, others: {
                sla: 300,
                working_day_start: 8,
                working_day_end: 18
              }
            });
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
              { team: 'Helpdesk', language: 'Finnish' },
              { team: 'Helpdesk', language: 'Swedish' },
              { team: 'Helpdesk', language: 'English' },
              { team: 'Helpdesk', language: 'Finnish' },
              { team: 'Helpdesk', language: 'Finnish' },
              { team: 'Helpdesk', language: 'Finnish' }
            ]);
            $httpBackend.whenGET('settings.json').respond({
              colors: {
                background: "#87aade",
                font: "#333333",
                statuses: {
                  free: "#37c837",
                  call: "#ffff4d",
                  busy: "#ff3333"
                }
              }, others: {
                sla: 300,
                working_day_start: 8,
                working_day_end: 18
              }
            });
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
              answered_percentage: 100,
              average_after_call_duration: 60 + 5,
              average_queue_duration: 100,
              calls_by_hour: [
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
              ],
              average_queue_duration_by_hour: [
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
              ],
              service_level_agreement: 91
            });
            $httpBackend.whenGET('settings.json').respond({
              colors: {
                background: "#87aade",
                font: "#333333",
                statuses: {
                  free: "#37c837",
                  call: "#ffff4d",
                  busy: "#ff3333"
                }
              }, others: {
                sla: 300,
                working_day_start: 8,
                working_day_end: 18
              }
              queue_durations_by_times: [
                ['2016-07-18 05:00:00.000000000 +0000', 60.0],
                ['2016-07-18 08:00:00.000000000 +0000', 240.0],
                ['2016-07-18 09:00:00.000000000 +0000', 120.0]],
              missed_calls_by_hour: [
                0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 3, 4, 5, 6, 7, 11, 11, 11, 11, 11, 11, 11, 11
              ]
            });
          });
      });
      browser.get('#/queue');
      var statsTable = element.all(by.className('queue-stats-table'));
      rows = statsTable.all(by.tagName('tr'));
    });

    it('should contain 6 rows', function () {
      expect(rows.count()).toBe(6);
    });

    it('should contain answered calls', function () {
      expect(rows.get(0).element(by.tagName('td')).getText()).toBe('100%');
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

    it('should contain average queue waiting duration', function () {
      expect(rows.get(4).element(by.tagName('th')).getText()).toBe('Jonotusten ka:');
      expect(rows.get(4).element(by.tagName('td')).getText()).toBe('01:40');
    });

    it('should contain testtest', function () {
      expect(rows.get(5).element(by.tagName('th')).getText()).toBe('Palvelutaso:');
      expect(rows.get(5).element(by.tagName('td')).getText()).toBe('91%');
    });
  });
});
