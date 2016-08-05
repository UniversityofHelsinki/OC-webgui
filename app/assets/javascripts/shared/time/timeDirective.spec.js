describe('ocTime', function () {
  var compile;
  var scope;
  var interval;
  var currentDate = new Date(2016, 7, 7, 10, 2, 3);

  beforeEach(function () {
    module('ocWebGui.shared.time');

    module(function ($provide) {
      $provide.service('CustomDate', function () {
        return {
          getDate: function () {
            return currentDate;
          },

          pad2: function (value) {
            return (value < 10 ? '0' : '') + value;
          },

          secondsToHoursMinutesSeconds: function (currentSeconds) {
            var seconds = currentSeconds % 60;
            var minutes = Math.floor(currentSeconds / 60);

            if (minutes >= 60) {
              minutes = Math.floor(currentSeconds / 60 % 60);
              var hours = Math.floor(currentSeconds / 60 / 60);
              return pad2(hours) + ':' + pad2(minutes) + ':' + pad2(seconds);
            }

            return pad2(minutes) + ':' + pad2(seconds);
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
      '<oc-time seconds="mySeconds" class="my-class"></oc-time>'
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
      scope.myDate = new Date(2016, 7, 7, 10, 0, 0);
      directiveElem = getCompiledElementForDateObject();
    });

    it('should have class', function () {
      expect(directiveElem.hasClass('my-class')).toBe(true);
    });

    it('should render initial time', function () {
      expect(directiveElem.text()).toBe('02:03');
    });

    it('should update time', function () {
      scope.myDate = new Date(2016, 7, 7, 9, 58, 43);
      scope.$digest();
      expect(directiveElem.text()).toBe('03:20');
    });

    it('should display hours if necessary', function () {
      scope.myDate = new Date(2016, 7, 7, 7, 58, 43);
      scope.$digest();
      expect(directiveElem.text()).toBe('02:03:20');
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

    it('should display hours if necessary', function () {
      scope.mySeconds = 3777;
      scope.$digest();
      expect(directiveElem.text()).toBe('01:02:57');
    });
  });
});
