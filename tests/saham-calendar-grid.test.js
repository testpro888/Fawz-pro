/**
 * Tests for the Calendar Grid Renderer (renderCalendarGrid)
 * Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 4.4
 */
import { describe, it, expect, beforeEach } from 'vitest';

// Simulate browser environment for the renderCalendarGrid function
function formatRp(n) {
  return 'Rp ' + (n || 0).toLocaleString('id-ID');
}

/**
 * Extracted renderCalendarGrid function for testing.
 * This mirrors the implementation in saham.html.
 */
function renderCalendarGrid(clientRows, year, month, nonTradingDays) {
  var daysInMonth = new Date(year, month, 0).getDate();
  var nonTradingSet = new Set(nonTradingDays);

  var html = '<table style="min-width:100%;border-collapse:collapse;font-size:0.75rem;">';
  html += '<thead><tr>';
  html += '<th style="padding:8px 6px;background:var(--navy);color:#fff;white-space:nowrap;">No</th>';
  html += '<th style="padding:8px 6px;background:var(--navy);color:#fff;white-space:nowrap;">Client_Code</th>';
  html += '<th style="padding:8px 6px;background:var(--navy);color:#fff;white-space:nowrap;">Customer Name</th>';
  html += '<th style="padding:8px 6px;background:var(--navy);color:#fff;white-space:nowrap;">Sales_Code</th>';

  for (var d = 1; d <= daysInMonth; d++) {
    var bgStyle = nonTradingSet.has(d) ? 'background:#e74c3c;color:#fff;' : 'background:var(--navy);color:#fff;';
    html += '<th style="padding:8px 4px;text-align:center;white-space:nowrap;' + bgStyle + '">' + d + '</th>';
  }

  html += '<th style="padding:8px 6px;background:var(--navy);color:#fff;white-space:nowrap;">Total</th>';
  html += '</tr></thead>';

  html += '<tbody>';

  var rows = [];
  if (clientRows instanceof Map) {
    clientRows.forEach(function(row) { rows.push(row); });
  } else if (Array.isArray(clientRows)) {
    rows = clientRows;
  } else {
    for (var key in clientRows) {
      if (clientRows.hasOwnProperty(key)) rows.push(clientRows[key]);
    }
  }

  if (rows.length === 0) {
    html += '<tr><td colspan="' + (daysInMonth + 5) + '" style="text-align:center;padding:40px 20px;color:#bbb;">Tidak ada data transaksi untuk bulan ini</td></tr>';
  } else {
    for (var i = 0; i < rows.length; i++) {
      var row = rows[i];
      var no = i + 1;

      html += '<tr style="border-bottom:none;">';
      html += '<td rowspan="2" style="padding:8px 6px;text-align:center;vertical-align:middle;border-bottom:1px solid #f0f0f5;font-weight:600;">' + no + '</td>';
      html += '<td rowspan="2" style="padding:8px 6px;vertical-align:middle;border-bottom:1px solid #f0f0f5;font-weight:600;">' + (row.client_id || '') + '</td>';
      html += '<td rowspan="2" style="padding:8px 6px;vertical-align:middle;border-bottom:1px solid #f0f0f5;">' + (row.client_name || '') + '</td>';
      html += '<td rowspan="2" style="padding:8px 6px;vertical-align:middle;border-bottom:1px solid #f0f0f5;">' + (row.sales_name || '') + '</td>';

      var totalVolume = 0;
      for (var d = 1; d <= daysInMonth; d++) {
        var dayData = row.days instanceof Map ? row.days.get(d) : (row.days && row.days[d]);
        if (dayData && dayData.volume) {
          html += '<td style="padding:6px 4px;text-align:right;font-size:0.7rem;white-space:nowrap;">' + formatRp(dayData.volume) + '</td>';
          totalVolume += dayData.volume;
        } else {
          html += '<td style="padding:6px 4px;"></td>';
        }
      }
      html += '<td style="padding:8px 6px;text-align:right;font-weight:700;white-space:nowrap;background:#f9f9ff;">' + formatRp(totalVolume) + '</td>';
      html += '</tr>';

      html += '<tr style="border-bottom:1px solid #f0f0f5;">';
      var totalFee = 0;
      for (var d = 1; d <= daysInMonth; d++) {
        var dayData = row.days instanceof Map ? row.days.get(d) : (row.days && row.days[d]);
        if (dayData && dayData.fee) {
          html += '<td style="padding:6px 4px;text-align:right;font-size:0.7rem;color:var(--green);white-space:nowrap;">' + formatRp(dayData.fee) + '</td>';
          totalFee += dayData.fee;
        } else {
          html += '<td style="padding:6px 4px;"></td>';
        }
      }
      html += '<td style="padding:8px 6px;text-align:right;font-weight:700;color:var(--green);white-space:nowrap;background:#f9f9ff;">' + formatRp(totalFee) + '</td>';
      html += '</tr>';
    }
  }

  html += '</tbody></table>';
  return html;
}

