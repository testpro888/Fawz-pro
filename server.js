const http = require('http');
const fs   = require('fs');
const path = require('path');

const PORT = 5500;

const MIME = {
  '.html': 'text/html',
  '.js':   'application/javascript',
  '.css':  'text/css',
  '.png':  'image/png',
  '.jpg':  'image/jpeg',
  '.svg':  'image/svg+xml',
  '.ico':  'image/x-icon',
  '.json': 'application/json',
};

http.createServer((req, res) => {
  let filePath = path.join(__dirname, req.url === '/' ? 'dashboard.html' : req.url);

  // Hapus query string jika ada
  filePath = filePath.split('?')[0];

  const ext = path.extname(filePath);
  const contentType = MIME[ext] || 'application/octet-stream';

  fs.readFile(filePath, (err, data) => {
    if (err) {
      // File tidak ditemukan → tampilkan 404.html
      fs.readFile(path.join(__dirname, '404.html'), (err2, data2) => {
        res.writeHead(404, { 'Content-Type': 'text/html' });
        res.end(err2 ? '<h1>404 Not Found</h1>' : data2);
      });
    } else {
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(data);
    }
  });
}).listen(PORT, () => {
  console.log(`Fawz Pro running at http://127.0.0.1:${PORT}`);
});