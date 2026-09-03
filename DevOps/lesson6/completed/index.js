const http = require('http');
// Get MYAPP_PORT from environment variable
const MYAPP_PORT = process.env.MYAPP_PORT;
http.createServer((req, res) => {
  if (req.url === '/kill') {
    // App die on uncaught error and print stack trace to stderr
    throw new Error('Someone kills me');
  }
  if (req.method === 'POST') {
    // App print this message to stderr, but is still alive
    console.error(`Error: Request ${req.method} ${req.url}`);
    res.writeHead(405, { 'Content-Type': 'text/plain' });
    res.end('405 Method Not Allowed');
    return;
  }
  // App print this message to stdout
  console.log(`Request ${req.method} ${req.url}`);
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('200 OK');
})
.listen(MYAPP_PORT);
