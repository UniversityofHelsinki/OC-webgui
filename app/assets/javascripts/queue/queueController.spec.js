angular.module('templates', []);

describe('QueueController', function () {
  var $controller;
  var $rootScope;

  beforeEach(function () {
    module('ocWebGui.queue');

    inject(function (_$controller_, _$rootScope_) {
      $controller = _$controller_;
      $rootScope = _$rootScope_;
    });
  });

  it('should have correct message', function () {
    var scope = $rootScope.$new();
    var ctrl = $controller('QueueController', { $scope: scope });
    expect(ctrl.message).toBe('Jono');
  });

  it('should have queue data', function () {
    var scope = $rootScope.$new();
    var ctrl = $controller('QueueController', { $scope: scope });
    expect(ctrl.queue.length).toBe(0);
  });
});
