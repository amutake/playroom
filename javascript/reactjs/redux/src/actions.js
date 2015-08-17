export function loadItems(dispatch) {
  new Promise((resolve) => {
    setTimeout(() => {
      resolve(['hoge', 'fuga', 'piyo']);
    }, 500);
  }).then(items => {
    dispatch({
      type: 'SET_ITEMS',
      items
    });
  });
}
