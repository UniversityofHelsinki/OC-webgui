describe('ocTime', function () {
  var compile;
  var scope;
  var interval;

  beforeEach(function () {
    module('ocWebGui.shared.time');

    // mokki
    module(function($provide) {
      $provide.service('CustomDate', function () {
        return {
          getDate: function () {
            return new Date(2016, 7, 7, 10, 2, 3);
          }
        };
      });
    });

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

  function getCompiledElementForDateObject() {
    var element = angular.element(
      '<oc-time dateobj="myDate" class="my-class"></oc-time>'
    );
    var compiledElement = compile(element)(scope);
    scope.$digest();
    return compiledElement;
  }

  describe('with date object', function () {
    var directiveElem;

    beforeEach(function () {
      // 10:00:00 7.7.2016
      // aika milloin "aloitettu"
      scope.myDate = new Date(2016, 7, 7, 10, 0, 0);
      scope.myUpdate = true;
      directiveElem = getCompiledElementForDateObject();
    });

    it('should have class', function () {
      expect(directiveElem.hasClass('my-class')).toBe(true);
    });

    it('should render initial time', function () {
      expect(directiveElem.text()).toBe('02:03');
    });

    it('should update time', function () {
      // tähän joku millä saa kasvatettua nykyistä aikaa
      // mikä mokataan ihan alussa
      expect(directiveElem.text()).toBe('03:20');
    });

    it('should update time each seconds', function () {
      interval.flush(1000);
      expect(directiveElem.text()).toBe('02:04');
      interval.flush(1000);
      expect(directiveElem.text()).toBe('02:05');
    });
  });

  describe('without update (use seconds)', function () {
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
