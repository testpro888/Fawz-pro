/**
 * Saham Data Aggregation Module
 * Pure functions that transform raw transaction arrays into structured grid data.
 * Handles aggregation by client+date, monthly totals, and summary calculations.
 *
 * Requirements: 1.2, 1.4, 1.6, 5.1, 5.2, 5.4
 */
(function () {
  'use strict';

  /**
   * Aggregates transactions by client and date.
   * Groups transactions by client_id, then sums volume and fee per day.
   * Multiple transactions for the same client on the same date are summed together (Req 1.6).
   *
   * @param {Array} transactions - Array of Transaction objects
   *   Each transaction: { id, tanggal, client_id, client_name, volume, fee, sales_name, catatan }
   * @returns {Map<string, object>} Map keyed by client_id, values are ClientRow objects:
   *   { client_id, client_name, sales_name, days: Map<number, { volume, fee }>, totalVolume, totalFee }
   */
  function aggregateByClientAndDate(transactions) {
    var clientMap = new Map();

    for (var i = 0; i < transactions.length; i++) {
      var tx = transactions[i];
      var clientId = tx.client_id;
      var volume = Number(tx.volume) || 0;
      var fee = Number(tx.fee) || 0;

      // Extract day number from tanggal (YYYY-MM-DD format)
      var day = parseInt(tx.tanggal.split('-')[2], 10);

      if (!clientMap.has(clientId)) {
        clientMap.set(clientId, {
          client_id: clientId,
          client_name: tx.client_name,
          sales_name: tx.sales_name,
          days: new Map(),
          totalVolume: 0,
          totalFee: 0
        });
      }

      var clientRow = clientMap.get(clientId);

      // Sum volume and fee for the same client+day (Req 1.6)
      if (clientRow.days.has(day)) {
        var existing = clientRow.days.get(day);
        existing.volume += volume;
        existing.fee += fee;
      } else {
        clientRow.days.set(day, { volume: volume, fee: fee });
      }

      // Accumulate totals (Req 1.4)
      clientRow.totalVolume += volume;
      clientRow.totalFee += fee;
    }

    return clientMap;
  }

  /**
   * Calculates the monthly total volume and fee for a single client row.
   * Returns the sum of all daily values (Req 1.4).
   *
   * @param {object} clientRow - A ClientRow object with a days Map
   * @returns {{ volume: number, fee: number }} Total volume and fee
   */
  function calculateMonthlyTotal(clientRow) {
    var totalVolume = 0;
    var totalFee = 0;

    clientRow.days.forEach(function (dayData) {
      totalVolume += dayData.volume;
      totalFee += dayData.fee;
    });

    return { volume: totalVolume, fee: totalFee };
  }

  /**
   * Calculates the monthly summary for a set of transactions.
   * Sums all volumes and fees, counts distinct active clients (Req 5.1, 5.4).
   *
   * @param {Array} transactions - Array of Transaction objects for the selected month
   * @returns {{ totalVolume: number, totalFee: number, activeClients: number }}
   */
  function calculateMonthlySummary(transactions) {
    var totalVolume = 0;
    var totalFee = 0;
    var clientIds = new Set();

    for (var i = 0; i < transactions.length; i++) {
      var tx = transactions[i];
      totalVolume += Number(tx.volume) || 0;
      totalFee += Number(tx.fee) || 0;
      clientIds.add(tx.client_id);
    }

    return {
      totalVolume: totalVolume,
      totalFee: totalFee,
      activeClients: clientIds.size
    };
  }

  /**
   * Calculates the YTD (Year-To-Date) summary.
   * Filters transactions from January 1 of the selected month's year through the
   * end of the selected month (inclusive), then sums volumes/fees and counts
   * distinct active clients (Req 5.2, 5.4).
   *
   * @param {Array} transactions - Array of ALL Transaction objects (not pre-filtered)
   * @param {string} selectedMonth - Month in 'YYYY-MM' format (e.g. '2026-03')
   * @returns {{ totalVolume: number, totalFee: number, activeClients: number }}
   */
  function calculateYTDSummary(transactions, selectedMonth) {
    var parts = selectedMonth.split('-');
    var year = parseInt(parts[0], 10);
    var month = parseInt(parts[1], 10);

    // YTD range: Jan 1 of the year through end of selected month
    var startDate = year + '-01-01';
    // End of selected month: last day of that month
    var lastDay = new Date(year, month, 0).getDate();
    var endDate = year + '-' + String(month).padStart(2, '0') + '-' + String(lastDay).padStart(2, '0');

    var totalVolume = 0;
    var totalFee = 0;
    var clientIds = new Set();

    for (var i = 0; i < transactions.length; i++) {
      var tx = transactions[i];
      var tanggal = tx.tanggal;

      // Filter: tanggal >= startDate AND tanggal <= endDate (string comparison works for YYYY-MM-DD)
      if (tanggal >= startDate && tanggal <= endDate) {
        totalVolume += Number(tx.volume) || 0;
        totalFee += Number(tx.fee) || 0;
        clientIds.add(tx.client_id);
      }
    }

    return {
      totalVolume: totalVolume,
      totalFee: totalFee,
      activeClients: clientIds.size
    };
  }

  // Export via window.SahamAggregation namespace
  window.SahamAggregation = {
    aggregateByClientAndDate: aggregateByClientAndDate,
    calculateMonthlyTotal: calculateMonthlyTotal,
    calculateMonthlySummary: calculateMonthlySummary,
    calculateYTDSummary: calculateYTDSummary
  };
})();
