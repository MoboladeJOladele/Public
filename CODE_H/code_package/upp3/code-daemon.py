import os
import platform
from datetime import datetime
import requests
import json
import subprocess

# === Paths & Config ===
DIR = os.path.dirname(os.path.abspath(__file__))
LOCAL_VERSION_FILE = os.path.join(DIR, "codeh.version")
REMOTE_VERSION_URL = "https://raw.githubusercontent.com/MoboladeJOladele/Public/main/CODE_H/codeh.version"
LOG_FILE = os.path.join(DIR, "code.log")
META_PATH = os.path.join(DIR, "code.meta.json")  # or use absolute "C:\\ProgramData\\CODE_H\\code.meta.json"
RESET_THRESHOLD_DAYS = 29.8

# === Logging ===
def log(message):
    timestamp = datetime.now().strftime("[%Y-%m-%d %H:%M:%S]")
    with open(LOG_FILE, "a") as log_file:
        log_file.write(f"{timestamp} {message}\n")

# === Version Fetchers ===
def get_local_version():
    try:
        with open(LOCAL_VERSION_FILE, "r") as f:
            return f.read().strip()
    except Exception as e:
        log(f"Error reading local version: {e}")
        return None

def get_remote_version():
    try:
        response = requests.get(REMOTE_VERSION_URL)
        if response.ok:
            return response.text.strip()
        else:
            log(f"HTTP error {response.status_code} fetching remote version")
    except Exception as e:
        log(f"Error fetching remote version: {e}")
    return None

# === OS-Specific Updater Dispatcher ===
def call_update_script():
    os_type = platform.system().lower()

    try:
        if "windows" in os_type:
            os.system(f'powershell -ExecutionPolicy Bypass -File "{os.path.join(DIR, "code-update.ps1")}"')
        elif "linux" in os_type or "darwin" in os_type:
            os.system(f'bash "{os.path.join(DIR, "code-update.sh")}"')
        else:
            log("Unsupported OS")
    except Exception as e:
        log(f"Error calling update script: {e}")

# === Windows Auto-Renew Scheduler Logic ===
def maybe_reset_task():
    if os.name != 'nt':
        return

    if not os.path.exists(META_PATH):
        return

    try:
        with open(META_PATH, "r") as f:
            meta = json.load(f)

        install_time_str = meta.get("install_time")
        if not install_time_str:
            return

        install_time = datetime.fromisoformat(install_time_str)
        now = datetime.now()
        days_elapsed = (now - install_time).total_seconds() / 86400

        if days_elapsed >= RESET_THRESHOLD_DAYS:
            log("Refreshing Windows scheduled task...")

            # Delete the old task silently
            subprocess.run([
                "schtasks", "/Delete", "/TN", "CODE_H_AutoUpdate", "/F"
            ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

            # Re-register it
            exe_path = os.path.join(DIR, "code-daemon.py")

            subprocess.run([
                "schtasks", "/Create",
                "/SC", "HOURLY", "/MO", "2",
                "/TN", "CodeHDaemon",
                "/TR", f'python "{exe_path}"',
                "/ST", now.strftime("%H:%M"),
                "/DU", "30:00",
                "/RL", "HIGHEST"
            ], check=False)

            # Update install_time in meta
            meta["install_time"] = now.isoformat()
            with open(META_PATH, "w") as f:
                json.dump(meta, f, indent=4)

            log("Scheduled task refreshed and install_time updated.")
    except Exception as e:
        log(f"Error while resetting task: {e}")

# === Main Logic ===
def main():
    maybe_reset_task()

    local = get_local_version()
    remote = get_remote_version()

    log(f"Local: {local} | Remote: {remote}")

    if local and remote and local != remote:
        log("Update required. Running updater...")
        call_update_script()
    else:
        log("Already up to date.")

if __name__ == "__main__":
    main()
