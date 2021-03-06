angular.module('ocWebGui.screens.queue', ['ocWebGui.screens.queue.service', 'ui.router',
    'ocWebGui.shared.time', 'ocWebGui.shared.chart.service', 'ocWebGui.stats.today.service',
    'nvd3'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('app.queue', {
        url: '/queue',
        views: {
          nav: {
            templateUrl: 'navbar/navbar_screen.html'
          },
          content: {
            templateUrl: 'screens/queue/_queue.html',
            controller: 'QueueController',
            controllerAs: 'queue'
          }
        },
        navbarOverlay: true
      });
  })
  .controller('QueueController', function ($q, $interval, $scope, $http, Queue, Chart, Stats, Settings) {
    var vm = this;
    vm.api = {
      sla: 150
    };
    vm.sla_time = 0;

    Settings.getOthers().then(function (others) {
      vm.sla_time = others.sla;
      vm.animated = others.animated;
    });

    vm.options = Chart.queueChart;
    vm.data = [{
      'bar': true,
      'color': '#888888',
      'values': []
    }, {
      'color': '#ff0000',
      'values': []
    }];

    function fetchContactStats() {
      Stats.query().then(function (values) {
        vm.otherSettings = values.otherSettings;

        var data = values.response.data;
        var callsValues = Chart.mapAndFilter(data.calls_by_hour, vm.otherSettings);
        var queueValues = Chart.mapAndFilter(data.average_queue_duration_by_hour, vm.otherSettings);

        vm.stats = data;
        vm.data[0].values = callsValues;
        vm.data[1].values = queueValues;
        var callMax = Chart.getMaxValPlusOne(vm.data[0]);
        // Multiply by 1.05 so highest value is high enough that highest point in chart isn't hidden
        var queueMax = Chart.getMaxValPlusOne(vm.data[1]) * 1.05;

        var y1AxisOldTicks = vm.options.chart.y1Axis.tickValues;
        var y2AxisOldTicks = vm.options.chart.y2Axis.tickValues;
        var y1AxisNewTicks = [callMax / 4, callMax / 2, callMax / (1 + 1.0 / 3)];
        var y2AxisNewTicks = [queueMax / 4, queueMax / 2, queueMax / (1 + 1.0 / 3)];
        if (!angular.equals(y1AxisOldTicks, y1AxisNewTicks) || !angular.equals(y2AxisOldTicks, y2AxisNewTicks)) {
          vm.options.chart.bars.yDomain[1] = callMax;
          vm.options.chart.lines.yDomain[1] = queueMax;
          vm.options.chart.y1Axis.tickValues = y1AxisNewTicks;
          vm.options.chart.y2Axis.tickValues = y2AxisNewTicks;
          vm.api.refresh();
        }
      });
    }

    vm.queue = [];
    vm.date = new Date();

    function fetchData() {
      Queue.query().then(function (queue) {
        vm.queue = queue;
      });
      // Also update date/time
      vm.date = new Date();
    }
    var fetchDataInterval = $interval(fetchData, 5000);
    var fetchContactStatsInterval = $interval(fetchContactStats, 30 * 1000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
      $interval.cancel(fetchContactStatsInterval);
    });

    fetchData();
    fetchContactStats();
  });
