import cv2
import numpy as np

def load_image(image_path_or_bytes):
    """Loads an image from path or bytes."""
    if isinstance(image_path_or_bytes, (str, bytes)):
        if isinstance(image_path_or_bytes, str):
            return cv2.imread(image_path_or_bytes)
        else:
            nparr = np.frombuffer(image_path_or_bytes, np.uint8)
            return cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    return None

def preprocess_for_ai(img):
    """Common preprocessing for face detection."""
    if img is None:
        return None
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    equalized = cv2.equalizeHist(gray)
    return equalized

def draw_landmarks(img, landmarks_dict, color=(0, 255, 0)):
    """Utility to draw landmarks on image."""
    result = img.copy()
    for i, (x, y) in landmarks_dict.items():
        cv2.circle(result, (x, y), 3, color, -1)
    return result
