import React from 'react';
import { createStore } from 'redux';
import reducer from './reducer';
import makeRoot from './universal';

const store = createStore(reducer, window.__initial_state);

React.render(makeRoot(store), document.getElementById('root'));
