import React, { Component, PropTypes } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as actions from './actions';

const select = state => ({
  n: state.n
});
const bind = dispatch => ({
  actions: bindActionCreators(actions, dispatch)
});

@connect(select, bind)
export default class App extends Component {
  static propTypes = {
    n: PropTypes.number.isRequired,
    actions: PropTypes.object.isRequired
  }

  // この中で非同期に API は呼べないから、上から n が降ってくる？
  constructor(props) {
    super(props);
  }

  render() {
    const { n, actions } = this.props;
    return (
      <div>
        <h1>{n}</h1>
        <button onClick={actions.increment}>+</button>
        <button onClick={actions.decrement}>-</button>
      </div>
    );
  }
}
