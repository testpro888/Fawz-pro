/**
 * Saham Input Validation Module
 * Validates transaction form inputs before submission.
 * 
 * Requirements: 2.3, 2.4, 2.7
 */
(function () {
  'use strict';

  var MAX_VALUE = 999999999999.99;

  /**
   * Validates a transaction input object.
   * @param {object} input - { tanggal, client_id, client_name, volume, fee }
   * @returns {{ valid: boolean, errors: string[] }}
   */
  function validateTransactionInput(input) {
    var errors = [];
    var tanggal = input.tanggal;
    var client_id = input.client_id;
    var client_name = input.client_name;
    var volume = input.volume;
    var fee = input.fee;

    // Validate required fields (must be non-empty and non-whitespace)
    if (!tanggal || typeof tanggal !== 'string' || tanggal.trim() === '') {
      errors.push('Field tanggal wajib diisi');
    }
    if (!client_id || typeof client_id !== 'string' || client_id.trim() === '') {
      errors.push('Field client_id wajib diisi');
    }
    if (!client_name || typeof client_name !== 'string' || client_name.trim() === '') {
      errors.push('Field client_name wajib diisi');
    }

    // Validate volume: must be numeric, >= 0, <= 999999999999.99
    if (!isValidNumeric(volume)) {
      errors.push('Nilai harus antara 0 dan 999.999.999.999,99');
    }

    // Validate fee: must be numeric, >= 0, <= 999999999999.99
    if (!isValidNumeric(fee)) {
      errors.push('Nilai harus antara 0 dan 999.999.999.999,99');
    }

    return {
      valid: errors.length === 0,
      errors: errors
    };
  }

  /**
   * Checks if a value is a valid numeric within the allowed range.
   * @param {*} value - The value to validate (string or number)
   * @returns {boolean} true if valid numeric in range [0, 999999999999.99]
   */
  function isValidNumeric(value) {
    // Handle null/undefined/empty
    if (value === null || value === undefined || value === '') {
      return false;
    }

    // Convert to string for parsing
    var strValue = String(value).trim();

    // Reject empty after trim
    if (strValue === '') {
      return false;
    }

    // Parse as number
    var num = Number(strValue);

    // Must be a finite number (rejects NaN, Infinity, -Infinity)
    if (!isFinite(num)) {
      return false;
    }

    // Must be >= 0
    if (num < 0) {
      return false;
    }

    // Must be <= MAX_VALUE
    if (num > MAX_VALUE) {
      return false;
    }

    return true;
  }

  // Export via window.SahamValidation namespace
  window.SahamValidation = {
    validateTransactionInput: validateTransactionInput
  };
})();
