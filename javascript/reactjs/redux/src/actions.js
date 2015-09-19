export function loadItems(dispatch) {
  console.log('a');
  let start = new Date().getTime();
  while (new Date().getTime() < start + 500) {}
  console.log('b');
  let items = ['hoge', 'fuga', 'piyo'];
  dispatch({
    type: 'SET_ITEMS',
    items
  });
  /*
  return new Promise((resolve) => {
    console.log('a');
    setTimeout(() => {
      console.log('b');
      resolve(['hoge', 'fuga', 'piyo']);
    }, 500);
  }).then(items => {
    console.log('c');
    dispatch({
      type: 'SET_ITEMS',
      items
    });
  });
  */
}
