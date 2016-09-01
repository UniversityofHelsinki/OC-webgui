describe('queue', function () {
  describe('queue', function () {
    it('should show 2 queuers', function () {
      browser.addMockModule('httpBackendMock', function () {
        angular.module('httpBackendMock', ['ngMockE2E'])
          .run(function ($httpBackend) {
            var baseTime = new Date(2013, 9, 23, 12, 0).getTime();
            $httpBackend.whenGET('api/teams').respond([
              {
                name: "Helpdesk",
                filter: true
              }
            ]);
            $httpBackend.whenGET('api/queue').respond([
              {
                id: 2,
                team: 'Helpdesk',
                language: 'Swedish',
                created_at: new Date(baseTime - 73 * 1000).toISOString()
              },
              {
                id: 1,
                team: 'Helpdesk',
                language: 'Finnish',
                created_at: new Date(baseTime - (4 * 60 + 25) * 1000).toISOString()
              }
            ]);
            $httpBackend.whenGET('api/settings').respond({
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
                working_day_end: 18,
                animated: false
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
            $httpBackend.whenGET('api/teams').respond([
              {
                name: "Helpdesk",
                filter: true
              }
            ]);
            $httpBackend.whenGET('api/queue').respond([
              { id: 1, team: 'Helpdesk', language: 'Finnish', created_at: new Date().toISOString() },
              { id: 2, team: 'Helpdesk', language: 'Swedish', created_at: new Date().toISOString() },
              { id: 3, team: 'Helpdesk', language: 'Finnish', created_at: new Date().toISOString() },
              { id: 4, team: 'Helpdesk', language: 'Finnish', created_at: new Date().toISOString() },
              { id: 5, team: 'Helpdesk', language: 'Finnish', created_at: new Date().toISOString() }
            ]);
            $httpBackend.whenGET('api/settings').respond({
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
                working_day_end: 18,
                animated: false
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
            $httpBackend.whenGET('api/teams').respond([
              {
                name: "Helpdesk",
                filter: true
              }
            ]);
            $httpBackend.whenGET('api/queue').respond([
              { id: 1, team: 'Helpdesk', language: 'Finnish', created_at: new Date().toISOString() },
              { id: 2, team: 'Helpdesk', language: 'Swedish', created_at: new Date().toISOString() },
              { id: 3, team: 'Helpdesk', language: 'English', created_at: new Date().toISOString() },
              { id: 4, team: 'Helpdesk', language: 'Finnish', created_at: new Date().toISOString() },
              { id: 5, team: 'Helpdesk', language: 'Finnish', created_at: new Date().toISOString() },
              { id: 6, team: 'Helpdesk', language: 'Finnish', created_at: new Date().toISOString() }
            ]);
            $httpBackend.whenGET('api/settings').respond({
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
                working_day_end: 18,
                animated: false
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
    beforeEach(function () {
      browser.addMockModule('httpBackendMock', function () {
        angular.module('httpBackendMock', ['ngMockE2E'])
          .run(function ($httpBackend) {
            $httpBackend.whenGET('api/contacts/stats').respond({
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
              service_level_agreement: 91,
              queue_durations_by_times: [
                ['2016-07-18 05:00:00.000000000 +0000', 60.0],
                ['2016-07-18 08:00:00.000000000 +0000', 240.0],
                ['2016-07-18 09:00:00.000000000 +0000', 120.0]],
              missed_calls_by_hour: [
                0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 3, 4, 5, 6, 7, 11, 11, 11, 11, 11, 11, 11, 11
              ]
            });
            $httpBackend.whenGET('api/settings').respond({
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
                working_day_end: 18,
                animated: false
              }
            });
          });
      });
      browser.get('#/queue');
    });

    it('should contain correct data', function () {
      var stats = element.all(by.css('.queue-stats > div')).map(function (row) {
        return row.all(by.tagName('div')).map(function (column) {
          return column.getText();
        });
      });
      expect(stats).toEqual([
        ['Vastausprosentti:', '100%'],
        ['Puhelut:', '11 / 11'],
        ['Puheluiden ka:', '02:15'],
        ['Jälkikirjausten ka:', '01:05'],
        ['Jonotusten ka:', '01:40'],
        ['Palvelutaso:', '91% (05:00)']
      ]);
    });
  });
});
