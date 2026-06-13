/**
 * Saham Filter Module
 * Provides filtering functions for saham transaction data.
 * Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.7
 */
'use strict';

/**
 * Filters transactions by month and optionally by client ID.
 *
 * @param {Array} allTransactions - Array of transaction objects with tanggal and client_id fields
 * @param {string} month - Month string in 'YYYY-MM' format; pass empty string or null for no month filter
 * @param {string|null} clientId - Client ID to filter by; pass null or empty string for all clients
 * @returns {Array} Filtered array of transactions
 */
function getFilteredTransactions(allTransactions, month, clientId) {
  var result = allTransactions;
  if (month) {
    result = result.filter(function (r) {
      return r.tanggal && r.tanggal.startsWith(month);
    });
  }
  if (clientId) {
    result = result.filter(function (r) {
      return r.client_id === clientId;
    });
  }
  return result;
}

/**
 * Returns a distinct, sorted list of clients who have transactions in the given month.
 *
 * @param {Array} transactions - Array of transaction objects
 * @param {string} month - Month string in 'YYYY-MM' format
 * @returns {Array} Sorted array of distinct client objects { client_id, client_name }
 */
function getClientsForMonth(transactions, month) {
  var monthTransactions = transactions.filter(function (r) {
    return r.tanggal && r.tanggal.startsWith(month);
  });
  var clientMap = {};
  for (var i = 0; i < monthTransactions.length; i++) {
    var tx = monthTransactions[i];
    if (tx.client_id && !clientMap[tx.client_id]) {
      clientMap[tx.client_id] = {
        client_id: tx.client_id,
        client_name: tx.client_name || tx.client_id,
      };
    }
  }
  var clients = Object.keys(clientMap).map(function (key) {
    return clientMap[key];
  });
  clients.sort(function (a, b) {
    return (a.client_name || '').localeCompare(b.client_name || '');
  });
  return clients;
}

module.exports = { getFilteredTransactions, getClientsForMonth };
