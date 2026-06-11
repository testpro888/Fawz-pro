/**
 * Saham Holidays Module
 * Manages 2026 Indonesian national holidays and cuti bersama for trading day classification.
 * Exports via window.SahamHolidays namespace.
 */
(function () {
  'use strict';

  /**
   * Set of all 2026 national holidays and cuti bersama dates in 'YYYY-MM-DD' format.
   */
  var HOLIDAYS_2026 = new Set([
    '2026-01-01', // Tahun Baru
    '2026-01-27', // Isra Miraj
    '2026-01-28', '2026-01-29', // Tahun Baru Imlek
    '2026-03-20', // Hari Raya Nyepi
    '2026-03-29', // Wafat Isa Almasih
    '2026-04-18', // Hari Raya Idul Fitri
    '2026-05-01', // Hari Buruh
    '2026-05-12', // Hari Raya Waisak
    '2026-05-29', // Kenaikan Isa Almasih
    '2026-06-01', // Hari Lahir Pancasila
    '2026-06-06', // Cuti Bersama
    '2026-06-07', // Idul Adha
    '2026-06-08', '2026-06-09', '2026-06-10',
    '2026-06-11', '2026-06-12', '2026-06-13', // Cuti Bersama
    '2026-07-07', // Tahun Baru Islam
    '2026-08-17', // Hari Kemerdekaan
    '2026-09-22', // Maulid Nabi
    '2026-10-02', // Hari Batik
    '2026-12-25', // Natal
    '2026-12-26'  // Cuti Bersama Natal
  ]);

  /**
   * Determines if a given date is a non-trading day.
   * Returns true for Saturdays, Sundays, or dates in HOLIDAYS_2026.
   *
   * @param {string} dateStr - Date in 'YYYY-MM-DD' format
   * @returns {boolean} true if the date is a non-trading day
   */
  function isNonTradingDay(dateStr) {
    if (HOLIDAYS_2026.has(dateStr)) {
      return true;
    }
    // Parse the date string to check day of week
    var parts = dateStr.split('-');
    var year = parseInt(parts[0], 10);
    var month = parseInt(parts[1], 10) - 1; // JS months are 0-indexed
    var day = parseInt(parts[2], 10);
    var date = new Date(year, month, day);
    var dayOfWeek = date.getDay();
    // 0 = Sunday, 6 = Saturday
    return dayOfWeek === 0 || dayOfWeek === 6;
  }

  /**
   * Returns an array of day numbers (1-based) that are non-trading days in the given month.
   *
   * @param {number} year - The year (e.g. 2026)
   * @param {number} month - The month (1-12)
   * @returns {number[]} Array of day numbers that are non-trading days
   */
  function getNonTradingDaysInMonth(year, month) {
    var nonTradingDays = [];
    // Get the number of days in the month
    var daysInMonth = new Date(year, month, 0).getDate();

    for (var day = 1; day <= daysInMonth; day++) {
      var dateStr = year + '-' + String(month).padStart(2, '0') + '-' + String(day).padStart(2, '0');
      if (isNonTradingDay(dateStr)) {
        nonTradingDays.push(day);
      }
    }

    return nonTradingDays;
  }

  /**
   * Returns the count of trading days in the given month.
   *
   * @param {number} year - The year (e.g. 2026)
   * @param {number} month - The month (1-12)
   * @returns {number} Count of trading days
   */
  function getTradingDaysInMonth(year, month) {
    var daysInMonth = new Date(year, month, 0).getDate();
    var nonTradingCount = getNonTradingDaysInMonth(year, month).length;
    return daysInMonth - nonTradingCount;
  }

  // Export via window.SahamHolidays namespace
  window.SahamHolidays = {
    HOLIDAYS_2026: HOLIDAYS_2026,
    isNonTradingDay: isNonTradingDay,
    getNonTradingDaysInMonth: getNonTradingDaysInMonth,
    getTradingDaysInMonth: getTradingDaysInMonth
  };
})();
