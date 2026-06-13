import { describe, it, expect, beforeAll } from 'vitest';

/**
 * Unit/example-based tests for js/commission-settings.js
 * Validates Requirements: 2.6, 2.7, 2.8, 2.9, 3.1, 3.6, 5.1, 5.2, 5.3, 5.4,
 *                         9.1, 9.5, 10.1, 10.2, 10.3, 10.4, 10.5
 *
 * Because commission-settings.js uses IIFE + window.CommissionSettings,
 * we set up global.window before dynamic import so the IIFE can attach itself.
 */

// Set up global.window before importing the module
globalThis.window = {};

// CS will be populated in beforeAll
let CS;

beforeAll(async () => {
  await import('../js/commission-settings.js');
  CS = globalThis.window.CommissionSettings;
});

// ---------------------------------------------------------------------------
// 3.1 resolveEffectiveSettings — concrete scenarios
// Requirements: 5.1, 5.2
// ---------------------------------------------------------------------------
describe('resolveEffectiveSettings', () => {
  it('empty array → returns Global_Default with isDefault: true', () => {
    const result = CS.resolveEffectiveSettings([], 'any-id', '2025-01');
    expect(result.isDefault).toBe(true);
    expect(result.target_fee).toBe(10_000_000);
    expect(result.rate_above).toBe(0.12);
    expect(result.rate_below).toBe(0.05);
  });

  it('single matching record → returns that record with isDefault: false', () => {
    const record = {
      sales_id: 'abc-123',
      period: '2025-06',
      target_fee: 20_000_000,
      rate_above: 0.15,
      rate_below: 0.08
    };
    const result = CS.resolveEffectiveSettings([record], 'abc-123', '2025-06');
    expect(result.isDefault).toBe(false);
    expect(result.target_fee).toBe(20_000_000);
    expect(result.rate_above).toBe(0.15);
    expect(result.rate_below).toBe(0.08);
  });

  it('array with multiple records, only one matches by sales_id+period → returns correct one', () => {
    const records = [
      { sales_id: 'id-1', period: '2025-06', target_fee: 5_000_000, rate_above: 0.10, rate_below: 0.04 },
      { sales_id: 'id-2', period: '2025-06', target_fee: 15_000_000, rate_above: 0.20, rate_below: 0.09 },
      { sales_id: 'id-3', period: '2025-06', target_fee: 25_000_000, rate_above: 0.25, rate_below: 0.11 }
    ];
    const result = CS.resolveEffectiveSettings(records, 'id-2', '2025-06');
    expect(result.isDefault).toBe(false);
    expect(result.target_fee).toBe(15_000_000);
    expect(result.rate_above).toBe(0.20);
    expect(result.rate_below).toBe(0.09);
  });

  it('matching sales_id but different period → returns Global_Default', () => {
    const record = {
      sales_id: 'abc-123',
      period: '2025-01',
      target_fee: 20_000_000,
      rate_above: 0.15,
      rate_below: 0.08
    };
    const result = CS.resolveEffectiveSettings([record], 'abc-123', '2025-06');
    expect(result.isDefault).toBe(true);
    expect(result.target_fee).toBe(10_000_000);
  });
});

// ---------------------------------------------------------------------------
// 3.2 calculateCommission — boundary scenarios
// Requirements: 5.3, 5.4
// ---------------------------------------------------------------------------
describe('calculateCommission', () => {
  it('totalFee === target_fee (boundary) → hitTarget: true, uses rate_above', () => {
    const settings = { target_fee: 10_000_000, rate_above: 0.12, rate_below: 0.05 };
    const result = CS.calculateCommission(10_000_000, settings);
    expect(result.hitTarget).toBe(true);
    expect(result.rate).toBe(0.12);
    expect(result.commission).toBe(10_000_000 * 0.12);
  });

  it('totalFee = 0 → hitTarget: false, commission = 0, uses rate_below', () => {
    const settings = { target_fee: 10_000_000, rate_above: 0.12, rate_below: 0.05 };
    const result = CS.calculateCommission(0, settings);
    expect(result.hitTarget).toBe(false);
    expect(result.rate).toBe(0.05);
    expect(result.commission).toBe(0);
  });

  it('totalFee=15_000_000, target=10_000_000, rate_above=0.12 → commission=1_800_000', () => {
    const settings = { target_fee: 10_000_000, rate_above: 0.12, rate_below: 0.05 };
    const result = CS.calculateCommission(15_000_000, settings);
    expect(result.hitTarget).toBe(true);
    expect(result.commission).toBe(1_800_000);
  });

  it('totalFee=8_000_000, target=10_000_000, rate_below=0.05 → commission=400_000', () => {
    const settings = { target_fee: 10_000_000, rate_above: 0.12, rate_below: 0.05 };
    const result = CS.calculateCommission(8_000_000, settings);
    expect(result.hitTarget).toBe(false);
    expect(result.commission).toBe(400_000);
  });
});

