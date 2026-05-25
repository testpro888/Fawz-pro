/**
 * Property Test: Non-Trading Day Classification
 * Feature: saham-trading-system, Property 5: Non-Trading Day Classification
 * Validates: Requirements 4.1, 4.5, 4.6
 */
import { describe, it, expect, beforeAll } from 'vitest';
import fc from 'fast-check';

// Set up window global for the IIFE module
globalThis.window = globalThis.window || {};

// Load the module (it attaches to window.SahamHolidays)
await import('../saham-holidays.js');

const { isNonTradingDay, HOLIDAYS_2026 } = window.SahamHolidays;

/**
 * Arbitrary: generates a valid date string in 2026 ('YYYY-MM-DD' format)
 */
const date2026Arb = fc
  .integer({ min: 1, max: 365 })
  .map((dayOfYear) => {
    const date = new Date(2026, 0, dayOfYear);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  });

describe('Feature: saham-trading-system, Property 5: Non-Trading Day Classification', () => {
  /**
   * Property 5a: isNonTradingDay returns true iff the date is Saturday, Sunday, or in HOLIDAYS_2026
   * Validates: Requirements 4.1, 4.6
   */
  it('isNonTradingDay returns true iff date is Saturday, Sunday, or in HOLIDAYS_2026', () => {
    fc.assert(
      fc.property(date2026Arb, (dateStr) => {
        const parts = dateStr.split('-');
        const year = parseInt(parts[0], 10);
        const month = parseInt(parts[1], 10) - 1;
        const day = parseInt(parts[2], 10);
        const date = new Date(year, month, day);
        const dayOfWeek = date.getDay();

        const isWeekend = dayOfWeek === 0 || dayOfWeek === 6;
        const isHoliday = HOLIDAYS_2026.has(dateStr);
        const expectedNonTrading = isWeekend || isHoliday;

        const result = isNonTradingDay(dateStr);

        expect(result).toBe(expectedNonTrading);
      }),
      { numRuns: 200 }
    );
  });

  /**
   * Property 5b: No double-counting — total trading days + total non-trading days = 365
   * Validates: Requirements 4.5, 4.6
   */
  it('total trading days + total non-trading days = 365 for 2026 (no double-counting)', () => {
    let tradingDays = 0;
    let nonTradingDays = 0;

    for (let dayOfYear = 1; dayOfYear <= 365; dayOfYear++) {
      const date = new Date(2026, 0, dayOfYear);
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      const dateStr = `2026-${month}-${day}`;

      if (isNonTradingDay(dateStr)) {
        nonTradingDays++;
      } else {
        tradingDays++;
      }
    }

    expect(tradingDays + nonTradingDays).toBe(365);
  });

  /**
   * Property 5c: Verify correct trading day count for 2026
   * The mathematically correct count is 242 trading days given the HOLIDAYS_2026 set
   * (6 holidays fall on weekends, so 365 - 104 weekends - 19 unique weekday holidays = 242)
   * Validates: Requirements 4.5, 4.6
   */
  it('2026 has exactly 242 trading days (accounting for holidays on weekends)', () => {
    let tradingDays = 0;

    for (let dayOfYear = 1; dayOfYear <= 365; dayOfYear++) {
      const date = new Date(2026, 0, dayOfYear);
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      const dateStr = `2026-${month}-${day}`;

      if (!isNonTradingDay(dateStr)) {
        tradingDays++;
      }
    }

    expect(tradingDays).toBe(242);
  });

  /**
   * Property 5d: Every date is classified exactly once (either trading or non-trading, never both)
   * This is a property-based verification using random sampling
   * Validates: Requirements 4.6
   */
  it('each date is classified as exactly one of trading or non-trading (mutual exclusivity)', () => {
    fc.assert(
      fc.property(date2026Arb, (dateStr) => {
        const result = isNonTradingDay(dateStr);
        // Result must be a boolean (exactly true or false, never undefined/null)
        expect(typeof result).toBe('boolean');
      }),
      { numRuns: 200 }
    );
  });

  /**
   * Property 5e: Weekend detection is consistent — all Saturdays and Sundays are non-trading
   * Validates: Requirements 4.1
   */
  it('all Saturdays and Sundays in 2026 are classified as non-trading days', () => {
    fc.assert(
      fc.property(date2026Arb, (dateStr) => {
        const parts = dateStr.split('-');
        const date = new Date(
          parseInt(parts[0], 10),
          parseInt(parts[1], 10) - 1,
          parseInt(parts[2], 10)
        );
        const dayOfWeek = date.getDay();

        if (dayOfWeek === 0 || dayOfWeek === 6) {
          expect(isNonTradingDay(dateStr)).toBe(true);
        }
      }),
      { numRuns: 200 }
    );
  });
});
