var Chart = React.createClass({
    setOver: function() {
        var half = 1000 * 60 * 60 * 0.5;
        var zipped = this.props.total.map(function(_, i) {
            return {
                total: this.props.total[i],
                willbe: this.props.willbe[i]
            };
        }.bind(this));
        console.log(zipped);
        var regions = zipped.filter(function(e) {
            return e.willbe.size > e.total.size;
        }).map(function(e) {
            return {
                axis: 'x',
                start: e.total.timestamp - half,
                end: e.total.timestamp + half,
                class: 'over'
            };
        });
        console.log(regions);
        this.state.chart.regions(regions);
    },
    componentDidMount: function() {
        var timestamps = this.props.total.map(function(i) { return i.timestamp; });
        var total = this.props.total.map(function(i) { return i.size; });
        // var willbe = this.props.willbe.map(function(i) { return i.size; });
        var chart = c3.generate({
            bindto: '#chart',
            data: {
                x: 'x',
                json: {
                    x: timestamps,
                    total: total,
                    // willbe: willbe
                },
                type: 'spline'
            },
            axis: {
                x: {
                    padding: {left: 0, right: 0},
                    type: 'timeseries'
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
        this.setState({
            chart: chart
        });
    },
    componentDidUpdate: function() {
        var willbe = this.props.willbe.map(function(i) { return i.size; });
        this.state.chart.load({
            json: {
                willbe: willbe
            }
        });
        this.setOver();
    },
    render: function() {
        return (
                <div id="chart"></div>
        );
    }
});

var Form = React.createClass({
    render: function() {
        var inputs = this.props.inventry.map(function(v, i) {
            return (
                    <input type="number" value={v.size} onChange={this.props.changeText(i)} />
            );
        }.bind(this));
        return (
            <div>{inputs}</div>
        );
    }
});

var Component = React.createClass({
    changeWillbe: function(id) {
        return function(e) {
            var willbe = this.state.willbe;
            willbe[id].size = e.target.value;
            this.setState({
                willbe: willbe
            });
        }.bind(this);
    },
    getInitialState: function() {
        var hour = function(n) {
            return 1000 * 60 * 60 * n;
        };
        var total = [];
        for (var i = 0; i < 30; i++) {
            total.push({
                timestamp: hour(i),
                size: Math.floor(Math.random() * 20) + 10
            });
        }
        var willbe = [];
        for (var i = 0; i < 30; i++) {
            willbe.push({
                timestamp: hour(i),
                size: Math.floor(Math.random() * 20)
            });
        }
        return {
            total: total,
            willbe: willbe
        };
    },
    render: function() {
        return (
            <div>
                <Chart total={this.state.total} willbe={this.state.willbe} />
                <Form inventry={this.state.willbe} changeText={this.changeWillbe} />
            </div>
        );
    }
});

React.render(
    <Component />,
    document.getElementById('component')
);
