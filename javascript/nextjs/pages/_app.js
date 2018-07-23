import React from 'react'
import App, { Container } from 'next/app'
import { Provider } from 'react-redux'
import withRedux from 'next-redux-wrapper'

import { makeStore, actionCreators } from '../store'

const fetchUser = (store) => {
  if (typeof store.getState().user === 'undefined') {
    return new Promise((resolve) => {
      setTimeout(() => {
        store.dispatch(actionCreators.user.set({name: Date.now()}))
        resolve()
      }, 1000)
    })
  } else {
    return {}
  }
}

class MyApp extends App {
  static async getInitialProps(ctx) {
    console.log('MyApp.getInitialProps.start')
    const props = await super.getInitialProps(ctx)
    await fetchUser(ctx.ctx.store)
    console.log('MyApp.getInitialProps.end')
    return { pageProps: { time: Date.now(), ...props.pageProps }}
  }

  render() {
    console.log('MyApp.render')
    const { Component, pageProps, store } = this.props
    return (
      <Container>
        <Provider store={store}>
          <Component {...pageProps} />
        </Provider>
      </Container>
    )
  }
}

export default withRedux(makeStore)(MyApp)
