window.__FAWZ_CONFIG__ = {
  supabaseUrl: "https://yhmrfluehibfapvtxcfi.supabase.co",
  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlobXJmbHVlaGliZmFwdnR4Y2ZpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkxNjEzODUsImV4cCI6MjA5NDczNzM4NX0.se_H4n_eLsf81d_1GH5sqsPCpX89MHewlPuuNkY6qcU"
};

/* ── SUPABASE SINGLETON ──
   Inject SDK sekali di sini, buat satu instance global window._supabase.
   Semua halaman cukup pakai window._supabase — tidak perlu createClient lagi.
   Halaman yang masih pakai _sb / _sbDash lokal tidak masalah, tapi
   navbar.js dan fitur lain akan pakai window._supabase yang sudah siap. */
(function() {
  if (window._supabase) return; // sudah ada

  var CFG = window.__FAWZ_CONFIG__;
  var URL = CFG.supabaseUrl;
  var KEY = CFG.supabaseKey;

  function _initSb() {
    if (window._supabase) return;
    if (window.__FAWZ_SB_INIT__) return;
    window.__FAWZ_SB_INIT__ = true;
    try {
      window._supabase = window.supabase.createClient(URL, KEY);
    } catch(e) {
      window.__FAWZ_SB_INIT__ = false;
      console.warn('Fawz config.js: Supabase init gagal', e);
    }
  }

  // Kalau SDK sudah ada (halaman load SDK sebelum config.js — jarang terjadi)
  if (window.supabase && window.supabase.createClient) {
    _initSb();
    return;
  }

  // Inject SDK lalu init
  var s = document.createElement('script');
  s.src = 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js';
  s.onload = _initSb;
  s.onerror = function() { console.warn('Fawz: Gagal load Supabase SDK'); };
  // Masukkan sebagai script pertama di head agar load secepat mungkin
  var head = document.head || document.getElementsByTagName('head')[0];
  head.insertBefore(s, head.firstChild);
})();
