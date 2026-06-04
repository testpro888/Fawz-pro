# Implementation Plan: Saham Trading System

## Overview

Implement the Saham Trading System for the Fawz Pro application, enhancing `saham.html` with a calendar grid view, daily transaction input with validation, month/client filtering, non-trading day visualization, YTD/monthly summaries, and data deletion. Create a new `saham-ranking.html` for monthly rankings. Enhance `fawz-point.html` with point calculation and redemption features. All code is vanilla HTML/CSS/JS with Supabase backend, following existing project patterns.

## Tasks

- [x] 1. Set up project infrastructure and shared modules
  - [x] 1.1 Create the `point_redemptions` database table
    - Execute the SQL schema to create the `point_redemptions` table with columns: id (UUID), client_id (TEXT), client_name (TEXT), points_redeemed (INTEGER CHECK >= 1), redeemed_by (TEXT), redemption_date (DATE), catatan (TEXT), created_at (TIMESTAMPTZ)
    - Create indexes on client_id and redemption_date
    - Disable RLS as per existing pattern
    - _Requirements: 9.4_

  - [x] 1.2 Create the Holiday Calendar module (`saham-holidays.js`)
    - Define `HOLIDAYS_2026` as a `Set` containing all 2026 national holidays and cuti bersama dates in 'YYYY-MM-DD' format
    - Implement `isNonTradingDay(dateStr)` that returns true for Saturdays, Sundays, or dates in HOLIDAYS_2026
    - Implement `getNonTradingDaysInMonth(year, month)` returning array of non-trading day numbers for a given month
    - Implement `getTradingDaysInMonth(year, month)` returning count of trading days
    - Export functions globally via `window.SahamHolidays` namespace
    - _Requirements: 4.1, 4.2, 4.3, 4.5, 4.6_

  - [x] 1.3 Write property test for Non-Trading Day Classification
    - **Property 5: Non-Trading Day Classification**
    - **Validates: Requirements 4.1, 4.5, 4.6**
    - For any date in 2026, isNonTradingDay returns true iff the date is Saturday, Sunday, or in HOLIDAYS_2026
    - Verify no double-counting: total trading days + total non-trading days = 365 (or 366 for leap year)
    - Verify exactly 239 trading days for 2026

  - [x] 1.4 Create the Input Validation module (`saham-validation.js`)
    - Implement `validateTransactionInput({ tanggal, client_id, client_name, volume, fee })` returning `{ valid, errors[] }`
    - Validate required fields: tanggal, client_id, client_name must be non-empty and non-whitespace
    - Validate volume: must be numeric, >= 0, <= 999999999999.99
    - Validate fee: must be numeric, >= 0, <= 999999999999.99
    - Export via `window.SahamValidation` namespace
    - _Requirements: 2.3, 2.4, 2.7_

  - [x]* 1.5 Write property tests for Input Validation
    - **Property 2: Numeric Input Validation**
    - **Validates: Requirements 2.3, 2.4**
    - For any negative, non-numeric, or out-of-range value, validation rejects with appropriate error
    - For any valid numeric in [0, 999999999999.99], validation accepts

  - [x]* 1.6 Write property test for Required Field Validation
    - **Property 3: Required Field Validation**
    - **Validates: Requirements 2.7**
    - For any input where at least one of tanggal, client_id, or client_name is empty/whitespace, validation rejects and identifies missing fields

  - [x] 1.7 Create the Data Aggregation module (`saham-aggregation.js`)
    - Implement `aggregateByClientAndDate(transactions)` returning a Map of ClientRow objects with per-day volume/fee sums
    - Implement `calculateMonthlyTotal(clientRow)` returning { volume, fee } totals
    - Implement `calculateMonthlySummary(transactions)` returning { totalVolume, totalFee, activeClients }
    - Implement `calculateYTDSummary(transactions, selectedMonth)` filtering Jan 1 through end of selected month
    - Export via `window.SahamAggregation` namespace
    - _Requirements: 1.2, 1.4, 1.6, 5.1, 5.2, 5.4_

  - [x]* 1.8 Write property test for Transaction Aggregation
    - **Property 1: Transaction Aggregation Correctness**
    - **Validates: Requirements 1.2, 1.4, 1.6**
    - For any set of transactions, per-cell values equal sum of all volumes/fees for that client+date
    - Total column equals sum of all daily values for that client

  - [x]* 1.9 Write property test for Summary Calculation
    - **Property 6: Summary Calculation Correctness**
    - **Validates: Requirements 5.1, 5.2, 5.4**
    - Monthly summary equals sum of volumes/fees within selected month
    - YTD summary equals sum from Jan 1 through end of selected month
    - Active client count equals distinct client_ids in period

