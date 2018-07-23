import React from 'react'
import Link from 'next/link'
import { connect } from 'react-redux'

import { actionCreators } from '../store'

class Index extends React.Component {
  static async getInitialProps(ctx) {
    console.log('Index.getInitialProps')
    return { index: 'index' }
  }

  increment = () => {
    this.props.dispatch(actionCreators.counter.increment())
  }
  decrement = () => {
    this.props.dispatch(actionCreators.counter.decrement())
  }

  render() {
    console.log('Index.render')
    console.log(this.props)
    return (
      <div>
        <Link href="/about">
          <a>about</a>
        </Link>
        {this.props.time}
        <button onClick={this.increment}>
          increment
        </button>
        <button onClick={this.decrement}>
          decrement
        </button>
        counter: {this.props.count}
        user: {this.props.user.name}
      </div>
    )
  }
}

export default connect(state => state,
                       dispatch => ({ increment: dispatch(actionCreators.counter.increment()),
                                      decrement: dispatch(actionCreators.counter.decrement())
                                    }))(Index)
