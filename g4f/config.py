from __future__ import annotations

import os
import sys
from pathlib import Path
from functools import lru_cache

@lru_cache(maxsize=1)
def get_config_dir() -> Path:
    """Get platform-appropriate config directory."""
    if sys.platform == "win32":
        return Path(os.environ.get("APPDATA", Path.home() / "AppData" / "Roaming"))
    elif sys.platform == "darwin":
        return Path.home() / "Library" / "Application Support"
    return Path.home() / ".config"

DEFAULT_PORT = 1337
DEFAULT_TIMEOUT = 600
DEFAULT_STREAM_TIMEOUT = 15

PACKAGE_NAME = "g4f"
CONFIG_DIR = get_config_dir() / PACKAGE_NAME
COOKIES_DIR = CONFIG_DIR / "cookies"
# 使用环境变量 G4F_STORAGE_PATH 配置基础存储路径，以支持持久化存储
# 在 K8s 中，应设置 G4F_STORAGE_PATH=/data (或其他挂载点)
# 如果环境变量未设置，则回退到 /tmp，这在本地测试或非持久化场景中很有用
BASE_STORAGE_PATH = os.getenv("G4F_STORAGE_PATH", "/tmp")
CUSTOM_COOKIES_DIR = os.path.join(BASE_STORAGE_PATH, "har_and_cookies")
ORGANIZATION = "gpt4free"
GITHUB_REPOSITORY = f"xtekky/{ORGANIZATION}"
STATIC_DOMAIN = f"{PACKAGE_NAME}.dev"
STATIC_URL = f"https://static.{STATIC_DOMAIN}/"
DIST_DIR = f"./{STATIC_DOMAIN}/dist"
DEFAULT_MODEL = "openai/gpt-oss-120b"
JSDELIVR_URL = "https://cdn.jsdelivr.net/"
DOWNLOAD_URL = f"{JSDELIVR_URL}gh/{ORGANIZATION}/{STATIC_DOMAIN}/"
GITHUB_URL = f"https://raw.githubusercontent.com/{ORGANIZATION}/{STATIC_DOMAIN}/refs/heads/main/"