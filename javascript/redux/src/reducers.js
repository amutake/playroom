import { combineReducers } from 'redux';

const initialState = {
  n: 0
};

function counter(state = initialState, action) {
  switch (action.type) {
    case 'INCREMENT':
      return {
        n: state.n + 1
      };
    case 'DECREMENT':
      return {
        n: state.n - 1
      };
    case 'RESET':
      return initialState;
    default:
      return state;
  }
}

const reducers = combineReducers({ counter });
export default reducers;
