import { defineConfig } from 'vitest/config';
import path from 'path';

export default defineConfig({
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: './spec/javascript/setupTests.js',
  },
  resolve: {
    alias: {
      "controllers": path.resolve(__dirname, "app/javascript/controllers"),
    },
  },
});
