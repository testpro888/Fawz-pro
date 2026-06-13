/**
 * Commission Settings Module
 * Pure functions untuk kalkulasi komisi, validasi, dan pengelolaan
 * pengaturan target fee per-sales di sistem Fawz Pro.
 *
 * Mengikuti pola IIFE + window namespace yang sama dengan saham-aggregation.js.
 *
 * Requirements: 2.3, 2.4, 2.6, 2.7, 2.8, 2.9, 3.1, 3.6, 5.1, 5.2, 5.3, 5.4,
 *               7.1, 7.2, 7.3, 9.1, 9.2, 9.5, 10.2, 10.3, 10.4, 10.5
 */
(function () {
  'use strict';

  /**
   * Nilai default global yang digunakan apabila tidak ada Settings_Record
   * spesifik untuk kombinasi sales dan periode tertentu.
   * Target: Rp 10.000.000, Rate ≥ target: 12%, Rate < target: 5%.
   */
  var GLOBAL_DEFAULT = {
    target_fee: 10_000_000,
    rate_above: 0.12,
    rate_below: 0.05,
    isDefault: true
  };

  /**
   * Mencari Settings_Record yang cocok untuk salesId dan period tertentu.
   * Jika tidak ditemukan, mengembalikan salinan dari GLOBAL_DEFAULT.
   *
   * @param {Array<Object>} settingsArray - Array of Settings_Record objects
   *   Setiap record: { sales_id, period, target_fee, rate_above, rate_below, ... }
   * @param {string} salesId - UUID sales yang dicari
   * @param {string} period  - Periode format 'YYYY-MM'
   * @returns {Object} EffectiveSettings: { target_fee, rate_above, rate_below, isDefault }
   */
  function resolveEffectiveSettings(settingsArray, salesId, period) {
    for (var i = 0; i < settingsArray.length; i++) {
      var record = settingsArray[i];
      if (record.sales_id === salesId && record.period === period) {
        return {
          target_fee: record.target_fee,
          rate_above: record.rate_above,
          rate_below: record.rate_below,
          isDefault: false
        };
      }
    }
    return { target_fee: GLOBAL_DEFAULT.target_fee, rate_above: GLOBAL_DEFAULT.rate_above, rate_below: GLOBAL_DEFAULT.rate_below, isDefault: true };
  }

  /**
   * Menghitung komisi berdasarkan total fee dan effective settings.
   * Menggunakan rate_above jika totalFee >= target_fee, rate_below jika tidak.
   *
   * @param {number} totalFee - Total fee sales dalam periode (Rupiah)
   * @param {Object} effectiveSettings - { target_fee, rate_above, rate_below }
   * @returns {{ commission: number, rate: number, hitTarget: boolean }}
   */
  function calculateCommission(totalFee, effectiveSettings) {
    var hitTarget = totalFee >= effectiveSettings.target_fee;
    var rate = hitTarget ? effectiveSettings.rate_above : effectiveSettings.rate_below;
    var commission = totalFee * rate;
    return { commission: commission, rate: rate, hitTarget: hitTarget };
  }

  /**
   * Menentukan status pencapaian target untuk ditampilkan sebagai badge.
   *
   * @param {number} totalFee  - Total fee sales dalam periode (Rupiah)
   * @param {number} targetFee - Target fee dari effective settings (Rupiah)
   * @returns {'TARGET_ACHIEVED' | 'BELOW_TARGET' | 'INVALID_TARGET'}
   */
  function getAchievementStatus(totalFee, targetFee) {
    if (!targetFee || targetFee <= 0 || !isFinite(targetFee)) {
      return 'INVALID_TARGET';
    }
    if (totalFee >= targetFee) {
      return 'TARGET_ACHIEVED';
    }
    return 'BELOW_TARGET';
  }

  /**
   * Menghitung persentase pencapaian target, dibulatkan ke dua desimal.
   * Mengembalikan null jika targetFee <= 0.
   *
   * @param {number} totalFee  - Total fee sales dalam periode (Rupiah)
   * @param {number} targetFee - Target fee dari effective settings (Rupiah)
   * @returns {number|null} Persentase pencapaian (misal: 84.32) atau null
   */
  function calculateAchievementPercent(totalFee, targetFee) {
    if (!targetFee || targetFee <= 0) {
      return null;
    }
    return Math.round((totalFee / targetFee) * 10000) / 100;
  }

  /**
   * Memvalidasi data form pengaturan komisi sebelum disimpan ke database.
   * targetFee harus berupa integer positif (≥ 1).
   * rateAbovePct dan rateBelowPct harus dalam rentang [1, 100].
   *
   * @param {Object} formData - { salesId, salesName, targetFee, rateAbovePct, rateBelowPct }
   * @returns {{ valid: boolean, errors: Object<string, string>, warnRateInversion: boolean }}
   */
  function validateSettingsInput(formData) {
    var errors = {};
    var valid = true;

    // Validasi targetFee: harus integer positif >= 1
    var targetFeeNum = Number(formData.targetFee);
    if (
      formData.targetFee === '' ||
      formData.targetFee === null ||
      formData.targetFee === undefined ||
      isNaN(targetFeeNum) ||
      !isFinite(targetFeeNum) ||
      targetFeeNum < 1 ||
      !Number.isInteger(targetFeeNum)
    ) {
      errors.targetFee = 'Target Fee harus lebih dari 0 dan berupa bilangan bulat';
      valid = false;
    }

    // Validasi rateAbovePct: harus dalam rentang [1, 100]
    var rateAboveNum = Number(formData.rateAbovePct);
    if (
      formData.rateAbovePct === '' ||
      formData.rateAbovePct === null ||
      formData.rateAbovePct === undefined ||
      isNaN(rateAboveNum) ||
      !isFinite(rateAboveNum) ||
      rateAboveNum < 1 ||
      rateAboveNum > 100
    ) {
      errors.rateAbovePct = 'Rate harus antara 1% hingga 100%';
      valid = false;
    }

    // Validasi rateBelowPct: harus dalam rentang [1, 100]
    var rateBelowNum = Number(formData.rateBelowPct);
    if (
      formData.rateBelowPct === '' ||
      formData.rateBelowPct === null ||
      formData.rateBelowPct === undefined ||
      isNaN(rateBelowNum) ||
      !isFinite(rateBelowNum) ||
      rateBelowNum < 1 ||
      rateBelowNum > 100
    ) {
      errors.rateBelowPct = 'Rate harus antara 1% hingga 100%';
      valid = false;
    }

    // Peringatan inversi rate: rate_above < rate_below (hanya jika keduanya valid)
    var warnRateInversion = false;
    if (valid && rateAboveNum < rateBelowNum) {
      warnRateInversion = true;
    }

    return { valid: valid, errors: errors, warnRateInversion: warnRateInversion };
  }

  /**
   * Mengonversi nilai persentase (misal: 12 atau "12.5") ke desimal (0.12 atau 0.125).
   *
   * @param {string|number} pct - Nilai persentase
   * @returns {number} Nilai desimal hasil konversi
   */
  function convertPercentToDecimal(pct) {
    return Number(pct) / 100;
  }

  /**
   * Memformat nilai numerik sebagai string mata uang Rupiah Indonesia.
   * Contoh: 10000000 → "Rp 10.000.000"
   *
   * @param {number} value - Nilai nominal dalam Rupiah
   * @returns {string} String terformat dengan pemisah ribuan gaya Indonesia
   */
  function formatTargetFeeDisplay(value) {
    return 'Rp ' + value.toLocaleString('id-ID');
  }

  /**
   * Membangun objek payload untuk operasi UPSERT ke tabel sales_commission_settings.
   * Konversi rateAbovePct dan rateBelowPct dari persentase ke desimal secara otomatis.
   *
   * @param {Object} formData  - { salesId, salesName, targetFee, rateAbovePct, rateBelowPct }
   * @param {string} period    - Periode format 'YYYY-MM'
   * @param {string} createdBy - Username pengguna yang sedang login
   * @returns {Object} Payload siap UPSERT ke database
   */
  function buildSettingsPayload(formData, period, createdBy) {
    return {
      sales_id: formData.salesId,
      sales_name: formData.salesName,
      period: period,
      target_fee: Number(formData.targetFee),
      rate_above: convertPercentToDecimal(formData.rateAbovePct),
      rate_below: convertPercentToDecimal(formData.rateBelowPct),
      created_by: createdBy
    };
  }

  /**
   * Memeriksa apakah role pengguna berwenang untuk menulis pengaturan komisi.
   * Hanya role 'head_sales' dan 'head_account' yang diizinkan.
   *
   * @param {string} role - Role pengguna dari session storage
   * @returns {boolean} true jika berwenang, false jika tidak
   */
  function canWriteSettings(role) {
    return role === 'head_sales' || role === 'head_account';
  }

  // Ekspor semua fungsi dan konstanta via window.CommissionSettings
  window.CommissionSettings = {
    GLOBAL_DEFAULT: GLOBAL_DEFAULT,
    resolveEffectiveSettings: resolveEffectiveSettings,
    calculateCommission: calculateCommission,
    getAchievementStatus: getAchievementStatus,
    calculateAchievementPercent: calculateAchievementPercent,
    validateSettingsInput: validateSettingsInput,
    convertPercentToDecimal: convertPercentToDecimal,
    formatTargetFeeDisplay: formatTargetFeeDisplay,
    buildSettingsPayload: buildSettingsPayload,
    canWriteSettings: canWriteSettings
  };
})();
