# Commission Report A4 Layout - Bug Condition Exploration Test

## Overview

This directory contains tests for the commission report A4 layout overflow bugfix.

**CRITICAL:** The bug condition exploration test (Task 1) is **EXPECTED TO FAIL** on unfixed code. Test failure confirms the bug exists.

## Test Documentation

### Property 1: Bug Condition - A4 Layout Overflow Detection

**Validates Requirements:** 1.1, 1.2, 1.3, 2.1, 2.2, 2.3

**Purpose:** Demonstrate that the current (unfixed) layout causes content to exceed A4 vertical dimensions (1123px), resulting in chart cut-off and pagination issues during print/PDF export.

**Expected Outcome on UNFIXED code:**
- ❌ Test FAILS
- Measured height: ~1180-1200px (exceeds 1123px limit)
- Chart section causes overflow
- Some months (especially Nov/Dec) not visible in print preview
- Footer may appear on page 2

**Expected Outcome AFTER fix:**
- ✅ Test PASSES
- Measured height: ≤ 1123px
- All 12 months visible
- Footer on page 1
- No pagination issues

## Running the Tests

### Option 1: Manual Browser Test (Recommended)

1. **Open the test harness:**
   ```bash
   open test-a4-layout-bug.html
   ```
   Or navigate to `http://localhost:8080/test-a4-layout-bug.html` if running a local server.

2. **Follow the on-screen instructions:**
   - Click "Open Commission Report" to open commission-report.html in a new tab
   - Log in if needed (use admin role)
   - Select any sales person
   - Select Month: December (12)
   - Select Year: 2024
   - Click "Generate Laporan"
   - Open Print Preview (Ctrl+P / Cmd+P)
   - Observe the layout in print preview mode

3. **Expected observations on UNFIXED code:**
   - Chart section appears cut off
   - Not all 12 months fully visible
   - Footer pushed to page 2
   - Content overflows A4 page boundary

### Option 2: Automated Playwright Test

**Note:** This test requires a running HTTP server and proper authentication setup.

1. **Install dependencies:**
   ```bash
   npm install
   npx playwright install chromium
   ```

2. **Run the test:**
   ```bash
   npm test
   ```

3. **Check results:**
   - Screenshots saved to `tests/screenshots/bug-condition-overflow.png`
   - Console output shows detailed measurements
   - Test assertions will FAIL on unfixed code (this is expected!)

## Test Results Documentation

### Counterexample Documentation Template

When running the test on unfixed code, document the following:

```json
{
  "measuredHeight": "~1180-1200px",
  "a4Limit": "1123px",
  "overflow": "~57-77px",
  "chartBoxHeight": "230px",
  "visibleMonths": "8-10 of 12",
  "observations": [
    "Chart bottom cut off in print preview",
    "Months Nov/Dec not fully visible",
    "Footer on page 2",
    "Content exceeds A4 vertical limit"
  ],
  "sections": {
    "header": "~XX px",
    "titleSection": "~XX px",
    "chartSection": "~XX px",
    "tableSection": "~XX px",
    "incomeSection": "~XX px",
    "footer": "~XX px"
  }
}
```

### Screenshot Evidence

- **Before fix:** `tests/screenshots/bug-condition-overflow.png` - Shows chart cut-off and overflow
- **After fix:** Will show all content within A4 bounds

## Important Notes

1. **Do NOT fix the test when it fails** - Failure confirms the bug exists
2. **Do NOT fix the code yet** - Task 1 is only for bug exploration
3. **Document all measurements** - These counterexamples prove the bug
4. **Take screenshots** - Visual evidence of the overflow issue

## Next Steps

After Task 1 is complete and bug is confirmed:
- ✅ Mark Task 1 complete
- ⏭️ Proceed to Task 2: Write preservation tests
- ⏭️ Then Task 3: Implement the fix

The same test will be re-run after the fix is implemented (Task 3.3) and should PASS at that point.
