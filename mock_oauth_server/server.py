#! /usr/bin/env python3
from http.server import SimpleHTTPRequestHandler, HTTPServer

PORT = 9988

with HTTPServer(('', PORT), SimpleHTTPRequestHandler) as server:
    print(f'Started httpserver on port {PORT}')
    server.serve_forever()