- [x] 2. Checkpoint - Ensure all core modules work correctly
  - Ensure all tests pass, ask the user if questions arise.

- [x] 3. Implement Calendar Grid View in `saham.html`
  - [x] 3.1 Implement access control check in `saham.html`
    - Add IIFE that checks `fawz_user` from sessionStorage/localStorage
    - Redirect to `login.html` if no valid session or invalid JSON
    - Redirect to `dashboard.html` if role is "sales"
    - Allow access only for "admin" and "head_account" roles
    - Ensure no data is rendered before redirect for unauthorized users
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.6, 6.7_

  - [x] 3.2 Implement month and client filter controls
    - Add month selector (input type="month") defaulting to current month
    - Add client dropdown filter defaulting to "Semua Nasabah" (all clients)
    - Populate client dropdown with distinct clients from selected month's data
    - On filter change, re-render calendar grid within 2 seconds
    - Display empty state message when no data matches filters
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_

  - [x]* 3.3 Write property test for Filter Correctness
    - **Property 4: Filter Correctness**
    - **Validates: Requirements 3.2, 3.3, 3.4, 3.5**
    - Filtered result contains only transactions within selected month AND matching client
    - Client dropdown lists exactly distinct client_ids in selected month

  - [x] 3.4 Implement calendar grid renderer
    - Render table with columns: No, Client_Code, Customer Name, Sales_Code, Date 1-N (based on days in month), Total
    - Each client gets two sub-rows: Volume row and Fee row
    - Apply red background to column headers for Non_Trading_Day dates using the Holiday Calendar module
    - Display empty cells for dates with no transactions
    - Calculate and display Total column as sum of all daily values per row
    - Include `saham-holidays.js` and `saham-aggregation.js` script references
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 4.4_

  - [x] 3.5 Implement YTD and Monthly Summary section
    - Display Monthly Summary: total volume, total fee for selected month in Rupiah format
    - Display YTD Summary: accumulated volume and fee from Jan 1 through end of selected month
    - Display active client count for both monthly and YTD periods
    - Recalculate on month filter change within 3 seconds
    - Display "Rp 0" and "0" when no data exists
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_

- [x] 4. Implement Transaction Input and Deletion
  - [x] 4.1 Enhance transaction input form with validation
    - Integrate `saham-validation.js` into the save flow
    - On submit: validate all fields before Supabase call
    - Display specific error messages for invalid volume/fee (must be numeric, 0 to 999,999,999,999.99)
    - Display error for missing required fields (tanggal, client_id, client_name)
    - Retain form data on validation failure
    - Auto-populate Customer Name and Sales Person from customers table on Client_Code selection
    - Store created_by from current user session
    - On success: refresh table and statistics without full page reload, show success toast
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7_

  - [x] 4.2 Implement transaction deletion with confirmation
    - Show confirmation dialog on delete button click
    - On cancel: take no action, record remains unchanged
    - On confirm: delete from `saham_transaksi` table and remove from local data
    - On success: refresh table, summary stats, and Rekap Bulanan section; show success toast
    - On failure: show error toast, record remains visible and unchanged
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6_

