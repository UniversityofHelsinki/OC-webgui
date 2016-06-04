describe('ocTime', function() {
    var compile, scope, directiveElem, interval;

    beforeEach(function(){
        module('ocWebGui.shared.time');

        inject(function($compile, $rootScope, $interval) {
            compile = $compile;
            scope = $rootScope.$new();
            interval = $interval;
        });

        directiveElem = getCompiledElement();
    });

    function getCompiledElement() {
        scope.mySeconds = 123;
        var element = angular.element('<oc-time seconds="mySeconds" class="my-class"></oc-time>');
        var compiledElement = compile(element)(scope);
        scope.$digest();
        return compiledElement;
    }

    it('should render initial time', function() {
        expect(directiveElem.text()).toBe('02:03');
    });

    it('should have class', function() {
        expect(directiveElem.hasClass('my-class')).toBe(true);
    });

    it('should update time each seconds', function() {
        interval.flush(1000);
        expect(directiveElem.text()).toBe('02:04');
        interval.flush(1000);
        expect(directiveElem.text()).toBe('02:05');
    });

    it('should update time', function() {
        scope.mySeconds = 200;
        scope.$digest();
        expect(directiveElem.text()).toBe('03:20');
    });
});
