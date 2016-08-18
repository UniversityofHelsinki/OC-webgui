describe('userAdmin', function () {
  beforeEach(function () {
    browser.addMockModule('httpBackendMock', function () {
      angular.module('httpBackendMock', ['ngMockE2E'])
        .run(function ($httpBackend) {
          $httpBackend.whenGET('agents.json').respond([
            {
              first_name: 'Etunimi',
              last_name: 'Sukunimi',
              id: 1,
              team_id: 2
            },
            {
              first_name: 'Jaska',
              last_name: 'Jokunen',
              id: 2,
              team_id: 1
            },
            {
              first_name: 'Aapeli',
              last_name: 'B',
              id: 3,
              team_id: 3
            }
          ]);
          $httpBackend.whenGET('users.json').respond([
            {
              id: 1,
              username: 'user1',
              is_admin: true,
              agent_id: 1
            },
            {
              id: 2,
              username: 'user2',
              is_admin: false,
              agent_id: null
            }
          ]);
          $httpBackend.whenPOST('users').respond(function (method, url, data) {
            return [200, { id: 3, username: 'user3', agent_id: 0 }];
          });
          $httpBackend.whenPOST('users/delete').respond(function (method, url, data) {
            return [200, { id: 1, username: 'user1', agent_id: 0 }];
          });
        });
    });
    browser.get('#/settings/users');
  });

  it('should list all current users', function () {
    var users = element.all(by.id('td-username'));
    expect(users.count()).toBe(2);
    expect(users.get(0).getText()).toBe('user1');
    expect(users.get(1).getText()).toBe('user2');
  });

  it('should allow adding users', function () {
    element(by.model('users.newUserUsername')).sendKeys('user3');
    element(by.model('users.newUserPassword')).sendKeys('abc123');
    element(by.model('users.newUserPasswordConfirmation')).sendKeys('abc123');
    element(by.buttonText('Luo käyttäjä')).click();

    var users = element.all(by.id('td-username'));
    expect(users.count()).toBe(3);
    expect(users.get(2).getText()).toBe('user3');
  });

  it('should allow deleting users', function () {
    element.all(by.buttonText('X')).get(0).click();
    browser.switchTo().alert().accept();
    expect(element.all(by.id('td-username')).count()).toBe(1);
  });

  it('should list users from OC ordered by team_id', function () {
    var parent = element(by.tagName('select'));
    var elements = parent.all(by.tagName('option'));

    expect(elements.get(0).getText()).toBe('Jaska Jokunen'); 
  });
});
