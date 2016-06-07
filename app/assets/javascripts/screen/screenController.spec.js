angular.module("templates", []);

describe('ScreenController', function() {
    var $controller, $rootScope;

    beforeEach(function() {
        module('ocWebGui.screen');

        inject(function(_$controller_, _$rootScope_) {
            $controller = _$controller_;
            $rootScope = _$rootScope_;
        });
    });

    it('should have correct message', function() {
        var scope = $rootScope.$new();
        var ctrl = $controller('ScreenController', {$scope: scope});
        expect(scope.message).toBe('Tilat');
    });

    it('should have agents\' states', function() {
        var scope = $rootScope.$new();
        var ctrl = $controller('ScreenController', {$scope: scope});
        expect(scope.agents.length).toBe(0);
    });
});
