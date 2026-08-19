import os
from pathlib import Path

# Base directory
BASE_DIR = Path(__file__).resolve().parent

# Models directory
MODELS_DIR = BASE_DIR / "models"

# Face Shape Model Paths
FACE_SHAPE_MODELS = {
    "landmarks": MODELS_DIR / "shape_predictor_68_face_landmarks.dat",
    "scaler": MODELS_DIR / "scaler.pkl",
    "pca": MODELS_DIR / "pca.pkl",
    "svm": MODELS_DIR / "svm_rbf_best.pkl",
}

# BiRefNet Settings (To be integrated)
BIREFNET_CONFIG = {
    "weights_path": MODELS_DIR / "birefnet_general.pth", # Placeholder for BiRefNet weights
    "input_size": 1024,
}

# API Settings
API_HOST = "0.0.0.0"
API_PORT = 8001

# Logging
LOG_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
