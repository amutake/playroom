import React from 'react';
import express from 'express';
import { renderToString } from 'react-dom/server';
import { createStore } from 'redux';
import { Provider } from 'react-redux';

import reducers from './reducers';
import App from './containers';

const app = express();
const port = 3000;

function renderFullString(html, initialState) {
  return `
<!doctype html>
<html>
  <head>
    <title>Redux Universal Example</title>
  </head>
  <body>
    <div id="app">${html}</div>
    <script>
      window.__INITIAL_STATE__ = ${JSON.stringify(initialState)}
    </script>
    <script src="/assets/js/bundle.js"></script>
  </body>
</html>
`;
}

function handleRender(req, res) {
  const store = createStore(reducers);
  const html = renderToString(
    <Provider store={store}>
      <App />
    </Provider>
  );
  const initialState = store.getState();
  res.send(renderFullString(html, initialState);
};

app.use(handleRender);
app.listen(port);
