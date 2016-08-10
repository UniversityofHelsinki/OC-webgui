describe('userAdmin', function () {
  beforeEach(function () {
    browser.addMockModule('httpBackendMock', function () {
      angular.module('httpBackendMock', ['ngMockE2E'])
        .run(function ($httpBackend) {
          $httpBackend.whenGET('api/agents').respond([
            {
              first_name: 'Etunimi',
              last_name: 'Sukunimi',
              id: 1
            },
            {
              first_name: 'Jaska',
              last_name: 'Jokunen',
              id: 2
            },
            {
              first_name: 'Aapeli',
              last_name: 'B',
              id: 3
            }
          ]);
          $httpBackend.whenGET('api/users').respond([
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
    browser.get('#/userAdmin');
  });

  it('should list all current users', function () {
    var users = element.all(by.id('td-username'));
    expect(users.count()).toBe(2);
    expect(users.get(0).getText()).toBe('user1');
    expect(users.get(1).getText()).toBe('user2');
  });

  it('should allow adding users', function () {
    element(by.model('userAdmin.newUserUsername')).sendKeys('user3');
    element(by.model('userAdmin.newUserPassword')).sendKeys('abc123');
    element(by.model('userAdmin.newUserPasswordConfirmation')).sendKeys('abc123');
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
});