- [x] 5. Checkpoint - Ensure saham.html is fully functional
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. Implement Monthly Ranking Page
  - [x] 6.1 Create `saham-ranking.html` page structure
    - Create new page with same styling patterns as existing pages (Inter font, CSS variables, navbar)
    - Include Supabase SDK, access control IIFE (admin/head_account only)
    - Add month filter defaulting to current month
    - Include page header with title "Ranking Bulanan Saham"
    - _Requirements: 6.1, 6.2, 6.3, 6.5, 7.3_

  - [x] 6.2 Implement ranking logic and display
    - Fetch transactions for selected month from `saham_transaksi`
    - Aggregate by client: sum volume and sum fee
    - Display Volume ranking: sorted descending by volume, ties broken by client_id ascending
    - Display Fee ranking: sorted descending by fee, ties broken by client_id ascending
    - Show for each client: rank, Client_Code, Customer Name, Sales_Code, Volume (Rp), Fee (Rp)
    - On month change: recalculate and re-render both rankings
    - Display empty state when no data exists for selected month
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_

  - [x]* 6.3 Write property test for Ranking Sort Order
    - **Property 7: Ranking Sort Order**
    - **Validates: Requirements 7.1, 7.2, 8.3**
    - For any set of client aggregates, ranking is sorted descending by field with ties broken by client_id ascending

  - [x] 6.4 Add navigation link to ranking page
    - Add "Ranking Saham" link in the navbar or as a button in `saham.html`
    - Ensure consistent navigation between saham.html and saham-ranking.html
    - _Requirements: 7.3_

- [x] 7. Enhance Fawz Point page with calculation and redemption
  - [x] 7.1 Implement enhanced point calculation in `fawz-point.html`
    - Add access control IIFE (admin/head_account only, redirect sales to dashboard)
    - Calculate points using formula: `Math.floor(total_volume / 10000000)`
    - Accumulate volume from all transaction types for point calculation
    - Display leaderboard ranked by points descending, ties broken by higher volume
    - Include clients with 0 points (volume < 10,000,000) in leaderboard
    - Show: rank, Client_Code, Customer Name, Volume (Rp), Points
    - Month filter defaults to current month, recalculates on change
    - Display empty state when no data for selected month
    - _Requirements: 6.5, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8_

  - [x]* 7.2 Write property test for Fawz Point Calculation
    - **Property 8: Fawz Point Calculation**
    - **Validates: Requirements 8.1, 8.2**
    - For any non-negative volume, points = Math.floor(volume / 10000000)
    - For multiple transaction types, total volume is the sum of all

  - [x] 7.3 Implement point redemption interface
    - Add redeem section with: client selector, numeric input for points (min 1), submit button
    - Validate available points = earned points - previously redeemed points
    - Reject if insufficient points with error showing current balance
    - Reject if redemption amount < 1 with appropriate error
    - On success: record in `point_redemptions` table (client_id, points_redeemed, redeemed_by, redemption_date)
    - On success: update leaderboard display within 2 seconds
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6_

  - [x]* 7.4 Write property test for Point Redemption Balance
    - **Property 9: Point Redemption Balance Invariant**
    - **Validates: Requirements 9.2, 9.5**
    - Available balance always equals earned points minus redeemed points
    - Any redemption exceeding available balance is rejected

  - [x] 7.5 Implement redemption history display
    - Fetch all records from `point_redemptions` table
    - Display list showing: client name, points redeemed, redeemed_by, redemption_date
    - Sort by most recent first (redemption_date descending)
    - _Requirements: 9.7_

  - [x]* 7.6 Write property test for Redemption History Ordering
    - **Property 10: Redemption History Ordering**
    - **Validates: Requirements 9.7**
    - Redemption history is always sorted by redemption_date descending

- [x] 8. Final checkpoint - Ensure all features work end-to-end
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- All modules use `window.*` namespace pattern since there's no build system
- The project uses vanilla HTML/CSS/JS with Supabase CDN — no npm/bundler needed for production code
- Test setup (fast-check + Vitest) is only needed if property tests are implemented

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2", "1.4"] },
    { "id": 1, "tasks": ["1.3", "1.5", "1.6", "1.7"] },
    { "id": 2, "tasks": ["1.8", "1.9", "3.1"] },
    { "id": 3, "tasks": ["3.2", "3.4", "3.5"] },
    { "id": 4, "tasks": ["3.3", "4.1", "4.2"] },
    { "id": 5, "tasks": ["6.1", "7.1"] },
    { "id": 6, "tasks": ["6.2", "6.4", "7.2", "7.3"] },
    { "id": 7, "tasks": ["6.3", "7.4", "7.5"] },
    { "id": 8, "tasks": ["7.6"] }
  ]
}
```
