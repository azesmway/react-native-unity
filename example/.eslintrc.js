module.exports = {
  root: true,
  ignorePatterns: ['**/*.d.ts'],
  extends: ['@react-native', 'eslint:recommended', 'plugin:@typescript-eslint/eslint-recommended', 'plugin:ft-flow/recommended'],
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint', 'simple-import-sort', 'jest', 'ft-flow'],
  overrides: [
    {
      files: ['*.ts', '*.tsx'],
      rules: {
        '@typescript-eslint/no-shadow': ['error'],
        'no-shadow': 'off',
        'no-undef': 'off'
      }
    }
  ],
  rules: {
    eqeqeq: 'off',
    'prettier/prettier': 'error',
    'comma-dangle': ['error', 'never'],
    semi: ['error', 'never'],
    'max-len': [
      'error',
      {
        code: 200
      }
    ],
    'react-hooks/exhaustive-deps': 'off',
    'simple-import-sort/exports': 'error',
    'simple-import-sort/imports': 'error',
    'no-unused-vars': 'off',
    '@typescript-eslint/no-unused-vars': 'off',
    '@typescript-eslint/ban-ts-ignore': 'off',
    'no-unsafe-optional-chaining': 'off',
    'ft-flow/boolean-style': [2, 'boolean']
  },
  env: {
    node: true,
    'jest/globals': true
  },
  settings: {
    'ft-flow': {
      onlyFilesWithFlowAnnotation: false
    }
  }
}
