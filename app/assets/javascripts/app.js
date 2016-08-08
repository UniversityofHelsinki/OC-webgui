angular.module('ocWebGui', ['templates', 'ocWebGui.home', 'ocWebGui.screen', 'ocWebGui.queue',
    'ocWebGui.filterpanel', 'ocWebGui.stats', 'ocWebGui.login', 'ocWebGui.navbar',
    'ocWebGui.personal', 'ocWebGui.color', 'ocWebGui.shared.color', 'ocWebGui.shared.settings',
    'ocWebGui.userAdmin'])
  .run(function ($rootScope, $state, User, $interval, Settings) {
    var $body = $(document.body);
    var $navbar = $('.navbar');
    var $queue = $('.answer');
    var $personal = $('.personal-statistics');
    var mouseHideTimeout;

    $rootScope.$on('settings:colors:update', function () {
      Settings.getColor('font').then(function (color) {
        $body.css('color', color);
        $queue.css('border-bottom-color', color); //TODO: Testaa tämä osa koodista että homma toimii kunnolla!!!
        $personal.css('border-bottom-color', color); //TODO: Testaa tämä osa koodista että homma toimii kunnolla!!!
      });
    });

    function createHideMouseTimeout() {
      return $interval(function () {
        $body.addClass('hide-mouse');
      }, 2000, 1);
    }

    function activateNavbarOverlay() {
      $interval.cancel(mouseHideTimeout);
      mouseHideTimeout = createHideMouseTimeout();
      $body.addClass('body-screen');

      $body.on('mousemove', function () {
        $body.removeClass('hide-mouse');
        $interval.cancel(mouseHideTimeout);
        mouseHideTimeout = createHideMouseTimeout();
      });
    }

    function disableNavbarOverlay() {
      $interval.cancel(mouseHideTimeout);

      $body.removeClass('hide-mouse').off('mousemove');
      $body.removeClass('body-screen');
    }

    $rootScope.returnToState = 'home';
    $rootScope.returnToParams = {};

    $rootScope.$on('$stateChangeStart', function (event, toState, toParams, fromState, fromParams) {
      if (toState.navbarOverlay === true) {
        activateNavbarOverlay();
      } else {
        disableNavbarOverlay();
      }

      if (toState.name === 'stats' && !User.isAuthenticated()) {
        $rootScope.returnToState = toState;
        $rootScope.returnToParams = toParams;
        event.preventDefault();
        $state.go('login');
      }
    });
  });
