export function loadItems(dispatch) {
  new Promise((resolve) => {
    dispatch({
      type: 'SET_ITEMS',
      items: ['hoge', 'fuga', 'piyo']
    });
  });
}
