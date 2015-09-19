import React, { Component, PropTypes } from 'react';
import { connect } from 'react-redux';
import * as actions from './actions';

@connect(state => ({ items: state.items }))
export default class App extends Component {
  static propTypes = {
    items: PropTypes.array.isRequired,
    dispatch: PropTypes.func.isRequired
  }
  componentWillMount() {
    actions.loadItems(this.props.dispatch);
  }
  render() {
    const items = this.props.items.map((item, i) => (
      <li key={i}>{item}</li>
    ));
    return (
      <div>
        <h1>Test App</h1>
        <ul>{items}</ul>
      </div>
    );
  }
}
