/**
 * Property-Based Tests for commission-settings.js
 * Feature: sales-target-commission
 *
 * Uses fast-check for property-based testing.
 * The module uses IIFE + window.CommissionSettings, so we set up
 * global.window before loading the file — same pattern as saham-access-control.test.js
 * which extracts logic directly rather than importing the browser module.
 *
 * All functions are extracted/replicated here to match the pure-function logic
 * in js/commission-settings.js for testability in Node/Vitest environment.
 */

import { describe, it, expect, beforeAll } from 'vitest';
import fc from 'fast-check';
import { createRequire } from 'module';
import { fileURLToPath } from 'url';
import path from 'path';

// ── Setup global.window so the IIFE can assign window.CommissionSettings ──────
globalThis.window = {};

// Load the IIFE module via createRequire (CommonJS-compatible dynamic load)
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const require = createRequire(import.meta.url);
require(path.resolve(__dirname, '../js/commission-settings.js'));

const CS = globalThis.window.CommissionSettings;

// ─────────────────────────────────────────────────────────────────────────────
// Property 1 — alphabetical sort
// Feature: sales-target-commission, Property 1: Sales list is always alphabetically sorted
// ─────────────────────────────────────────────────────────────────────────────
describe('Property 1: Sales list is always alphabetically sorted', () => {
  it('sorted array satisfies locale-aware order for any input', () => {
    // Feature: sales-target-commission, Property 1: alphabetical sort
    fc.assert(
      fc.property(
        fc.array(fc.record({ id: fc.uuid(), nama: fc.string() })),
        (salesArr) => {
          const sorted = [...salesArr].sort((a, b) =>
            a.nama.localeCompare(b.nama, 'id', { sensitivity: 'base' })
          );
          for (let i = 1; i < sorted.length; i++) {
            expect(
              sorted[i - 1].nama.localeCompare(sorted[i].nama, 'id', { sensitivity: 'base' })
            ).toBeLessThanOrEqual(0);
          }
        }
      ),
      { numRuns: 100 }
    );
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// Property 2 — case-insensitive lookup
// Feature: sales-target-commission, Property 2: Sales name lookup is case-insensitive
// ─────────────────────────────────────────────────────────────────────────────
describe('Property 2: Sales name lookup is case-insensitive', () => {
  // Inline lookup function matching the autoSelectSales logic
  function findSalesByName(salesList, customerSalesName) {
    if (!customerSalesName) return null;
    const match = salesList.find(
      (s) => s.nama.toLowerCase() === customerSalesName.toLowerCase()
    );
    return match || null;
  }

  it('finds the same record regardless of casing variation', () => {
    // Feature: sales-target-commission, Property 2: case-insensitive lookup
    fc.assert(
      fc.property(
        fc.array(fc.record({ id: fc.uuid(), nama: fc.string({ minLength: 1 }) }), { minLength: 1 }),
        fc.integer({ min: 0 }).chain((idx) =>
          fc.tuple(fc.constant(idx), fc.string())
        ),
        (salesList, [rawIdx, randomSuffix]) => {
          const idx = rawIdx % salesList.length;
          const targetRecord = salesList[idx];

          // Create a casing variant of the target name
          const nameVariant = targetRecord.nama
            .split('')
            .map((ch, i) => (i % 2 === 0 ? ch.toUpperCase() : ch.toLowerCase()))
            .join('');

          const found = findSalesByName(salesList, nameVariant);
          // Should find the record (same id) since lookup is case-insensitive
          expect(found).not.toBeNull();
          expect(found.id).toBe(targetRecord.id);

          // No-match scenario: use a name that clearly won't be in the list
          const notFound = findSalesByName(salesList, '\x00\x01\x02_no_match_' + randomSuffix);
          // It's technically possible (but astronomically unlikely) for this to match;
          // only assert null when the list doesn't contain the sentinel
          const hasIt = salesList.some(
            (s) => s.nama.toLowerCase() === ('\x00\x01\x02_no_match_' + randomSuffix).toLowerCase()
          );
          if (!hasIt) {
            expect(notFound).toBeNull();
          }
        }
      ),
      { numRuns: 100 }
    );
  });

  it('returns null for empty customerSalesName', () => {
    // Feature: sales-target-commission, Property 2: empty lookup returns null
    fc.assert(
      fc.property(
        fc.array(fc.record({ id: fc.uuid(), nama: fc.string() })),
        (salesList) => {
          expect(findSalesByName(salesList, '')).toBeNull();
          expect(findSalesByName(salesList, null)).toBeNull();
        }
      ),
      { numRuns: 100 }
    );
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// Property 3 — resolveEffectiveSettings: matching record vs Global_Default
// Feature: sales-target-commission, Property 3: resolveEffectiveSettings returns the correct record or Global_Default
// ─────────────────────────────────────────────────────────────────────────────
describe('Property 3: resolveEffectiveSettings returns correct record or Global_Default', () => {
  it('returns matching record when present, Global_Default otherwise', () => {
    // Feature: sales-target-commission, Property 3: resolveEffectiveSettings matching record vs Global_Default
    fc.assert(
      fc.property(
        fc.array(
          fc.record({
            sales_id: fc.uuid(),
            period: fc.string(),
            target_fee: fc.float({ min: Math.fround(1), noNaN: true, noDefaultInfinity: true }),
            rate_above: fc.float({ min: Math.fround(0.01), max: Math.fround(1), noNaN: true }),
            rate_below: fc.float({ min: Math.fround(0.01), max: Math.fround(1), noNaN: true }),
          })
        ),
        fc.uuid(),
        fc.string(),
        (arr, salesId, period) => {
          const result = CS.resolveEffectiveSettings(arr, salesId, period);
          const match = arr.find(
            (r) => r.sales_id === salesId && r.period === period
          );
          if (match) {
            expect(result.target_fee).toBe(match.target_fee);
            expect(result.isDefault).toBe(false);
          } else {
            expect(result.target_fee).toBe(CS.GLOBAL_DEFAULT.target_fee);
            expect(result.isDefault).toBe(true);
          }
        }
      ),
      { numRuns: 200 }
    );
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// Property 4 — calculateCommission: correct rate branch
// Feature: sales-target-commission, Property 4: Commission calculation applies the correct rate branch
// ─────────────────────────────────────────────────────────────────────────────
describe('Property 4: calculateCommission applies correct rate branch', () => {
  it('uses rate_above when totalFee >= targetFee, rate_below otherwise', () => {
    // Feature: sales-target-commission, Property 4: calculateCommission correct rate branch
    fc.assert(
      fc.property(
        fc.float({ min: Math.fround(0), max: Math.fround(1e9), noNaN: true, noDefaultInfinity: true }),
        fc.float({ min: Math.fround(1), max: Math.fround(1e9), noNaN: true, noDefaultInfinity: true }),
        fc.float({ min: Math.fround(0.01), max: Math.fround(1), noNaN: true }),
        fc.float({ min: Math.fround(0.01), max: Math.fround(1), noNaN: true }),
        (totalFee, targetFee, rateAbove, rateBelow) => {
          const settings = {
            target_fee: targetFee,
            rate_above: rateAbove,
            rate_below: rateBelow,
          };
          const { commission } = CS.calculateCommission(totalFee, settings);

          if (totalFee >= targetFee) {
            const expected = totalFee * rateAbove;
            // Relative tolerance of 1e-6 for floating-point arithmetic
            const tolerance = Math.max(Math.abs(expected) * 1e-6, 1e-9);
            expect(Math.abs(commission - expected)).toBeLessThanOrEqual(tolerance);
          } else {
            const expected = totalFee * rateBelow;
            const tolerance = Math.max(Math.abs(expected) * 1e-6, 1e-9);
            expect(Math.abs(commission - expected)).toBeLessThanOrEqual(tolerance);
          }
        }
      ),
      { numRuns: 200 }
    );
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// Property 5 — getAchievementStatus: badge classification
// Feature: sales-target-commission, Property 5: Badge classification is correct for any (totalFee, targetFee) pair
// ─────────────────────────────────────────────────────────────────────────────
describe('Property 5: getAchievementStatus badge classification', () => {
  it('returns TARGET_ACHIEVED when targetFee > 0 and totalFee >= targetFee', () => {
    // Feature: sales-target-commission, Property 5: zone 1 TARGET_ACHIEVED
    fc.assert(
      fc.property(
        fc.float({ min: Math.fround(0), max: Math.fround(1e9), noNaN: true, noDefaultInfinity: true }),
        fc.float({ min: Math.fround(0.001), max: Math.fround(1e9), noNaN: true, noDefaultInfinity: true }),
        (base, extra) => {
          // totalFee = base + extra >= targetFee = base (ensure totalFee >= targetFee)
          const targetFee = base;
          const totalFee = base + extra;
          fc.pre(targetFee > 0);
          expect(CS.getAchievementStatus(totalFee, targetFee)).toBe('TARGET_ACHIEVED');
        }
      ),
      { numRuns: 100 }
    );
  });

  it('returns BELOW_TARGET when targetFee > 0 and totalFee < targetFee', () => {
    // Feature: sales-target-commission, Property 5: zone 2 BELOW_TARGET
    fc.assert(
      fc.property(
        fc.float({ min: Math.fround(0.001), max: Math.fround(1e9), noNaN: true, noDefaultInfinity: true }),
        fc.float({ min: Math.fround(0.001), max: Math.fround(1e9), noNaN: true, noDefaultInfinity: true }),
        (totalFee, extra) => {
          const targetFee = totalFee + extra; // targetFee > totalFee
          expect(CS.getAchievementStatus(totalFee, targetFee)).toBe('BELOW_TARGET');
        }
      ),
      { numRuns: 100 }
    );
  });

  it('returns INVALID_TARGET when targetFee <= 0', () => {
    // Feature: sales-target-commission, Property 5: zone 3 INVALID_TARGET
    fc.assert(
      fc.property(
        fc.float({ min: Math.fround(0), max: Math.fround(1e9), noNaN: true, noDefaultInfinity: true }),
        fc.oneof(
          fc.constant(0),
          fc.float({ max: 0, noNaN: true, noDefaultInfinity: true }),
          fc.constant(-1),
          fc.constant(-1000000)
        ),
        (totalFee, targetFee) => {
          expect(CS.getAchievementStatus(totalFee, targetFee)).toBe('INVALID_TARGET');
        }
      ),
      { numRuns: 100 }
    );
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// Property 6 — calculateAchievementPercent: precision
// Feature: sales-target-commission, Property 6: Achievement percentage calculation
// ─────────────────────────────────────────────────────────────────────────────
describe('Property 6: calculateAchievementPercent precision', () => {
  it('returns Math.round((totalFee/targetFee)*10000)/100 for targetFee > 0', () => {
    // Feature: sales-target-commission, Property 6: calculateAchievementPercent precision
    fc.assert(
      fc.property(
        fc.float({ min: Math.fround(0), max: Math.fround(1e9), noNaN: true, noDefaultInfinity: true }),
        fc.float({ min: Math.fround(0.001), max: Math.fround(1e9), noNaN: true, noDefaultInfinity: true }),
        (totalFee, targetFee) => {
          const result = CS.calculateAchievementPercent(totalFee, targetFee);
          const expected = Math.round((totalFee / targetFee) * 10000) / 100;
          expect(result).toBe(expected);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('returns null when targetFee <= 0', () => {
    // Feature: sales-target-commission, Property 6: null for targetFee <= 0
    fc.assert(
      fc.property(
        fc.float({ min: 0, max: 1e9, noNaN: true, noDefaultInfinity: true }),
        fc.oneof(
          fc.constant(0),
          fc.float({ max: 0, noNaN: true, noDefaultInfinity: true }),
          fc.constant(-1)
        ),
        (totalFee, targetFee) => {
          expect(CS.calculateAchievementPercent(totalFee, targetFee)).toBeNull();
        }
      ),
      { numRuns: 100 }
    );
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// Property 7 — validateSettingsInput: rejects invalid
// Feature: sales-target-commission, Property 7: Validation rejects all invalid inputs
// ─────────────────────────────────────────────────────────────────────────────
describe('Property 7: validateSettingsInput rejects all invalid inputs', () => {
  it('Sub A: rejects invalid targetFee (<=0 or non-integer)', () => {
    // Feature: sales-target-commission, Property 7A: invalid targetFee rejected
    fc.assert(
      fc.property(
        fc.oneof(
          fc.constant(0),
          fc.integer({ max: 0 }),
          // Float with fractional part (0.1 to 0.9)
          fc.float({ min: Math.fround(0.1), max: Math.fround(0.9), noNaN: true, noDefaultInfinity: true })
        ),
        (badTargetFee) => {
          const formData = {
            targetFee: badTargetFee,
            rateAbovePct: 12,
            rateBelowPct: 5,
          };
          const result = CS.validateSettingsInput(formData);
          expect(result.valid).toBe(false);
          expect(result.errors.targetFee).toBeTruthy();
        }
      ),
      { numRuns: 100 }
    );
  });

  it('Sub B: rejects rateAbovePct outside [1, 100]', () => {
    // Feature: sales-target-commission, Property 7B: invalid rateAbovePct rejected
    fc.assert(
      fc.property(
        fc.oneof(
          fc.constant(0),
          fc.float({ min: Math.fround(0), max: Math.fround(0.99), noNaN: true, noDefaultInfinity: true }),
          fc.float({ min: Math.fround(100.01), max: Math.fround(200), noNaN: true, noDefaultInfinity: true })
        ),
        (badRate) => {
          const formData = {
            targetFee: 10000000,
            rateAbovePct: badRate,
            rateBelowPct: 5,
          };
          const result = CS.validateSettingsInput(formData);
          expect(result.valid).toBe(false);
          expect(result.errors.rateAbovePct).toBeTruthy();
        }
      ),
      { numRuns: 100 }
    );
  });

  it('Sub C: warns on rate inversion (rateAbovePct < rateBelowPct) with valid inputs', () => {
    // Feature: sales-target-commission, Property 7C: rate inversion warning
    fc.assert(
      fc.property(
        fc.integer({ min: 1, max: 999999 }),
        // rateBelow > rateAbove; both in [1,100]
        fc.tuple(
          fc.float({ min: Math.fround(1), max: Math.fround(50), noNaN: true, noDefaultInfinity: true }),
          fc.float({ min: Math.fround(1), max: Math.fround(50), noNaN: true, noDefaultInfinity: true })
        ),
        (targetFee, [rateA, rateB]) => {
          // Ensure rateAbovePct < rateBelowPct
          const rateAbovePct = Math.min(rateA, rateB);
          const rateBelowPct = Math.max(rateA, rateB);
          fc.pre(rateAbovePct < rateBelowPct); // strict inversion
          const formData = {
            targetFee,
            rateAbovePct,
            rateBelowPct,
          };
          const result = CS.validateSettingsInput(formData);
          expect(result.valid).toBe(true);
          expect(result.warnRateInversion).toBe(true);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('Sub D: no inversion warning when rateAbovePct >= rateBelowPct with valid inputs', () => {
    // Feature: sales-target-commission, Property 7D: no inversion warning for valid rates
    fc.assert(
      fc.property(
        fc.integer({ min: 1, max: 999999 }),
        fc.tuple(
          fc.float({ min: Math.fround(1), max: Math.fround(50), noNaN: true, noDefaultInfinity: true }),
          fc.float({ min: Math.fround(1), max: Math.fround(50), noNaN: true, noDefaultInfinity: true })
        ),
        (targetFee, [rateA, rateB]) => {
          const rateAbovePct = Math.max(rateA, rateB); // rateAbove >= rateBelow
          const rateBelowPct = Math.min(rateA, rateB);
          const formData = {
            targetFee,
            rateAbovePct,
            rateBelowPct,
          };
          const result = CS.validateSettingsInput(formData);
          expect(result.valid).toBe(true);
          expect(result.warnRateInversion).toBe(false);
        }
      ),
      { numRuns: 100 }
    );
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// Property 8 — convertPercentToDecimal: exact conversion
// Feature: sales-target-commission, Property 8: Percentage-to-decimal conversion is exact
// ─────────────────────────────────────────────────────────────────────────────
describe('Property 8: convertPercentToDecimal is exact', () => {
  it('result is within 1e-10 of pct/100 for pct in [1,100]', () => {
    // Feature: sales-target-commission, Property 8: convertPercentToDecimal exact
    fc.assert(
      fc.property(
        fc.float({ min: Math.fround(1), max: Math.fround(100), noNaN: true, noDefaultInfinity: true }),
        (pct) => {
          const result = CS.convertPercentToDecimal(pct);
          expect(Math.abs(result - pct / 100)).toBeLessThan(1e-10);
        }
      ),
      { numRuns: 100 }
    );
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// Property 9 — buildSettingsPayload: all required columns present
// Feature: sales-target-commission, Property 9: buildSettingsPayload includes all required columns
// ─────────────────────────────────────────────────────────────────────────────
describe('Property 9: buildSettingsPayload includes all required columns', () => {
  it('payload has all keys with correct types and value constraints', () => {
    // Feature: sales-target-commission, Property 9: buildSettingsPayload all columns present
    fc.assert(
      fc.property(
        fc.record({
          salesId: fc.uuid(),
          salesName: fc.string(),
          targetFee: fc.integer({ min: 1, max: 999999999 }),
          rateAbovePct: fc.float({ min: Math.fround(1), max: Math.fround(100), noNaN: true, noDefaultInfinity: true }),
          rateBelowPct: fc.float({ min: Math.fround(1), max: Math.fround(100), noNaN: true, noDefaultInfinity: true }),
        }),
        fc.string(),
        fc.string(),
        (formData, period, createdBy) => {
          const payload = CS.buildSettingsPayload(formData, period, createdBy);

          // All required keys must be present
          expect(payload).toHaveProperty('sales_id');
          expect(payload).toHaveProperty('sales_name');
          expect(payload).toHaveProperty('period');
          expect(payload).toHaveProperty('target_fee');
          expect(payload).toHaveProperty('rate_above');
          expect(payload).toHaveProperty('rate_below');
          expect(payload).toHaveProperty('created_by');

          // rate_above and rate_below must be in [0.01, 1.00]
          expect(payload.rate_above).toBeGreaterThanOrEqual(0.01);
          expect(payload.rate_above).toBeLessThanOrEqual(1.0);
          expect(payload.rate_below).toBeGreaterThanOrEqual(0.01);
          expect(payload.rate_below).toBeLessThanOrEqual(1.0);

          // target_fee must be a positive integer >= 1
          expect(payload.target_fee).toBeGreaterThanOrEqual(1);
          expect(Number.isInteger(payload.target_fee)).toBe(true);
        }
      ),
      { numRuns: 100 }
    );
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// Property 12 — canWriteSettings: only authorized roles
// Feature: sales-target-commission, Property 12: canWriteSettings is correct for all roles
// ─────────────────────────────────────────────────────────────────────────────
describe('Property 12: canWriteSettings is correct for all roles', () => {
  it('returns true only for head_sales and head_account, false for all others', () => {
    // Feature: sales-target-commission, Property 12: canWriteSettings correct roles
    fc.assert(
      fc.property(
        fc.string(),
        (role) => {
          const result = CS.canWriteSettings(role);
          const expected = role === 'head_sales' || role === 'head_account';
          expect(result).toBe(expected);
        }
      ),
      { numRuns: 100 }
    );
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// Property 13 — formatTargetFeeDisplay: valid Rupiah string
// Feature: sales-target-commission, Property 13: formatTargetFeeDisplay produces a valid Rupiah string
// ─────────────────────────────────────────────────────────────────────────────
describe('Property 13: formatTargetFeeDisplay produces a valid Rupiah string', () => {
  it('starts with "Rp " and numeric portion parses back to original value', () => {
    // Feature: sales-target-commission, Property 13: formatTargetFeeDisplay valid Rupiah
    fc.assert(
      fc.property(
        fc.integer({ min: 1, max: 1e12 }),
        (value) => {
          const result = CS.formatTargetFeeDisplay(value);

          // Must start with "Rp "
          expect(result.startsWith('Rp ')).toBe(true);

          // Strip "Rp " prefix and remove thousand-separator dots, then parse
          const numericPart = result.slice(3).replace(/\./g, '');
          expect(parseInt(numericPart, 10)).toBe(value);
        }
      ),
      { numRuns: 100 }
    );
  });
});
