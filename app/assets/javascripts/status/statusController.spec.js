angular.module('templates', []);

describe('StatusController', function () {
  var $controller;
  var $rootScope;

  beforeEach(function () {
    module('ocWebGui.status');

    inject(function (_$controller_, _$rootScope_) {
      $controller = _$controller_;
      $rootScope = _$rootScope_;
    });
  });

  it('should have correct message', function () {
    var scope = $rootScope.$new();
    var ctrl = $controller('StatusController', { $scope: scope });
    expect(ctrl.message).toBe('Tilat');
  });

  it('should have status\' states', function () {
    var scope = $rootScope.$new();
    var ctrl = $controller('StatusController', { $scope: scope });
    expect(ctrl.status.length).toBe(0);
  });
});
