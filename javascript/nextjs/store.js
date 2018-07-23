import { createStore } from 'redux'
import { createActions, handleActions } from 'redux-actions'

const initialState = {
  user: undefined,
  count: 0
}

export const actionCreators = createActions({
  USER: {
    SET: undefined
  },
  COUNTER: {
    INCREMENT: undefined,
    DECREMENT: undefined
  }
})

const reducer = handleActions({
  USER: {
    SET: (state, action) => {
      console.log(action)
      return ({
        ...state,
        user: action.payload
      })
    }
  },
  COUNTER: {
    INCREMENT: (state) => ({
      ...state,
      count: state.count + 1
    }),
    DECREMENT: (state) => ({
      ...state,
      count: state.count - 1
    })
  }
}, initialState)

export const makeStore = (state = initialState) => {
  console.log(state)
  return createStore(reducer, state)
}
