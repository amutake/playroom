var React = require('react');
var Router = require('react-router');
var { Route, DefaultRoute, RouteHandler, Link, NotFoundRoute } = Router;

var App = React.createClass({
  render: () => (
    <div>
      <ul>
        <li><Link to="app">Link to App</Link></li>
        <li><Link to="page1">Link to Page1</Link></li>
      </ul>
      <RouteHandler />
    </div>
  )
});

var Page1 = React.createClass({
  render: () => (
    <div>
      <p>Page1</p>
      <Link to="app">Back</Link>
    </div>
  )
});

var Default = React.createClass({
  render: () => (
    <h1>This is default page</h1>
  )
});

var routes = (
  <Route name="app" path="/" handler={App}>
    <Route name="page1" path="/page1" handler={Page1} />
    <DefaultRoute handler={Default} />
  </Route>
);

Router.run(routes, Router.HistoryLocation, (Handler) => {
  React.render(<Handler />, document.body);
});
