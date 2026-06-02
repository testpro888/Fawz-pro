/* ============================================================
   navbar.js — Fawz Pro Navbar Logic
   Di-load via <script src="navbar.js"> di setiap halaman.
   Menghandle: session sync, user info, dropdown, active link.
   ============================================================ */

(function () {

  /* ── 0. FAVICON ── */
  (function() {
    const link = document.querySelector("link[rel~='icon']") || document.createElement('link');
    link.rel  = 'icon';
    link.type = 'image/png';
    link.href = 'assets/logo/fawz.png';
    document.head.appendChild(link);
  })();

  /* ── 1. SESSION SYNC ── */
  const ss  = sessionStorage.getItem('fawz_user');
  const ls  = localStorage.getItem('fawz_user_remember');
  const raw = ss || ls;

  if (!raw) {
    window.location.replace('login.html');
    return;
  }
  // Selalu sync ke sessionStorage agar tersedia di semua halaman
  sessionStorage.setItem('fawz_user', raw);

  /* ── 2. CONSTANTS ── */
  const ROLE_LABELS = {
    head_account : 'Head Account',
    admin        : 'Admin',
    sales        : 'Sales',
    treasury     : 'Bonds Dealer'
  };

  /* ── 3. INIT USER INFO ── */
  function initNavbar() {
    const user     = JSON.parse(raw);
    const roleName = ROLE_LABELS[user.role] || user.role;
    const initial  = (user.name || 'U')[0].toUpperCase();

    const setTxt = (id, val) => { const el = document.getElementById(id); if (el) el.textContent = val; };

    setTxt('navUserName',  user.name || 'User');
    setTxt('navUserRole',  roleName);
    setTxt('ddUserName',   user.name || 'User');
    setTxt('ddUserEmail',  user.username || '');

    // Avatar
    const avatarEl = document.getElementById('navAvatar');
    if (avatarEl) {
      if (user.photoURL) {
        avatarEl.innerHTML = `<img src="${user.photoURL}" alt="avatar"
          onerror="this.parentElement.textContent='${initial}'"/>`;
      } else {
        avatarEl.textContent = initial;
      }
    }

    // Kelola Akun hanya untuk head_account
    if (user.role === 'head_account') {
      const el = document.getElementById('manageAccountsLink');
      if (el) el.style.display = 'flex';
    }

    // ── PERMISSION MATRIX ──
    // Definisi akses per role: true = tampil, false = hidden
    const PERMISSIONS = {
      // format: { navItemId atau href : [roles yang BOLEH lihat] }
      // Nav menu utama
      navSales   : ['head_account', 'admin', 'treasury', 'sales'],
      navCustomer: ['head_account', 'admin', 'treasury', 'sales'],
      navProduct : ['head_account', 'admin', 'treasury', 'sales'],
      navRevenue : ['head_account', 'admin', 'treasury', 'sales'],

      // Dropdown items — by href
      // Sales dropdown
      'sales-activity.html'    : ['head_account', 'admin', 'treasury', 'sales'],
      'sales-transaction.html' : ['head_account', 'admin', 'treasury', 'sales'],
      'sales-tracker.html'     : ['head_account', 'admin'],
      'sales.html'             : ['head_account', 'admin'],

      // Customer dropdown
      'customer.html'          : ['head_account', 'admin', 'treasury', 'sales'],

      // Product dropdown
      'obligasi-bookbuilding.html'   : ['head_account', 'admin', 'treasury', 'sales'],
      'obligasi-pasar-sekunder.html' : ['head_account', 'admin', 'treasury', 'sales'],
      'obligasi-ipo.html'            : ['head_account', 'admin', 'treasury', 'sales'],
      'bond-transaction.html'        : ['head_account', 'admin', 'treasury', 'sales'],
      'reksadana-data.html'          : ['head_account', 'admin', 'treasury', 'sales'],
      'reksadana-order.html'         : ['head_account', 'admin', 'treasury', 'sales'],
      'waran-terstruktur.html'       : ['head_account', 'admin', 'treasury', 'sales'],
      'saham.html'                   : ['head_account', 'admin', 'treasury', 'sales'],
      'saham-ranking.html'           : ['head_account', 'admin'],

      // Revenue dropdown
      'revenue-data.html'      : ['head_account', 'admin', 'sales'],
      'sales-commission.html'  : ['head_account', 'admin', 'sales'],

      // User dropdown
      'manageAccountsLink'     : ['head_account'],  // Kelola Akun di profile
    };

    const role = user.role;

    // Sembunyikan nav menu utama
    ['navSales','navCustomer','navProduct','navRevenue'].forEach(id => {
      const allowed = PERMISSIONS[id];
      const el = document.getElementById(id);
      if (el && allowed && !allowed.includes(role)) el.style.display = 'none';
    });

    // Sembunyikan dropdown items berdasarkan href
    document.querySelectorAll('.dropdown-item[href]').forEach(el => {
      const href    = el.getAttribute('href');
      const allowed = PERMISSIONS[href];
      if (allowed && !allowed.includes(role)) el.style.display = 'none';
    });

    // Setelah sembunyikan items, cek dropdown section yang jadi kosong — hapus juga
    document.querySelectorAll('.dropdown-section').forEach(section => {
      const visibleItems = [...section.querySelectorAll('.dropdown-item')]
        .filter(i => i.style.display !== 'none');
      if (visibleItems.length === 0) section.style.display = 'none';
    });

    // Sembunyikan nav-item yang semua dropdown-item-nya hidden
    document.querySelectorAll('.nav-menu .nav-item[id]').forEach(item => {
      const dd = item.querySelector('.dropdown');
      if (!dd) return;
      const visibleItems = [...dd.querySelectorAll('.dropdown-item')]
        .filter(i => i.style.display !== 'none');
      if (visibleItems.length === 0) item.style.display = 'none';
    });

    // Mobile drawer: sembunyikan mob-link berdasarkan href yang sama
    document.querySelectorAll('.mobile-drawer .mob-link[href]').forEach(el => {
      const href    = el.getAttribute('href');
      const allowed = PERMISSIONS[href];
      if (allowed && !allowed.includes(role)) el.style.display = 'none';
    });

    // Mobile drawer: sembunyikan drawer-group jika semua mob-link di dalamnya hidden
    document.querySelectorAll('.drawer-group').forEach(group => {
      const visibleLinks = [...group.querySelectorAll('.mob-link[href]')]
        .filter(l => l.style.display !== 'none');
      if (visibleLinks.length === 0) group.style.display = 'none';
    });

    // Active link — highlight menu sesuai halaman aktif
    const currentFile = window.location.pathname.split('/').pop() || 'dashboard.html';
    let matched = false;

    document.querySelectorAll('.nav-link').forEach(link => {
      link.classList.remove('active');
      if (link.getAttribute('href') === currentFile) {
        link.classList.add('active');
        matched = true;
      }
    });

    if (!matched) {
      document.querySelectorAll('.dropdown-item').forEach(item => {
        if (item.getAttribute('href') === currentFile) {
          const parent = item.closest('.nav-item');
          if (parent) parent.querySelector('.nav-link')?.classList.add('active');
        }
      });
    }

  }

  /* ── 4. DROPDOWN HOVER ── */
  function setupDropdowns() {
    const items = document.querySelectorAll('.nav-menu .nav-item');

    items.forEach(item => {
      let timer = null;
      const open  = () => { clearTimeout(timer); items.forEach(o => { if (o !== item) o.classList.remove('open'); }); item.classList.add('open'); };
      const close = () => { timer = setTimeout(() => item.classList.remove('open'), 180); };
      const hold  = () => clearTimeout(timer);

      item.addEventListener('mouseenter', open);
      item.addEventListener('mouseleave', close);

      const dd = item.querySelector('.dropdown');
      if (dd) {
        dd.addEventListener('mouseenter', hold);
        dd.addEventListener('mouseleave', close);
      }
    });

    // Tutup saat klik di luar
    document.addEventListener('click', e => {
      if (!e.target.closest('.nav-item') && !e.target.closest('.nav-user')) {
        items.forEach(i => i.classList.remove('open'));
        document.getElementById('navUser')?.classList.remove('open');
      }
    });

    // User dropdown
    const navUser = document.getElementById('navUser');
    const userDd  = navUser?.querySelector('.user-dropdown');
    let userTimer = null;
    if (navUser && userDd) {
      const openU  = () => { clearTimeout(userTimer); navUser.classList.add('open'); };
      const closeU = () => { userTimer = setTimeout(() => navUser.classList.remove('open'), 180); };
      const holdU  = () => clearTimeout(userTimer);
      navUser.addEventListener('mouseenter', openU);
      navUser.addEventListener('mouseleave', closeU);
      userDd.addEventListener('mouseenter', holdU);
      userDd.addEventListener('mouseleave', closeU);
    }
  }

  /* ── 5. GLOBAL FUNCTIONS ── */
  window.doLogout = function () {
    sessionStorage.removeItem('fawz_user');
    localStorage.removeItem('fawz_user_remember');
    window.location.href = 'login.html';
  };

  window.toggleMobile = function () {
    const drawer = document.getElementById('mobileDrawer');
    const overlay = document.getElementById('drawerOverlay');
    const hamburger = document.getElementById('hamburger');
    const isOpen = drawer?.classList.contains('open');
    drawer?.classList.toggle('open');
    overlay?.classList.toggle('open');
    hamburger?.classList.toggle('active');
    document.body.style.overflow = isOpen ? '' : 'hidden';
  };

  window.toggleDrawerGroup = function (header) {
    const items = header.nextElementSibling;
    const isOpen = items.classList.contains('open');
    document.querySelectorAll('.drawer-group-items.open').forEach(el => {
      el.classList.remove('open');
      el.previousElementSibling.classList.remove('active');
    });
    if (!isOpen) {
      items.classList.add('open');
      header.classList.add('active');
    }
  };
  /* ── 5b. GLOBAL MODAL ESCAPE — tutup semua modal overlay saat tekan Escape ── */
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
      document.querySelectorAll('.modal-overlay.open, .detail-modal-overlay.open').forEach(function(el) {
        el.classList.remove('open');
      });
    }
  });

  /* ── 6. FETCH & INJECT NAVBAR HTML, LALU INIT ── */
  fetch('navbar.html')
    .then(r => r.text())
    .then(html => {
      const parser = new DOMParser();
      const doc    = parser.parseFromString(html, 'text/html');

      // Inject styles
      doc.querySelectorAll('style').forEach(s => {
        const clone = document.createElement('style');
        clone.textContent = s.textContent;
        document.head.appendChild(clone);
      });

      // Inject nav + drawer HTML
      const ph     = document.getElementById('navbar-placeholder');
      const nav    = doc.querySelector('nav.fawz-navbar');
      const drawer = doc.querySelector('.mobile-drawer');
      if (nav    && ph) ph.appendChild(nav);
      if (drawer && ph) ph.appendChild(drawer);

      // Init setelah HTML ada di DOM — TIDAK inject ulang script dari navbar.html
      // karena semua logika sudah ada di file navbar.js ini
      initNavbar();
      setupDropdowns();

      // Event delegation untuk drawer group accordion
      document.addEventListener('click', function(e) {
        const header = e.target.closest('.drawer-group-header');
        if (!header) return;
        const items = header.nextElementSibling;
        if (!items || !items.classList.contains('drawer-group-items')) return;
        const isOpen = items.classList.contains('open');
        document.querySelectorAll('.drawer-group-items.open').forEach(el => {
          el.classList.remove('open');
          el.previousElementSibling.classList.remove('active');
        });
        if (!isOpen) {
          items.classList.add('open');
          header.classList.add('active');
        }
      });
    })
    .catch(err => console.warn('Navbar gagal dimuat:', err));

})();
