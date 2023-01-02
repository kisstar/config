module.exports = {
  root: true,
  env: {
    browser: true,
    es6: true,
  },
  extends: ['eslint:recommended', 'airbnb-base', 'airbnb-typescript/base'],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
    project: './tsconfig.json',
  },
  rules: {},
}
