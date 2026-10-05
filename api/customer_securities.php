<?php
/**
 * api/customer_securities.php — CRUD data sekuritas / rekening customer
 * GET    /api/customer_securities.php?customer_id=X  — list securities milik satu customer
 * GET    /api/customer_securities.php?id=X           — detail satu row
 * POST   /api/customer_securities.php                — create (body JSON)
 * PUT    /api/customer_securities.php?id=X           — update
 * DELETE /api/customer_securities.php?id=X           — delete satu row
 * DELETE /api/customer_securities.php?customer_id=X  — delete semua row milik customer
 */
require_once __DIR__ . '/cors.php';
require_once __DIR__ . '/db.php';

$user = requireAuth();
$pdo  = getDB();
$m    = method();

// Kolom yang boleh ditulis
$FIELDS = ['customer_id','sekuritas_name','rdn_bank_name','rdn_account_no',
           'sec_client_id','sid','personal_bank_name','personal_account_no',
           'personal_account_name','sort_order'];

$id         = isset($_GET['id']) ? (int)$_GET['id'] : null;
$customerId = isset($_GET['customer_id']) ? (int)$_GET['customer_id'] : null;

// ── LIST by customer_id ───────────────────────────────────
if ($m === 'GET' && $customerId) {
    $stmt = $pdo->prepare(
        'SELECT * FROM customer_securities WHERE customer_id = ? ORDER BY sort_order ASC, id ASC'
    );
    $stmt->execute([$customerId]);
    jsonList($stmt->fetchAll());
}

// ── DETAIL by id ──────────────────────────────────────────
if ($m === 'GET' && $id) {
    $stmt = $pdo->prepare('SELECT * FROM customer_securities WHERE id = ?');
    $stmt->execute([$id]);
    $row = $stmt->fetch();
    if (!$row) jsonError('Data tidak ditemukan', 404);
    jsonOk($row);
}

if ($m === 'GET') jsonError('customer_id atau id wajib diisi');

// Mulai sini perlu role admin / head_account
if (!in_array($user['role'], ['admin', 'head_account'])) {
    jsonError('Tidak diizinkan', 403);
}

// ── CREATE ────────────────────────────────────────────────
if ($m === 'POST') {
    $b = getBody();
    if (empty($b['customer_id'])) jsonError('customer_id wajib diisi');

    $cols = [];
    $vals = [];
    foreach ($FIELDS as $f) {
        if (array_key_exists($f, $b)) {
            $cols[] = "`$f`";
            $vals[] = ($b[$f] === '' ? null : $b[$f]);
        }
    }

    $stmt = $pdo->prepare(
        'INSERT INTO customer_securities (' . implode(',', $cols) . ') VALUES (' .
        implode(',', array_fill(0, count($cols), '?')) . ')'
    );
    $stmt->execute($vals);
    $newId = $pdo->lastInsertId();

    $row = $pdo->prepare('SELECT * FROM customer_securities WHERE id = ?');
    $row->execute([$newId]);
    jsonOk($row->fetch(), 201);
}

// ── UPDATE ────────────────────────────────────────────────
if ($m === 'PUT' && $id) {
    $b    = getBody();
    $sets = [];
    $vals = [];
    foreach ($FIELDS as $f) {
        if ($f === 'customer_id') continue; // jangan pindah owner lewat update
        if (array_key_exists($f, $b)) {
            $sets[] = "`$f` = ?";
            $vals[] = ($b[$f] === '' ? null : $b[$f]);
        }
    }
    if (empty($sets)) jsonError('Tidak ada data yang diupdate');
    $vals[] = $id;

    $pdo->prepare('UPDATE customer_securities SET ' . implode(',', $sets) . ' WHERE id = ?')
        ->execute($vals);

    $row = $pdo->prepare('SELECT * FROM customer_securities WHERE id = ?');
    $row->execute([$id]);
    jsonOk($row->fetch());
}

// ── DELETE semua milik customer ───────────────────────────
if ($m === 'DELETE' && $customerId && !$id) {
    $pdo->prepare('DELETE FROM customer_securities WHERE customer_id = ?')->execute([$customerId]);
    jsonOk(['deleted_customer_id' => $customerId]);
}

// ── DELETE satu row ───────────────────────────────────────
if ($m === 'DELETE' && $id) {
    $pdo->prepare('DELETE FROM customer_securities WHERE id = ?')->execute([$id]);
    jsonOk(['deleted' => $id]);
}

jsonError('Endpoint tidak ditemukan', 404);
