import Document, { Main, NextScript } from 'next/document'

export default class MyDocument extends Document {
  static async getInitialProps(ctx) {
    console.log('MyDocument.getInitialProps.start')
    const props = await super.getInitialProps(ctx)
    console.log('MyDocument.getInitialProps.end')
    return props
  }

  render() {
    return (
      <html>
        <body>
          <Main />
          <NextScript />
        </body>
      </html>
    )
  }
}
