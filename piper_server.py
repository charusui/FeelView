import http.server
import socketserver
import subprocess
import urllib.parse
import os
import tempfile

PORT = 5000
MODEL_PATH = "en_US-amy-medium.onnx"

class PiperHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        if parsed.path == "/tts":
            params = urllib.parse.parse_qs(parsed.query)
            text = params.get("text", [""])[0]
            if not text:
                self.send_response(400)
                self.end_headers()
                self.wfile.write(b"Missing text parameter")
                return

            try:
                with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
                    tmp_wav = f.name
                
                subprocess.run(
                    ["python", "-m", "piper", "-m", MODEL_PATH, "-f", tmp_wav],
                    input=text,
                    text=True,
                    check=True,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL
                )

                with open(tmp_wav, "rb") as f:
                    audio_data = f.read()

                try:
                    os.remove(tmp_wav)
                except Exception:
                    pass

                self.send_response(200)
                self.send_header("Content-Type", "audio/wav")
                self.send_header("Access-Control-Allow-Origin", "*")
                self.send_header("Content-Length", str(len(audio_data)))
                self.end_headers()
                self.wfile.write(audio_data)
            except Exception as e:
                self.send_response(500)
                self.send_header("Access-Control-Allow-Origin", "*")
                self.end_headers()
                self.wfile.write(f"TTS Error: {e}".encode("utf-8"))
        else:
            self.send_response(404)
            self.end_headers()

with socketserver.TCPServer(("", PORT), PiperHandler) as httpd:
    print(f"🎤 Piper TTS Server running at http://localhost:{PORT}/tts?text=Hello")
    print(f"Using model: {MODEL_PATH}")
    httpd.serve_forever()
