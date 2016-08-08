angular.module('ocWebGui.queue', ['ocWebGui.queue.service', 'ui.router', 'ocWebGui.shared.time', 'ocWebGui.shared.chart.service', 'nvd3'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('queue', {
        url: '/queue',
        views: {
          nav: {
            templateUrl: 'navbar/navbar_screen.html'
          },
          content: {
            templateUrl: 'queue/_queue.html',
            controller: 'QueueController',
            controllerAs: 'queue'
          }
        },
        navbarOverlay: true
      });
  })
  .controller('QueueController', function ($q, $interval, $scope, Queue, $http, Settings, Chart) {
    var vm = this;
    vm.api = {};

    vm.options = Chart.queueChart;
    vm.data = [{
      'key': 'Puheluja tunnissa',
      'bar': true,
      'color': '#888888',
      'values': []
    }, {
      'key': 'Keskim. jonotusaika',
      'color': '#ff0000',
      'values': []
    }];

    function fetchContactStats() {
      return $q.all({
        otherSettings: Settings.getOthers(),
        response: $http.get('contacts/stats.json')
      }).then(function (values) {
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

        var yAxis1OldTicks = vm.options.chart.yAxis1.tickValues;
        var yAxis2OldTicks = vm.options.chart.yAxis2.tickValues;
        var yAxis1NewTicks = [callMax / 4, callMax / 2, callMax / (1 + 1.0 / 3)];
        var yAxis2NewTicks = [queueMax / 4, queueMax / 2, queueMax / (1 + 1.0 / 3)];
        if (!angular.equals(yAxis1OldTicks, yAxis1NewTicks) || !angular.equals(yAxis2OldTicks, yAxis2NewTicks)) {
          vm.options.chart.bars.yDomain[1] = callMax;
          vm.options.chart.lines.yDomain[1] = queueMax;
          vm.options.chart.yAxis1.tickValues = yAxis1NewTicks;
          vm.options.chart.yAxis2.tickValues = yAxis2NewTicks;
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
    var fetchDataInterval = $interval(fetchData, 1000);
    var fetchContactStatsInterval = $interval(fetchContactStats, 30 * 1000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
      $interval.cancel(fetchContactStatsInterval);
    });

    fetchData();
    fetchContactStats();
  });
