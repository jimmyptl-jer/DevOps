const http = require('http');
const port = process.env.PORT || 3000;

const requestHandler = (req, res) => {
  res.end('Hello from Node.js in a Docker container!');
};

const server = http.createServer(requestHandler);

server.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