// ---------------------------------------------------------------------------
// 3.3 validateSettingsInput — specific examples
// Requirements: 2.6, 2.7, 2.8, 2.9, 9.1
// ---------------------------------------------------------------------------
describe('validateSettingsInput', () => {
  it('valid inputs {targetFee:10_000_000, rateAbovePct:12, rateBelowPct:5} → {valid:true, warnRateInversion:false}', () => {
    const result = CS.validateSettingsInput({
      targetFee: 10_000_000,
      rateAbovePct: 12,
      rateBelowPct: 5
    });
    expect(result.valid).toBe(true);
    expect(result.warnRateInversion).toBe(false);
  });

  it('targetFee=0 → valid:false, errors.targetFee defined', () => {
    const result = CS.validateSettingsInput({
      targetFee: 0,
      rateAbovePct: 12,
      rateBelowPct: 5
    });
    expect(result.valid).toBe(false);
    expect(result.errors.targetFee).toBeDefined();
  });

  it('targetFee=-1 → valid:false', () => {
    const result = CS.validateSettingsInput({
      targetFee: -1,
      rateAbovePct: 12,
      rateBelowPct: 5
    });
    expect(result.valid).toBe(false);
  });

  it('rateAbovePct=101 → valid:false, errors.rateAbovePct defined', () => {
    const result = CS.validateSettingsInput({
      targetFee: 10_000_000,
      rateAbovePct: 101,
      rateBelowPct: 5
    });
    expect(result.valid).toBe(false);
    expect(result.errors.rateAbovePct).toBeDefined();
  });

  it('rateAbovePct=0 → valid:false', () => {
    const result = CS.validateSettingsInput({
      targetFee: 10_000_000,
      rateAbovePct: 0,
      rateBelowPct: 5
    });
    expect(result.valid).toBe(false);
  });

  it('rateAbovePct=3, rateBelowPct=10 → valid:true, warnRateInversion:true', () => {
    const result = CS.validateSettingsInput({
      targetFee: 10_000_000,
      rateAbovePct: 3,
      rateBelowPct: 10
    });
    expect(result.valid).toBe(true);
    expect(result.warnRateInversion).toBe(true);
  });

  it('empty string targetFee → valid:false', () => {
    const result = CS.validateSettingsInput({
      targetFee: '',
      rateAbovePct: 12,
      rateBelowPct: 5
    });
    expect(result.valid).toBe(false);
  });
});

// ---------------------------------------------------------------------------
// 3.4 buildSettingsPayload — specific examples
// Requirements: 3.1, 3.6
// ---------------------------------------------------------------------------
describe('buildSettingsPayload', () => {
  const baseFormData = {
    salesId: 'sales-uuid-001',
    salesName: 'Budi Santoso',
    targetFee: 10_000_000,
    rateAbovePct: 12,
    rateBelowPct: 5
  };

  it('rateAbovePct=12 → payload.rate_above === 0.12', () => {
    const payload = CS.buildSettingsPayload(baseFormData, '2025-06', 'admin1');
    expect(payload.rate_above).toBeCloseTo(0.12, 10);
  });

  it('rateBelowPct=5 → payload.rate_below === 0.05', () => {
    const payload = CS.buildSettingsPayload(baseFormData, '2025-06', 'admin1');
    expect(payload.rate_below).toBeCloseTo(0.05, 10);
  });

  it('period and createdBy are copied verbatim', () => {
    const payload = CS.buildSettingsPayload(baseFormData, '2025-06', 'admin1');
    expect(payload.period).toBe('2025-06');
    expect(payload.created_by).toBe('admin1');
  });

  it('sales_id and sales_name from formData are in payload', () => {
    const payload = CS.buildSettingsPayload(baseFormData, '2025-06', 'admin1');
    expect(payload.sales_id).toBe('sales-uuid-001');
    expect(payload.sales_name).toBe('Budi Santoso');
  });
});

// ---------------------------------------------------------------------------
// 3.5 formatTargetFeeDisplay
// Requirements: 9.5, 10.1
// ---------------------------------------------------------------------------
describe('formatTargetFeeDisplay', () => {
  it('10_000_000 → "Rp 10.000.000"', () => {
    expect(CS.formatTargetFeeDisplay(10_000_000)).toBe('Rp 10.000.000');
  });

  it('1_500_000 → "Rp 1.500.000"', () => {
    expect(CS.formatTargetFeeDisplay(1_500_000)).toBe('Rp 1.500.000');
  });

  it('500_000 → "Rp 500.000"', () => {
    expect(CS.formatTargetFeeDisplay(500_000)).toBe('Rp 500.000');
  });
});

// ---------------------------------------------------------------------------
// 3.6 getAchievementStatus + calculateAchievementPercent
// Requirements: 10.2, 10.3, 10.4, 10.5
// ---------------------------------------------------------------------------
describe('getAchievementStatus', () => {
  it('(10_000_000, 10_000_000) → "TARGET_ACHIEVED"', () => {
    expect(CS.getAchievementStatus(10_000_000, 10_000_000)).toBe('TARGET_ACHIEVED');
  });

  it('(9_999_999, 10_000_000) → "BELOW_TARGET"', () => {
    expect(CS.getAchievementStatus(9_999_999, 10_000_000)).toBe('BELOW_TARGET');
  });

  it('(5_000_000, 0) → "INVALID_TARGET"', () => {
    expect(CS.getAchievementStatus(5_000_000, 0)).toBe('INVALID_TARGET');
  });
});

describe('calculateAchievementPercent', () => {
  it('(8_432_000, 10_000_000) → 84.32', () => {
    expect(CS.calculateAchievementPercent(8_432_000, 10_000_000)).toBe(84.32);
  });

  it('(5_000_000, 0) → null', () => {
    expect(CS.calculateAchievementPercent(5_000_000, 0)).toBeNull();
  });
});
