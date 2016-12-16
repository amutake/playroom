const transformer = (ast, file, next) => {
  console.log(ast);
}

export default function (remark, options) {
  console.log('remark', remark);
  console.log('options', options);
  return transformer;
}
