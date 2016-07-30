angular.module('ocWebGui', ['templates', 'ocWebGui.home', 'ocWebGui.screen',
  'ocWebGui.queue', 'ocWebGui.filterpanel', 'ocWebGui.stats', 'ocWebGui.login',
  'ocWebGui.navbar', 'ocWebGui.personal', 'ocWebGui.color'])
  .run(function ($rootScope, $state, User, $interval) {
    var $body = $(document.body);
    var $navbar = $('.navbar');
    var mouseHideTimeout;

    $rootScope.settings = {
      colors: {
        background: '#87aade',
        font: '#333333',
        statuses: {
          free: '#37c837',
          call: '#ffff4d',
          busy: '#ff3333'
        }
      }
    };

    $rootScope.$watch('settings', function () {
      $body.css('background-color', $rootScope.settings.colors.background);
      $body.css('color', $rootScope.settings.colors.font);
    }, true);

    function createHideMouseTimeout() {
      return $interval(function () {
        $body.addClass('hide-mouse');
      }, 2000, 1);
    }

    function activateNavbarOverlay() {
      $interval.cancel(mouseHideTimeout);
      mouseHideTimeout = createHideMouseTimeout();

      $navbar.addClass('overlay');
      $body.on('mousemove', function () {
        $body.removeClass('hide-mouse');
        $interval.cancel(mouseHideTimeout);
        mouseHideTimeout = createHideMouseTimeout();
      });
    }

    function disableNavbarOverlay() {
      $interval.cancel(mouseHideTimeout);

      $navbar.removeClass('overlay');
      $body.removeClass('hide-mouse').off('mousemove');
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
