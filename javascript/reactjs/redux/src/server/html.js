export default function html(root, state) {
  return `
<!doctype html>
<html>
  <head>
    <title>React Sample</title>
  </head>
  <body>
    <div id="root">${root}</div>
    <script src="/assets/js/vendor.bundle.js"></script>
    <script>window.__initial_state=${state};</script>
    <script src="/assets/js/bundle.js"></script>
  </body>
</html>
  `;
}
