angular.module("templates", []);

describe('ScreenController', function() {
    beforeEach(module('ocWebGui'));
    it('should have correct message', inject(function($controller) {
        var scope = {};
        var ctrl = $controller('ScreenController', {$scope: scope});
        expect(scope.message).toBe('Hei maailma!');
    }));
});
