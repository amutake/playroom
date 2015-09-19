import { combineReducers } from 'redux';

const initialState = {
  items: []
};

export default function reducer(state = initialState, action) {
  console.log('d');
  switch(action.type) {
  case 'SET_ITEMS':
    return {
      ...state,
      items: action.items
    };
  default:
    return state;
  }
}

export default reducer;
