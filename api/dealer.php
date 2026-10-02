<?php
/**
 * api/dealer.php — Dealer Report (nasabah, transaksi, dividen)
 *
 * Semua request pakai query param ?table=nasabah|transaksi|dividen
 *
 * GET    /api/dealer.php?table=nasabah               — list nasabah
 * POST   /api/dealer.php?table=nasabah               — create nasabah {id, nama}
 * POST   /api/dealer.php?table=nasabah&bulk=1        — bulk insert [{id,nama}, ...]
 * DELETE /api/dealer.php?table=nasabah&id=X          — hapus nasabah (+ transaksinya)
 *
 * GET    /api/dealer.php?table=transaksi             — list transaksi
 * POST   /api/dealer.php?table=transaksi             — create {id,tgl,cid,nama,kode,trx,qty,harga,total}
 * PUT    /api/dealer.php?table=transaksi&id=X        — update
 * DELETE /api/dealer.php?table=transaksi&id=X        — hapus satu
 * DELETE /api/dealer.php?table=transaksi&ids=1,2,3   — hapus banyak
 *
 * GET    /api/dealer.php?table=dividen               — list dividen
 * POST   /api/dealer.php?table=dividen               — create {id,tgl,cid,nama,stock,qty,div,amt,txt}
 * DELETE /api/dealer.php?table=dividen&id=X          — hapus satu
 * DELETE /api/dealer.php?table=dividen&ids=1,2,3     — hapus banyak
 */
require_once __DIR__ . '/cors.php';
require_once __DIR__ . '/db.php';

$user  = requireAuth();
$pdo   = getDB();
$m     = method();
$table = $_GET['table'] ?? '';

// Hanya admin / head_account yang boleh akses dealer report
if (!in_array($user['role'], ['admin', 'head_account'], true)) {
    jsonError('Tidak diizinkan', 403);
}

/** Ambil daftar id dari query ?ids=1,2,3 */
function idsFromQuery(): array {
    if (empty($_GET['ids'])) return [];
    return array_values(array_filter(array_map('trim', explode(',', $_GET['ids'])), fn($v) => $v !== ''));
}

