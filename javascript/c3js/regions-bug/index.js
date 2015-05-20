(function() {
    var chart = c3.generate({
        bindto: '#chart',
        data: {
            columns: [
                ['data', 1, 3, 2, 4, 3]
            ]
        },
        regions: [
            { axis: 'x', start: 0, end: 2, class: 'over' },
            { axis: 'x', start: 3, end: 4, class: 'over' }
        ]
    });

    setTimeout(function() {
        chart.regions([
            { axis: 'x', start: 3, end: 4, class: 'over' }
        ]);
    }, 1000);
})();
