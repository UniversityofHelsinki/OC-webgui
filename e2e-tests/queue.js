describe('queue', function () {
  describe('queue', function () {
    jasmine.clock().install();
    var baseTime = new Date(2013, 9, 23);
    jasmine.clock().mockDate(baseTime);

    it('should show 2 queuers', function () {
      browser.addMockModule('httpBackendMock', function () {
        angular.module('httpBackendMock', ['ngMockE2E'])
          .run(function ($httpBackend) {
            $httpBackend.whenGET('queue.json').respond([
              {
                line: 136,
                label: 'sssssssss',
                created_at: Date.now() - (4 * 60 + 25) * 1000
              },
              {
                line: 133,
                label: 'zzzzz',
                created_at: Date.now() - 73 * 1000
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
              ]
            });
          });
      });
      browser.get('#/queue');
      var statsTable = element.all(by.className('stats-table'));
      rows = statsTable.all(by.tagName('tr'));
    });

    it('should contain 3 rows', function () {
      expect(rows.count()).toBe(3);
    });

    it('should contain answered calls', function () {
      expect(rows.get(0).element(by.tagName('th')).getText()).toBe('Puhelut:');
      expect(rows.get(0).element(by.tagName('td')).getText()).toBe('11');
    });

    it('should contain average call duration', function () {
      expect(rows.get(1).element(by.tagName('th')).getText()).toBe('Puhelun ka:');
      expect(rows.get(1).element(by.tagName('td')).getText()).toBe('02:15');
    });

    it('should contain average call duration', function () {
      expect(rows.get(2).element(by.tagName('th')).getText()).toBe('Jälkikirjauksen ka:');
      expect(rows.get(2).element(by.tagName('td')).getText()).toBe('01:05');
    });

    jasmine.clock().uninstall();
  });
});
