angular.module('templates', []);

describe('AgentsController', function () {
  var $controller;
  var $rootScope;

  beforeEach(function () {
    module('ocWebGui.agents');

    inject(function (_$controller_, _$rootScope_) {
      $controller = _$controller_;
      $rootScope = _$rootScope_;
    });
  });

  it('should have correct message', function () {
    var scope = $rootScope.$new();
    var ctrl = $controller('AgentsController', { $scope: scope });
    expect(ctrl.message).toBe('Tilat');
  });

  it('should have agents\' states', function () {
    var scope = $rootScope.$new();
    var ctrl = $controller('AgentsController', { $scope: scope });
    expect(ctrl.agents.length).toBe(0);
  });
});
