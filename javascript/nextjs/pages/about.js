import React from 'react'
import Link from 'next/link'
import { connect } from 'react-redux'

import { actionCreators } from '../store'

class About extends React.Component {
  static async getInitialProps(ctx) {
    console.log('About.getInitialProps')
    return { about: 'about' }
  }

  render() {
    console.log('About.render')
    return (
      <div>
        <Link href="/">
          <a>index</a>
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
                                    }))(About)
