(function() {
    'use strict';
    var chart = c3.generate({
        bindto: '#chart',
        size: {
            height: 480
        },
        data: {
            x: 'x',
            // columns: [
            //     ['x', '05:00', '06:00', '07:00', '08:00', '09:00', '10:00'],
            //     ['Total', 30000, 20000, 10000, 40000, 15000, 25000],
            //     ['Reserved', 5000, 3000, 2000, 6000, 5000, 2500]
            // ],
            json: {
                x: [0, 1000000000, 2000000000, 3000000000, 4000000000, 5000000000, 6000000000000],
                // x: ['2015-05-20 05:00:00', '2015-05-20 06:00:00', '2015-05-20 07:00:00', '2015-05-20 08:00:00', '2015-05-20 09:00:00', '2015-05-20 10:00:00'],
                Total: [30000, 20000, 10000, 40000, 15000, 25000],
                Reserved: [5000, 3000, 2000, 6000, 5000, 2500]
            },
            type: 'spline',
            selection: {
                draggable: true
            }
        },
        axis: {
            x: {
                padding: {left: 0, right: 0},
                type: 'timeseries',
                tick: {
                    format: function(x) {
                        var t = '';
                        if (x.getHours === 0) {
                            t += x.getYears() + '-' + x.getMonth() + '-' + x.getDay() + ' ';
                        }
                        t += x.getHours() + ':' + x.getMinutes();
                        return t;
                    }
                }
            },
            y: {
                padding: {bottom: 0}
            }
        },
        point: {
            show: false
        },
        subchart: {
            show: true,
            onbrush: function(d) {
                console.log(d);
            },
            size: {
                height: 20
            }
        }
    });
    window.chart = chart;
})();
