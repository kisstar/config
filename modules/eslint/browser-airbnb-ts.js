module.exports = {
  root: true,
  env: {
    browser: true,
    es2021: true,
  },
  extends: ['eslint:recommended', 'airbnb-base', 'airbnb-typescript/base'],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
    // parserOptions: {
    //   project: './tsconfig.json',
    // },
  },
  rules: {},
}
