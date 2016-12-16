import React from 'react';
import ReactDOM from 'react-dom';
import remark from 'remark';
import html from 'remark-html';
import marked from 'marked';
import htmlparser from 'htmlparser2';

import plugin from './plugin';

const toCamelCase = (k) => {
  return k.replace(/_./g, (s) => s.charAt(1).toUpperCase());
};
const cssToObj = (css) => {
  const result = {};
  const attrs = css.split(';');
  attrs.map((attr) => {
    const [key, value] = attr.split(':');
    result[toCamelCase(key)] = value;
  });
  return result;
};
const keyMap = (obj, key1, key2) => {
  if (obj[key1] !== undefined) {
    obj[key2] = obj[key1];
    delete obj[key1];
  }
};
const valueMap = (obj, key, f) => {
  if (obj[key] !== undefined) {
    obj[key] = f(obj[key]);
  }
};

class Html extends React.Component {

  build = (str) => {
    let keyId = 0;
    const tagStack = [];
    const childrenStack = [[]];
    const parser = new htmlparser.Parser({
      onopentag: (name, attrs) => {
        tagStack.push({ name, attrs });
        childrenStack.push([]);
      },
      ontext: (text) => {
        const children = childrenStack.pop();
        children.push(text);
        childrenStack.push(children);
      },
      onclosetag: () => {
        const children = childrenStack.pop();
        const { name, attrs } = tagStack.pop();
        // class -> className, for -> htmlFor
        keyMap(attrs, 'class', 'className');
        keyMap(attrs, 'for', 'htmlFor');
        valueMap(attrs, 'style', cssToObj);
        const e = React.createElement(name, { ...attrs, key: keyId++ }, ...children); // TODO
        const parentChildren = childrenStack.pop();
        parentChildren.push(e);
        childrenStack.push(parentChildren);
      },
    });
    parser.parseComplete(str);
    return childrenStack.pop();
  };

  render() {
    const elems = this.build(this.props.htmlStr);
    return (
      <div>
        {elems}
      </div>
    );
  }
}

class App extends React.Component {

  state = {
    remarkJson: '',
    remarkHtml: '',
    markedJson: '',
    markedHtml: '',
    sandbox: '',
  };

  handleText = (e) => {
    const str = e.target.value;

    const remarkAst = remark.parse(str, {
      breaks: true,
      position: false,
    });
    const remarkHtml = remark().use(html).process(str);

    const markedAst = marked.lexer(str, {
      sanitize: true,
    });
    const markedHtml = marked(str);

    this.setState({
      remarkJson: JSON.stringify(remarkAst, null, 2),
      markedJson: JSON.stringify(markedAst, null, 2),
      remarkHtml: remarkHtml,
      markedHtml: markedHtml,
    });
  };

  render() {
    const { remarkJson, markedJson, remarkHtml, markedHtml } = this.state;
    return (
      <div>
        <textarea onChange={this.handleText} cols="200" rows="20"/>
        <div style={{display: 'flex'}}>
          <pre style={{width: '50vw', margin: '0', overflow: 'scroll'}}>{remarkJson}</pre>
          <pre style={{width: '50vw', margin: '0', overflow: 'scroll'}}>{markedJson}</pre>
        </div>
        <div style={{display: 'flex'}}>
          <pre style={{width: '50vw', margin: '0', overflow: 'scroll'}}>{remarkHtml}</pre>
          <pre style={{width: '50vw', margin: '0', overflow: 'scroll'}}>{markedHtml}</pre>
        </div>
        <Html htmlStr={markedHtml}/>
      </div>
    );
  }
}

ReactDOM.render(<App/>, document.getElementById('app'));
