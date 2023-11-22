module.exports = {
  clearMocks: true,

  globals: {
    'ts-jest': {
      tsconfig: 'tsconfig.spec.json', // as specified by ts-jest
      babelConfig: true
    }
  },

  moduleFileExtensions: ['js', 'jsx', 'ts', 'tsx', 'json', 'node'],

  moduleNameMapper: {
    '^.+.(css|styl|less|sass|scss|png|jpg|ttf|woff|woff2|webp)$': 'jest-transform-stub'
  },

  preset: 'react-native',

  testEnvironment: 'jsdom',

  transform: {
    '^.+\\.jsx$': 'babel-jest',
    '^.+\\.tsx?$': 'ts-jest',
    '.+\\.(css|styl|less|sass|scss|png|jpg|ttf|woff|woff2)$': 'jest-transform-stub'
  },

  transformIgnorePatterns: ['/node_modules/(?!(@react-native|react-native)).*/'],

  verbose: true
}
