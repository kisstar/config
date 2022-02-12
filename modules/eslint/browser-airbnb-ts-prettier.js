module.exports = {
  root: true,
  env: {
    browser: true,
    es2021: true,
  },
  plugins: ['prettier'],
  extends: [
    'eslint:recommended',
    'airbnb-base',
    'airbnb-typescript/base',
    'plugin:prettier/recommended',
  ],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
    // parserOptions: {
    //   project: './tsconfig.json',
    // },
  },
  rules: {
    'prettier/prettier': 'error',
  },
}
