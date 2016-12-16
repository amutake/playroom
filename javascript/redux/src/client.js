import React from 'react';
import { createStore } from 'redux';
import { render } from 'react-dom';
import { createStore } from 'redux';
import { Provider } from 'react-redux';

import App from './containers';
import reducers from './reducers';

const initialState = window.__INITIAL_STATE__;
const store = createStore(reducers, initialState);

render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById('root')
);
