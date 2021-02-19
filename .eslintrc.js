module.exports = {
  env: {
    browser: true,
    es2021: true,
    jasmine: true,
  },
  extends: [
    'airbnb-base',
    'prettier',
    'plugin:jasmine/recommended'
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 12,
    sourceType: 'module',
  },
  plugins: ['@typescript-eslint', 'jasmine'],
  rules: {},
};
