// BASE_URL defaults to the staging container started by e2e/run-staging.sh.
const { defineConfig } = require('@playwright/test');
module.exports = defineConfig({
  testDir: '.',
  testMatch: '*.spec.js',
  timeout: 30000,
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:18080',
    channel: process.env.PW_CHANNEL || 'chrome', // system Chrome; no browser download needed
    screenshot: 'on',
  },
  outputDir: 'test-results',
});
