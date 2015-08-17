import React from 'react';
import { Provider } from 'react-redux';

import App from './container';

export default function makeRoot(store) {
  return (
    <Provider store={store}>
      {() => <App />}
    </Provider>
  );
}
