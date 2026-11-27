from functools import partial
from http.client import HTTPConnection
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import re


class PreviewHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        name = Path(self.translate_path(self.path)).name
        cache_control = "max-age=31536000, immutable" if re.search(r"\.[0-9a-f]{8}\.", name) else "no-cache"
        self.send_header("Cache-Control", cache_control)
        super().end_headers()

    def send_head(self):
        original = Path(self.translate_path(self.path))
        compressed = Path(f"{original}.gz")
        if "gzip" in self.headers.get("Accept-Encoding", "") and compressed.is_file():
            file = compressed.open("rb")
            self.send_response(200)
            self.send_header("Content-Type", self.guess_type(str(original)))
            self.send_header("Content-Encoding", "gzip")
            self.send_header("Content-Length", str(compressed.stat().st_size))
            self.send_header("Vary", "Accept-Encoding")
            self.end_headers()
            return file
        return super().send_head()

    def do_GET(self):
        if self.path.startswith(("/api/", "/health")):
            self.forward_to_backend()
        else:
            super().do_GET()

    def do_POST(self):
        if self.path.startswith("/api/"):
            self.forward_to_backend()
        else:
            self.send_error(404)

    def forward_to_backend(self):
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length) if length else None
        headers = {"Content-Type": self.headers.get("Content-Type", "application/json")}
        connection = HTTPConnection("127.0.0.1", 8000, timeout=30)
        try:
            connection.request(self.command, self.path, body=body, headers=headers)
            response = connection.getresponse()
            content = response.read()
            self.send_response(response.status)
            self.send_header("Content-Type", response.getheader("Content-Type", "application/json"))
            self.send_header("Content-Length", str(len(content)))
            self.end_headers()
            self.wfile.write(content)
        finally:
            connection.close()


web_root = Path(__file__).resolve().parents[1] / "mobile" / "build" / "web"
handler = partial(PreviewHandler, directory=str(web_root))
ThreadingHTTPServer(("0.0.0.0", 3000), handler).serve_forever()
