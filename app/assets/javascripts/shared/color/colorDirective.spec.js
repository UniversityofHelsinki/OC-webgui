describe('ocColor', function () {
  var compile;
  var scope;

  beforeEach(function () {
    module('ocWebGui.shared.color');
    module('ocWebGui.shared.settings');

    inject(function ($compile, $rootScope) {
      compile = $compile;
      scope = $rootScope.$new();
    });
  });

  function compileElement(template) {
    var element = angular.element(template);
    var compiledElement = compile(element)(scope);
    scope.$digest();
    return compiledElement;
  }

  it('changes background color', function () {
    var el = compileElement('<div oc-color="background"></div>');
    expect(el.css('background-color')).toBe('rgb(135, 170, 222)');
  });

  it('supports nested values', function () {
    var el = compileElement('<div oc-color="statuses.free"></div>');
    expect(el.css('background-color')).toBe('rgb(55, 200, 55)');
  });

  it('supports dynamic colors', function () {
    scope.myColor = 'background';
    var el = compileElement('<div oc-color="{{ myColor }}"></div>');
    expect(el.css('background-color')).toBe('rgb(135, 170, 222)');
  });

  it('supports nested dynamic colors', function () {
    scope.type = 'free';
    var el = compileElement('<div oc-color="statuses.{{ type }}"></div>');
    expect(el.css('background-color')).toBe('rgb(55, 200, 55)');
  });

  it('reacts to changes', function () {
    scope.myColor = 'background';
    var el = compileElement('<div oc-color="{{ myColor }}"></div>');
    expect(el.css('background-color')).toBe('rgb(135, 170, 222)');

    scope.myColor = 'statuses.free';
    scope.$digest();
    expect(el.css('background-color')).toBe('rgb(55, 200, 55)');
  });

  it('reacts to changes when nested', function () {
    scope.myColor = 'free';
    var el = compileElement('<div oc-color="statuses.{{ myColor }}"></div>');
    expect(el.css('background-color')).toBe('rgb(55, 200, 55)');

    scope.myColor = 'busy';
    scope.$digest();
    expect(el.css('background-color')).toBe('rgb(255, 51, 51)');
  });
});
