// Jest setup file
// Mock Electron APIs for testing
global.electronAPI = {
  // Mock electron APIs here for testing
};

// Mock console methods to reduce noise in tests
global.console = {
  ...console,
  log: jest.fn(),
  debug: jest.fn(),
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn()
};