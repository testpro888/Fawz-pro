# Create analytics.html
html_content = """<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Fawz Pro | Analytics</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet"/>
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js"></script>
  <script>
    const SUPABASE_URL = 'https://yhmrfluehibfapvtxcfi.supabase.co';
    const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlobXJmbHVlaGliZmFwdnR4Y2ZpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkxNjEzODUsImV4cCI6MjA5NDczNzM4NX0.se_H4n_eLsf81d_1GH5sqsPCpX89MHewlPuuNkY6qcU';
    const _sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
  </script>
  <style>
    * { box-sizing:border-box; margin:0; padding:0; }
    :root { --navy:#0d0d2b; --gold:#f5a623; --bg:#f8f9fc; --white:#fff; --border:#e0e0ef; --nav-h:68px; }
    body { font-family:'Inter',sans-serif; background:var(--bg); padding-top:var(--nav-h); }
    .container { max-width:1400px; margin:0 auto; padding:32px 28px; }
    .header { margin-bottom:32px; }
    .title { font-size:2rem; font-weight:900; color:var(--navy); }
    .subtitle { font-size:0.9rem; color:#888; margin-top:6px; }
    .filter-bar { background:var(--white); border-radius:14px; padding:20px; margin-bottom:24px; }
    .filter-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(200px,1fr)); gap:16px; }
    .filter-item { display:flex; flex-direction:column; gap:8px; }
    .filter-label { font-size:0.72rem; font-weight:700; color:#888; text-transform:uppercase; }
    .filter-select { height:40px; border:1.5px solid var(--border); border-radius:10px; padding:0 12px; font-family:'Inter'; font-size:0.875rem; }
    .kpi-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(240px,1fr)); gap:20px; margin-bottom:28px; }
    .kpi-card { background:var(--white); border-radius:14px; padding:24px; box-shadow:0 2px 10px rgba(0,0,0,0.05); }
    .kpi-label { font-size:0.75rem; color:#888; text-transform:uppercase; margin-bottom:8px; }
    .kpi-value { font-size:1.8rem; font-weight:800; color:var(--navy); }
    .chart-card { background:var(--white); border-radius:14px; padding:28px; box-shadow:0 2px 10px rgba(0,0,0,0.05); margin-bottom:24px; }
    .chart-title { font-size:1.1rem; font-weight:700; color:var(--navy); margin-bottom:20px; }
    .chart-wrap { height:400px; position:relative; }
  </style>
  <script>
    (function() {
      var raw = sessionStorage.getItem('fawz_user') || localStorage.getItem('fawz_user_remember');
      if (!raw) { window.location.replace('login.html'); return; }
      sessionStorage.setItem('fawz_user', raw);
    })();
  </script>
</head>
"""

with open('analytics.html', 'w', encoding='utf-8') as f:
    f.write(html_content)

print("Part 1 written")
