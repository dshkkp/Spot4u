import gzip
import hashlib
import os
import re
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MOBILE = ROOT / "mobile"
WEB = MOBILE / "build" / "web"
if WEB.exists():
    shutil.rmtree(WEB)

subprocess.run(
    [
        os.getenv("FLUTTER_BIN", "flutter"),
        "build",
        "web",
        "--release",
        "--web-content-hash",
        "--no-web-resources-cdn",
        "--dart-define=SPOT4U_API_URL=/",
    ],
    cwd=MOBILE,
    check=True,
)

bootstrap = WEB / "flutter_bootstrap.js"
content = bootstrap.read_text()
updated, replacements = re.subn(
    r"_flutter\.loader\.load\(\{\n  serviceWorkerSettings: \{\n    serviceWorkerVersion: \"[^\"]+\"[^\n]*\n  \}\n\}\);",
    "_flutter.loader.load();",
    content,
)
if replacements != 1:
    raise RuntimeError("Не удалось отключить deprecated Flutter Service Worker")
bootstrap.write_text(updated)

cache_key = hashlib.sha256(
    (WEB / "precache_manifest.json").read_bytes()
    + (MOBILE / "web" / "sw.js").read_bytes()
    + (WEB / "index.html").read_bytes()
).hexdigest()[:12]
service_worker = WEB / "sw.js"
service_worker.write_text(
    service_worker.read_text().replace("__SPOT4U_CACHE_NAME__", f"spot4u-static-{cache_key}")
)

for path in WEB.rglob("*"):
    if path.suffix in (".js", ".json", ".html", ".ttf", ".otf", ".wasm", ".png") and path.is_file():
        with path.open("rb") as source, gzip.open(f"{path}.gz", "wb", compresslevel=9) as output:
            output.writelines(source)

print(f"PWA собрано: {WEB}")
