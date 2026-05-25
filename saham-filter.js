/**
 * Saham Filter Module
 * Pure functions for filtering transactions by month and client.
 * Used by the calendar grid view to apply month/client filter controls.
 *
 * Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7
 */
(function (root) {
  'use strict';

  /**
   * Filters transactions by month and optionally by client_id.
   * - When month is provided, only transactions with tanggal starting with that month are included (Req 3.2)
   * - When clientId is provided, only transactions matching that client_id are included (Req 3.4)
   * - When clientId is null/empty, all clients for the month are shown (Req 3.5)
   *
   * @param {Array} allTransactions - Array of Transaction objects
   * @param {string} month - Month in 'YYYY-MM' format (e.g. '2026-03')
   * @param {string|null} clientId - Client ID to filter by, or null/empty for all clients
   * @returns {Array} Filtered transactions
   */
  function getFilteredTransactions(allTransactions, month, clientId) {
    var result = allTransactions;

    // Filter by month: only rows where tanggal falls within selected month (Req 3.2)
    if (month) {
      result = result.filter(function (r) {
        return r.tanggal && r.tanggal.startsWith(month);
      });
    }

    // Filter by client: only rows matching selected client_id (Req 3.4)
    if (clientId) {
      result = result.filter(function (r) {
        return r.client_id === clientId;
      });
    }

    return result;
  }

  /**
   * Returns distinct clients that have transactions in the given month.
   * The client dropdown lists all clients in saham_transaksi for the selected month (Req 3.3).
   *
   * @param {Array} transactions - Array of ALL Transaction objects (not pre-filtered)
   * @param {string} month - Month in 'YYYY-MM' format (e.g. '2026-03')
   * @returns {Array} Array of { client_id, client_name } objects, sorted by client_name ascending
   */
  function getClientsForMonth(transactions, month) {
    // First filter to only transactions in the given month
    var monthTransactions = transactions.filter(function (r) {
      return r.tanggal && r.tanggal.startsWith(month);
    });

    // Build a map of distinct clients
    var clientMap = {};
    for (var i = 0; i < monthTransactions.length; i++) {
      var tx = monthTransactions[i];
      if (tx.client_id && !clientMap[tx.client_id]) {
        clientMap[tx.client_id] = {
          client_id: tx.client_id,
          client_name: tx.client_name || tx.client_id
        };
      }
    }

    // Convert to array and sort by client_name
    var clients = Object.keys(clientMap).map(function (key) {
      return clientMap[key];
    });
    clients.sort(function (a, b) {
      return (a.client_name || '').localeCompare(b.client_name || '');
    });

    return clients;
  }

  var exports = {
    getFilteredTransactions: getFilteredTransactions,
    getClientsForMonth: getClientsForMonth
  };

  // Export for both browser (window.SahamFilter) and Node.js (module.exports)
  if (typeof module !== 'undefined' && module.exports) {
    module.exports = exports;
  }
  if (typeof root !== 'undefined' && root !== null) {
    root.SahamFilter = exports;
  }
})(typeof window !== 'undefined' ? window : (typeof global !== 'undefined' ? global : this));
