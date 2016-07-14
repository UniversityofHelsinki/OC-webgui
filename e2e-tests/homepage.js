describe('homepage', function () {
  it('should automatically redirect to /home', function () {
    browser.get('');
    expect(browser.getLocationAbsUrl()).toMatch('/home');
  });
  it('should contain header', function () {
    browser.get('#/home');
    expect(element(by.tagName('h1')).getText()).toBe('Home');

  });
});
