export function fetchCount(cb) {
  // instead of promise.then
  setTimeout(function () {
    cb(0);
  }, 500);
}
