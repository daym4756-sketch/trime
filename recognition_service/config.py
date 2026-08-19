import os
from pathlib import Path
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent

ENV_FILE = BASE_DIR / ".env"
if ENV_FILE.exists():
    load_dotenv(dotenv_path=ENV_FILE)
else:
    load_dotenv()

MODELS_DIR = BASE_DIR / "models"

FACE_SHAPE_MODELS = {
    "landmarks": MODELS_DIR / "shape_predictor_68_face_landmarks.dat",
    "scaler": MODELS_DIR / "scaler.pkl",
    "pca": MODELS_DIR / "pca.pkl",
    "svm": MODELS_DIR / "svm_rbf_best.pkl",
}

BIREFNET_CONFIG = {
    "weights_path": MODELS_DIR / "birefnet_general.pth",
    "input_size": 1024,
}

API_HOST = os.getenv("API_HOST", "0.0.0.0")
API_PORT = int(os.getenv("API_PORT", "8001"))
API_SECRET = os.getenv("API_SECRET", "trime_dev_secret")

LOG_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"

ENABLE_WA_NOTIF = os.getenv("ENABLE_WA_NOTIF", "true").lower() == "true"
ENABLE_FACE_ANALYSIS = os.getenv("ENABLE_FACE_ANALYSIS", "true").lower() == "true"

WA_PROVIDER = os.getenv("WA_PROVIDER", "fonnte")

FONNTE_CONFIG = {
    "token": os.getenv("WA_FONNTE_TOKEN", ""),
    "base_url": os.getenv("WA_FONNTE_BASE_URL", "https://api.fonnte.com/send"),
}

WHACENTER_CONFIG = {
    "token": os.getenv("WA_WHACENTER_TOKEN", ""),
    "base_url": os.getenv("WA_WHACENTER_BASE_URL", "https://app.whacenter.com/api"),
}

TWILIO_CONFIG = {
    "account_sid": os.getenv("TWILIO_ACCOUNT_SID", ""),
    "auth_token": os.getenv("TWILIO_AUTH_TOKEN", ""),
    "wa_from": os.getenv("TWILIO_WA_FROM", "whatsapp:+14155238886"),
}

SUPABASE_CONFIG = {
    "url": os.getenv("SUPABASE_URL", ""),
    "anon_key": os.getenv("SUPABASE_ANON_KEY", ""),
    "service_key": os.getenv("SUPABASE_SERVICE_KEY", ""),
}

REMINDER_MINUTES_BEFORE = int(os.getenv("REMINDER_MINUTES_BEFORE", "30"))
SCHEDULER_ENABLED = os.getenv("SCHEDULER_ENABLED", "true").lower() == "true"
