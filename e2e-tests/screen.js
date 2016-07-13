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
              created_at: Date.now() - (10 * 60 + 15) * 1000
            },
            {
              id: 2,
              agent_id: 4321,
              name: 'Kanerva Aallotar',
              team: 'Helpdesk',
              status: 'Vapaa',
              created_at: Date.now() - 45 * 1000
            },
            {
              id: 10,
              agent_id: 8754,
              name: 'Ansala Tuomas',
              team: 'Helpdesk',
              status: 'Tauko',
              created_at: Date.now() - 30 * 1000
            },
            {
              id: 6,
              agent_id: 666,
              name: 'Ahola Jenni',
              team: 'Helpdesk',
              status: 'Tauko',
              created_at: Date.now() - (1 * 60 + 5) * 1000
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
    element(by.className('navbar')).element(by.linkText('Show filter screen')).click();
    element(by.id('Tauko')).click();
    browser.actions().mouseMove(element(by.className('navbar'))).perform();
    element(by.className('navbar')).element(by.linkText('Show state screen')).click();
    agentCards = element.all(by.className('agent-card'));
    expect(agentCards.count()).toBe(1);
    expect(agentCards.get(0).element(by.className('agent-name')).getText())
      .toBe('Aallotar K');
  });
});