describe('renderCalendarGrid', () => {
  describe('Req 1.1: Column order - No, Client_Code, Customer Name, Sales_Code, Date 1-N, Total', () => {
    it('should render header columns in correct order', () => {
      const clientRows = new Map();
      const html = renderCalendarGrid(clientRows, 2026, 1, []);

      // Check header order
      const headerMatch = html.match(/<thead><tr>(.*?)<\/tr><\/thead>/s);
      expect(headerMatch).not.toBeNull();
      const headerContent = headerMatch[1];

      const thMatches = [...headerContent.matchAll(/<th[^>]*>(.*?)<\/th>/g)].map(m => m[1]);
      expect(thMatches[0]).toBe('No');
      expect(thMatches[1]).toBe('Client_Code');
      expect(thMatches[2]).toBe('Customer Name');
      expect(thMatches[3]).toBe('Sales_Code');
      // Days 1 through 31 for January
      for (let d = 1; d <= 31; d++) {
        expect(thMatches[3 + d]).toBe(String(d));
      }
      // Total column at the end
      expect(thMatches[thMatches.length - 1]).toBe('Total');
    });

    it('should render correct number of date columns for February', () => {
      const clientRows = new Map();
      const html = renderCalendarGrid(clientRows, 2026, 2, []);

      const headerMatch = html.match(/<thead><tr>(.*?)<\/tr><\/thead>/s);
      const thMatches = [...headerMatch[1].matchAll(/<th[^>]*>(.*?)<\/th>/g)].map(m => m[1]);
      // No + Client_Code + Customer Name + Sales_Code + 28 days + Total = 33
      expect(thMatches.length).toBe(33);
      expect(thMatches[thMatches.length - 1]).toBe('Total');
    });
  });

  describe('Req 1.2: Volume sub-row and Fee sub-row per client', () => {
    it('should render two rows per client (volume and fee)', () => {
      const days = new Map();
      days.set(5, { volume: 1000000, fee: 50000 });

      const clientRows = new Map();
      clientRows.set('C001', {
        client_id: 'C001',
        client_name: 'Test Client',
        sales_name: 'Sales A',
        days: days,
        totalVolume: 1000000,
        totalFee: 50000
      });

      const html = renderCalendarGrid(clientRows, 2026, 1, []);

      // Should have rowspan="2" for the fixed columns (No, Client_Code, Customer Name, Sales_Code)
      expect(html).toContain('rowspan="2"');

      // Should contain volume value
      expect(html).toContain(formatRp(1000000));
      // Should contain fee value
      expect(html).toContain(formatRp(50000));
    });
  });

  describe('Req 1.3 & 4.4: Non-trading day column headers get red background', () => {
    it('should apply red background to non-trading day headers', () => {
      const nonTradingDays = [3, 4, 10, 11]; // Sat/Sun
      const clientRows = new Map();
      const html = renderCalendarGrid(clientRows, 2026, 1, nonTradingDays);

      // Non-trading day headers should have red background
      const headerMatch = html.match(/<thead><tr>(.*?)<\/tr><\/thead>/s);
      const headerContent = headerMatch[1];

      // Check that day 3 has red background
      expect(headerContent).toContain('background:#e74c3c;color:#fff;">3</th>');
      expect(headerContent).toContain('background:#e74c3c;color:#fff;">4</th>');
      expect(headerContent).toContain('background:#e74c3c;color:#fff;">10</th>');
      expect(headerContent).toContain('background:#e74c3c;color:#fff;">11</th>');

      // Trading days should have navy background
      expect(headerContent).toContain('background:var(--navy);color:#fff;">1</th>');
      expect(headerContent).toContain('background:var(--navy);color:#fff;">2</th>');
      expect(headerContent).toContain('background:var(--navy);color:#fff;">5</th>');
    });
  });

  describe('Req 1.4: Total column = sum of all daily values', () => {
    it('should calculate total as sum of all daily volumes and fees', () => {
      const days = new Map();
      days.set(1, { volume: 500000, fee: 25000 });
      days.set(5, { volume: 300000, fee: 15000 });
      days.set(10, { volume: 200000, fee: 10000 });

      const clientRows = new Map();
      clientRows.set('C001', {
        client_id: 'C001',
        client_name: 'Test Client',
        sales_name: 'Sales A',
        days: days,
        totalVolume: 1000000,
        totalFee: 50000
      });

      const html = renderCalendarGrid(clientRows, 2026, 1, []);

      // Total volume = 500000 + 300000 + 200000 = 1000000
      expect(html).toContain(formatRp(1000000));
      // Total fee = 25000 + 15000 + 10000 = 50000
      expect(html).toContain(formatRp(50000));
    });
  });

  describe('Req 1.5: Empty cell for dates with no transactions', () => {
    it('should render empty td for days without data', () => {
      const days = new Map();
      days.set(5, { volume: 1000000, fee: 50000 });

      const clientRows = new Map();
      clientRows.set('C001', {
        client_id: 'C001',
        client_name: 'Test Client',
        sales_name: 'Sales A',
        days: days,
        totalVolume: 1000000,
        totalFee: 50000
      });

      const html = renderCalendarGrid(clientRows, 2026, 1, []);

      // Empty cells should be present (blank td)
      expect(html).toContain('<td style="padding:6px 4px;"></td>');
    });
  });

  describe('Req 1.6: Multiple transactions same client+date show aggregated sum', () => {
    it('should display aggregated values from the Map (aggregation done upstream)', () => {
      // The aggregation is done by SahamAggregation.aggregateByClientAndDate
      // The renderer just displays what's in the days Map
      const days = new Map();
      days.set(5, { volume: 2500000, fee: 125000 }); // Already aggregated

      const clientRows = new Map();
      clientRows.set('C001', {
        client_id: 'C001',
        client_name: 'Test Client',
        sales_name: 'Sales A',
        days: days,
        totalVolume: 2500000,
        totalFee: 125000
      });

      const html = renderCalendarGrid(clientRows, 2026, 1, []);
      expect(html).toContain(formatRp(2500000));
      expect(html).toContain(formatRp(125000));
    });
  });

  describe('Empty state', () => {
    it('should show empty message when no client rows', () => {
      const clientRows = new Map();
      const html = renderCalendarGrid(clientRows, 2026, 1, []);
      expect(html).toContain('Tidak ada data transaksi untuk bulan ini');
    });
  });

  describe('Multiple clients', () => {
    it('should render numbered rows for multiple clients', () => {
      const days1 = new Map();
      days1.set(1, { volume: 100000, fee: 5000 });

      const days2 = new Map();
      days2.set(2, { volume: 200000, fee: 10000 });

      const clientRows = new Map();
      clientRows.set('C001', {
        client_id: 'C001',
        client_name: 'Client One',
        sales_name: 'Sales A',
        days: days1,
        totalVolume: 100000,
        totalFee: 5000
      });
      clientRows.set('C002', {
        client_id: 'C002',
        client_name: 'Client Two',
        sales_name: 'Sales B',
        days: days2,
        totalVolume: 200000,
        totalFee: 10000
      });

      const html = renderCalendarGrid(clientRows, 2026, 1, []);

      // Should contain both client IDs
      expect(html).toContain('C001');
      expect(html).toContain('C002');
      expect(html).toContain('Client One');
      expect(html).toContain('Client Two');
    });
  });
});
