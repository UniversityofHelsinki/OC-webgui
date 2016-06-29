module.exports = function(config) {
    config.set({
        basePath: './app/assets/javascripts',
        files: [
            '../../../vendor/assets/bower_components/angular/angular.js',
            '../../../vendor/assets/bower_components/angular-route/angular-route.js',
            '../../../vendor/assets/bower_components/angular-mocks/angular-mocks.js',
            '../../../vendor/assets/bower_components/angular-resource/angular-resource.js',
            '../../../vendor/assets/bower_components/angular-ui-router/release/angular-ui-router.js',
            '../../../vendor/assets/bower_components/angular-nvd3/dist/angular-nvd3.js',
            '../../../vendor/assets/bower_components/angularjs-nvd3-directives/dist/angularjs-nvd3-directives.js',
            '../../../vendor/assets/bower_components/d3/d3.js',
            '../../../vendor/assets/bower_components/nvd3/build/nv.d3.js',
            '../../../vendor/assets/bower_components/chartjs/dist/Chart.js',
            '**/*.js',
            '*.html',
        ],
        autoWatch: true,
        frameworks: ['jasmine'],
        browsers: ['Firefox'],
        plugins: [
            'karma-chrome-launcher',
            'karma-firefox-launcher',
            'karma-jasmine',
            'karma-junit-reporter',
        ],
        junitReporter: {
            outputFile: 'test_out/unit.xml',
            suite: 'unit',
        }
    });
};
