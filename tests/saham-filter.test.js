/**
 * Unit tests for Saham Filter Module
 * Tests getFilteredTransactions and getClientsForMonth functions.
 * Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.7
 */
const { getFilteredTransactions, getClientsForMonth } = require('../saham-filter.js');

describe('getFilteredTransactions', () => {
  const sampleData = [
    { id: '1', tanggal: '2026-03-02', client_id: 'C001', client_name: 'Alice', volume: 1000, fee: 10 },
    { id: '2', tanggal: '2026-03-05', client_id: 'C002', client_name: 'Bob', volume: 2000, fee: 20 },
    { id: '3', tanggal: '2026-03-10', client_id: 'C001', client_name: 'Alice', volume: 3000, fee: 30 },
    { id: '4', tanggal: '2026-04-01', client_id: 'C001', client_name: 'Alice', volume: 4000, fee: 40 },
    { id: '5', tanggal: '2026-04-15', client_id: 'C003', client_name: 'Charlie', volume: 5000, fee: 50 },
  ];

  test('filters by month only - returns transactions within selected month (Req 3.2)', () => {
    const result = getFilteredTransactions(sampleData, '2026-03', null);
    expect(result).toHaveLength(3);
    expect(result.every(r => r.tanggal.startsWith('2026-03'))).toBe(true);
  });

  test('filters by month and client - returns only matching rows (Req 3.4)', () => {
    const result = getFilteredTransactions(sampleData, '2026-03', 'C001');
    expect(result).toHaveLength(2);
    expect(result.every(r => r.client_id === 'C001' && r.tanggal.startsWith('2026-03'))).toBe(true);
  });

  test('all clients shown when clientId is null (Req 3.5)', () => {
    const result = getFilteredTransactions(sampleData, '2026-03', null);
    const clientIds = new Set(result.map(r => r.client_id));
    expect(clientIds.has('C001')).toBe(true);
    expect(clientIds.has('C002')).toBe(true);
  });

  test('all clients shown when clientId is empty string (Req 3.5)', () => {
    const result = getFilteredTransactions(sampleData, '2026-03', '');
    expect(result).toHaveLength(3);
  });

  test('returns empty array when no data matches month (Req 3.7)', () => {
    const result = getFilteredTransactions(sampleData, '2026-12', null);
    expect(result).toHaveLength(0);
  });

  test('returns empty array when no data matches client in month (Req 3.7)', () => {
    const result = getFilteredTransactions(sampleData, '2026-03', 'C999');
    expect(result).toHaveLength(0);
  });

  test('returns all data when month is empty/null', () => {
    const result = getFilteredTransactions(sampleData, '', null);
    expect(result).toHaveLength(5);
  });

  test('handles empty transaction array', () => {
    const result = getFilteredTransactions([], '2026-03', null);
    expect(result).toHaveLength(0);
  });

  test('handles transactions with null tanggal gracefully', () => {
    const data = [
      { id: '1', tanggal: null, client_id: 'C001', client_name: 'Alice', volume: 1000, fee: 10 },
      { id: '2', tanggal: '2026-03-05', client_id: 'C002', client_name: 'Bob', volume: 2000, fee: 20 },
    ];
    const result = getFilteredTransactions(data, '2026-03', null);
    expect(result).toHaveLength(1);
    expect(result[0].client_id).toBe('C002');
  });
});

describe('getClientsForMonth', () => {
  const sampleData = [
    { id: '1', tanggal: '2026-03-02', client_id: 'C001', client_name: 'Alice', volume: 1000, fee: 10 },
    { id: '2', tanggal: '2026-03-05', client_id: 'C002', client_name: 'Bob', volume: 2000, fee: 20 },
    { id: '3', tanggal: '2026-03-10', client_id: 'C001', client_name: 'Alice', volume: 3000, fee: 30 },
    { id: '4', tanggal: '2026-04-01', client_id: 'C001', client_name: 'Alice', volume: 4000, fee: 40 },
    { id: '5', tanggal: '2026-04-15', client_id: 'C003', client_name: 'Charlie', volume: 5000, fee: 50 },
  ];

  test('returns distinct clients for selected month (Req 3.3)', () => {
    const clients = getClientsForMonth(sampleData, '2026-03');
    expect(clients).toHaveLength(2);
    const ids = clients.map(c => c.client_id);
    expect(ids).toContain('C001');
    expect(ids).toContain('C002');
  });

  test('does not include clients from other months (Req 3.3)', () => {
    const clients = getClientsForMonth(sampleData, '2026-03');
    const ids = clients.map(c => c.client_id);
    expect(ids).not.toContain('C003'); // C003 only has April data
  });

  test('returns clients sorted by client_name ascending', () => {
    const clients = getClientsForMonth(sampleData, '2026-03');
    expect(clients[0].client_name).toBe('Alice');
    expect(clients[1].client_name).toBe('Bob');
  });

  test('returns empty array when no transactions in month', () => {
    const clients = getClientsForMonth(sampleData, '2026-12');
    expect(clients).toHaveLength(0);
  });

  test('handles duplicate client entries - returns distinct only', () => {
    // C001 appears twice in March but should only be listed once
    const clients = getClientsForMonth(sampleData, '2026-03');
    const c001Entries = clients.filter(c => c.client_id === 'C001');
    expect(c001Entries).toHaveLength(1);
  });

  test('handles empty transaction array', () => {
    const clients = getClientsForMonth([], '2026-03');
    expect(clients).toHaveLength(0);
  });

  test('uses client_id as fallback when client_name is missing', () => {
    const data = [
      { id: '1', tanggal: '2026-03-02', client_id: 'C001', client_name: '', volume: 1000, fee: 10 },
    ];
    const clients = getClientsForMonth(data, '2026-03');
    expect(clients).toHaveLength(1);
    expect(clients[0].client_name).toBe('C001'); // Falls back to client_id
  });
});
