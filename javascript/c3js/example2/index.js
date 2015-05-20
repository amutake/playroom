(function() {
    var hour = function(n) {
        return 1000 * 60 * 60 * n;
    };
    var timestamps = [];
    for (var i = 0; i < 30; i++) {
        timestamps.push(hour(i));
    };
    var total = [];
    for (var i = 0; i < 30; i++) {
        total.push(Math.floor(Math.random() * 20) + 10);
    }
    var willbe = [];
    var resetWillbe = function() {
        willbe = [];
        for (var i = 0; i < 30; i++) {
            willbe.push(Math.floor(Math.random() * 20));
        }
    };
    resetWillbe();

    var chart = c3.generate({
        bindto: '#chart',
        data: {
            // x: 'x',
            json: {
                // x: timestamps,
                total: total,
                willbe: willbe
            },
            type: 'spline'
        },
        axis: {
            x: {
                padding: {left: 0, right: 0},
                // type: 'timeseries'
            },
            y: {
                padding: {bottom: 0}
            }
        },
        subchart: {
            show: true
        },
        point: {
            show: false
        }
    });

    var setOver = function() {
        var half = 1000 * 60 * 60 * 0.5;
        var zipped = total.map(function(_, i) {
            return {
                total: total[i],
                willbe: willbe[i],
                timestamp: timestamps[i],
                index: i
            };
        });
        console.log(zipped);
        var regions = zipped.filter(function(e) {
            return e.willbe > e.total;
        }).map(function(e) {
            return {
                axis: 'x',
                start: e.index,
                end: e.index + 1,
                // start: e.timestamp - half,
                // end: e.timestamp + half,
                class: 'over'
            };
        });
        console.log(regions);
        chart.regions(regions);
    };
    setOver();

    input.addEventListener('input', function() {
        console.log(input.value);
        willbe[5] = input.value;
        chart.load({
            json: {
                willbe: willbe
            }
        });
        setOver();
    });

    document.getElementById('button').addEventListener('click', function() {
        resetWillbe();
        chart.load({
            json: {
                willbe: willbe
            }
        });
        setOver();
    });
})();
