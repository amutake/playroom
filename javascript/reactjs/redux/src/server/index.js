import express from 'express';
import React from 'react';
import { createStore } from 'redux';
import serialize from 'serialize-javascript';
import html from './html.js';
import makeRoot from '../universal';
import reducer from '../reducer';

const app = express();

app.use('/assets', express.static('assets'));

app.get('/', (req, res) => {
  console.log(`location: ${req.path}`);
  const store = createStore(reducer);
  const rootString = React.renderToString(makeRoot(store));
  const serializedState = serialize(store.getState());
  console.log(serializedState);
  res.send(html(rootString, serializedState));
});

app.listen(5815);
