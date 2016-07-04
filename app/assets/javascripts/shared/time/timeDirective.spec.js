describe('ocTime', function () {
  var compile;
  var scope;
  var interval;

  beforeEach(function () {
    module('ocWebGui.shared.time');

    inject(function ($compile, $rootScope, $interval) {
      compile = $compile;
      scope = $rootScope.$new();
      interval = $interval;
    });
  });

  function getCompiledElement() {
    var element = angular.element(
      '<oc-time seconds="mySeconds" class="my-class" update="myUpdate"></oc-time>'
    );
    var compiledElement = compile(element)(scope);
    scope.$digest();
    return compiledElement;
  }

  describe('with update', function () {
    var directiveElem;

    beforeEach(function () {
      scope.mySeconds = 123;
      scope.myUpdate = true;
      directiveElem = getCompiledElement();
    });

    it('should have class', function () {
      expect(directiveElem.hasClass('my-class')).toBe(true);
    });

    it('should render initial time', function () {
      expect(directiveElem.text()).toBe('02:03');
    });

    it('should update time', function () {
      scope.mySeconds = 200;
      scope.$digest();
      expect(directiveElem.text()).toBe('03:20');
    });

    it('should update time each seconds', function () {
      interval.flush(1000);
      expect(directiveElem.text()).toBe('02:04');
      interval.flush(1000);
      expect(directiveElem.text()).toBe('02:05');
    });
  });

  describe('without update', function () {
    var directiveElem;

    beforeEach(function () {
      scope.mySeconds = 123;
      scope.myUpdate = false;
      directiveElem = getCompiledElement();
    });

    it('should have class', function () {
      expect(directiveElem.hasClass('my-class')).toBe(true);
    });

    it('should render initial time', function () {
      expect(directiveElem.text()).toBe('02:03');
    });

    it('should update time', function () {
      scope.mySeconds = 200;
      scope.$digest();
      expect(directiveElem.text()).toBe('03:20');
    });

    it('should not update time automatically', function () {
      interval.flush(5000);
      expect(directiveElem.text()).toBe('02:03');
    });
  });
});