switch ($table) {

    // ── NASABAH ───────────────────────────────────────────
    case 'nasabah': {
        if ($m === 'GET') {
            $rows = $pdo->query('SELECT id, nama FROM dealer_nasabah ORDER BY id')->fetchAll();
            jsonList($rows);
        }

        if ($m === 'POST') {
            $b = getBody();

            // bulk insert
            if (!empty($_GET['bulk']) && isset($b[0])) {
                $stmt = $pdo->prepare(
                    'INSERT INTO dealer_nasabah (id, nama) VALUES (?, ?)
                     ON DUPLICATE KEY UPDATE nama = VALUES(nama)'
                );
                $n = 0;
                foreach ($b as $row) {
                    $rid   = trim((string)($row['id'] ?? ''));
                    $rnama = trim((string)($row['nama'] ?? ''));
                    if ($rid === '' || $rnama === '') continue;
                    $stmt->execute([$rid, $rnama]);
                    $n++;
                }
                jsonOk(['imported' => $n], 201);
            }

            // single insert
            $id   = trim((string)($b['id'] ?? ''));
            $nama = trim((string)($b['nama'] ?? ''));
            if ($id === '' || $nama === '') jsonError('id dan nama wajib diisi');
            $pdo->prepare(
                'INSERT INTO dealer_nasabah (id, nama) VALUES (?, ?)
                 ON DUPLICATE KEY UPDATE nama = VALUES(nama)'
            )->execute([$id, $nama]);
            jsonOk(['id' => $id], 201);
        }

        if ($m === 'DELETE') {
            $id = $_GET['id'] ?? '';
            if ($id === '') jsonError('id wajib diisi');
            // hapus nasabah + transaksinya
            $pdo->prepare('DELETE FROM dealer_transaksi WHERE cid = ?')->execute([$id]);
            $pdo->prepare('DELETE FROM dealer_nasabah WHERE id = ?')->execute([$id]);
            jsonOk(['deleted' => $id]);
        }
        break;
    }

    // ── TRANSAKSI ─────────────────────────────────────────
    case 'transaksi': {
        if ($m === 'GET') {
            $rows = $pdo->query('SELECT * FROM dealer_transaksi ORDER BY tgl DESC, id DESC')->fetchAll();
            jsonList($rows);
        }

        if ($m === 'POST') {
            $b = getBody();
            $id = isset($b['id']) ? (int)$b['id'] : 0;
            if (!$id) jsonError('id wajib diisi');
            $fields = ['id','tgl','cid','nama','kode','trx','qty','harga','total'];
            $cols = []; $vals = [];
            foreach ($fields as $f) {
                if (array_key_exists($f, $b)) {
                    $cols[] = "`$f`";
                    $vals[] = ($b[$f] === '' ? null : $b[$f]);
                }
            }
            $pdo->prepare(
                'INSERT INTO dealer_transaksi (' . implode(',', $cols) . ') VALUES (' . implode(',', array_fill(0, count($cols), '?')) . ')'
            )->execute($vals);
            jsonOk(['id' => $id], 201);
        }

        if ($m === 'PUT') {
            $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
            if (!$id) jsonError('id wajib diisi');
            $b = getBody();
            $fields = ['tgl','cid','nama','kode','trx','qty','harga','total'];
            $sets = []; $vals = [];
            foreach ($fields as $f) {
                if (array_key_exists($f, $b)) {
                    $sets[] = "`$f` = ?";
                    $vals[] = ($b[$f] === '' ? null : $b[$f]);
                }
            }
            if (empty($sets)) jsonError('Tidak ada data');
            $vals[] = $id;
            $pdo->prepare('UPDATE dealer_transaksi SET ' . implode(',', $sets) . ' WHERE id = ?')->execute($vals);
            jsonOk(['id' => $id]);
        }

        if ($m === 'DELETE') {
            $ids = idsFromQuery();
            if (!$ids && !empty($_GET['id'])) $ids = [$_GET['id']];
            if (!$ids) jsonError('id atau ids wajib diisi');
            $ph = implode(',', array_fill(0, count($ids), '?'));
            $pdo->prepare("DELETE FROM dealer_transaksi WHERE id IN ($ph)")
                ->execute(array_map('intval', $ids));
            jsonOk(['deleted' => $ids]);
        }
        break;
    }

    // ── DIVIDEN ───────────────────────────────────────────
    case 'dividen': {
        if ($m === 'GET') {
            $rows = $pdo->query('SELECT * FROM dealer_dividen ORDER BY id DESC')->fetchAll();
            jsonList($rows);
        }

        if ($m === 'POST') {
            $b = getBody();
            $id = isset($b['id']) ? (int)$b['id'] : 0;
            if (!$id) jsonError('id wajib diisi');
            $fields = ['id','tgl','cid','nama','stock','qty','div','amt','txt'];
            $cols = []; $vals = [];
            foreach ($fields as $f) {
                if (array_key_exists($f, $b)) {
                    $cols[] = "`$f`";
                    $vals[] = ($b[$f] === '' ? null : $b[$f]);
                }
            }
            $pdo->prepare(
                'INSERT INTO dealer_dividen (' . implode(',', $cols) . ') VALUES (' . implode(',', array_fill(0, count($cols), '?')) . ')'
            )->execute($vals);
            jsonOk(['id' => $id], 201);
        }

        if ($m === 'DELETE') {
            $ids = idsFromQuery();
            if (!$ids && !empty($_GET['id'])) $ids = [$_GET['id']];
            if (!$ids) jsonError('id atau ids wajib diisi');
            $ph = implode(',', array_fill(0, count($ids), '?'));
            $pdo->prepare("DELETE FROM dealer_dividen WHERE id IN ($ph)")
                ->execute(array_map('intval', $ids));
            jsonOk(['deleted' => $ids]);
        }
        break;
    }

    default:
        jsonError('table tidak dikenal (nasabah|transaksi|dividen)', 400);
}

jsonError('Endpoint tidak ditemukan', 404);
