var React = require('react');
var Markdown = require('react-remarkable');

var App = React.createClass({
  getInitialState: function() {
    return {
      code: ''
    };
  },
  componentDidMount: function() {
    setInterval(function() {
      var code = this.refs.code.getDOMNode().value;
      this.setState({code: code});
    }.bind(this), 1000);
  },
  render: function() {
    return (
      <div>
        <h1>Markdown Editor</h1>
        <textarea ref='code' rows='20' style={{width: '100%'}} />
        <Markdown source={this.state.code} />
      </div>
    )
  }
});

React.render(<App />, document.body);
