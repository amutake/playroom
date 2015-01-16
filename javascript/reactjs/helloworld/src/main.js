var React = require('react');
var CommentBox = require('./components.js');
var data = require('./data.js');

React.render(
  <CommentBox url="http://localhost:4567/comments" pollInterval={2000} />,
  document.getElementById('content')
);
