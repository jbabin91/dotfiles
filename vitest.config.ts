import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    include: ['tests/**/*.test.ts'],
    // Pinned rather than load-bearing: measured, the suite passes identically
    // under forks, threads, and no setting. It is the vitest 5 default, stated
    // so a future default change cannot move process-spawning tests silently.
    pool: 'forks',
    // Every assertion here is on a long stderr string; the default truncates
    // diffs at ~40 characters, which hides the part that differs.
    chaiConfig: { truncateThreshold: 0 },
    // A test that asserts nothing passes by default. One already slipped
    // through this suite (an early `return` where `skipIf` was meant).
    expect: { requireAssertions: true },
  },
});
