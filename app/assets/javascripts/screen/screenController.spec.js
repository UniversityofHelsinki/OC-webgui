angular.module("templates", []);

describe('ScreenController', function() {
    beforeEach(module('ocWebGui'));
    it('should have correct message', inject(function($controller) {
        var scope = {};
        var ctrl = $controller('ScreenController', {$scope: scope});
        expect(scope.message).toBe('Tilat');
    }));

    it('should have agents\' states', inject(function($controller) {
        var scope = {};
        var ctrl = $controller('ScreenController', {$scope: scope});
        expect(scope.agents).not.toBe(null);
    }));

});
