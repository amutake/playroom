var React = require('react');
var { Grid, Row, Col, Input, Button } = require('react-bootstrap');
var Markdown = require('react-remarkable');

var App = React.createClass({
  getInitialState: function() {
    return {
      code: ''
    };
  },
  handleChange: function() {
    this.setState({ code: this.refs.code.getValue() });
  },
  render: function() {
    return (
      <Grid>
        <h1>Markdown Editor</h1>
        <Row>
          <Col xs={8} md={6}>
            <Input type='textarea' ref='code' label='Code' onChange={this.handleChange} rows={30} />
          </Col>
          <Col xs={8} md={6}>
            <Markdown source={this.state.code} />
          </Col>
        </Row>
      </Grid>
    )
  }
});

React.render(<App />, document.body);

require('bootstrap/dist/css/bootstrap.min.css');
