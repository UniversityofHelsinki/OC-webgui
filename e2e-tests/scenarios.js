describe('homepage', function() {
    it('should automatically redirect to /home', function() {
        browser.get('');
        expect(browser.getLocationAbsUrl()).toMatch('/home');
    });
    it('should contain header', function() {
        browser.get('#/home');
        expect(element(by.tagName('h1')).getText()).toBe('Home');
    });
});

describe('screen', function() {
    beforeEach(function() {
        browser.addMockModule('httpBackendMock', function() {
            angular.module('httpBackendMock', ['ngMockE2E'])
                .run(function($httpBackend) {
                    $httpBackend.whenGET('agents.json').respond([
                        {
                            id: 1,
                            agent_id: 1234,
                            name: 'Kekkonen Benjamin',
                            team: 'Helpdesk',
                            status: 'PALAVERI',
                            time_in_status: 6485
                        },
                        {
                            id: 2,
                            agent_id: 4321,
                            name: 'Kanerva Aallotar',
                            team: 'Helpdesk',
                            status: 'Sisäänkirjaus',
                            time_in_status: 1278
                        }
                    ]);
                });
        });
    });

    it('should something', function() {
        browser.get('#/screen');
        var agents = element.all(by.tagName('div'));
        expect(agents.count()).toBe(2);
        expect(agents.get(0).getText()).toBe('Kekkonen Benjamin: PALAVERI');
        expect(agents.get(1).getText()).toBe('Kanerva Aallotar: Sisäänkirjaus');
    });
});
