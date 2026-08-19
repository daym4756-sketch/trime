import dlib
import joblib
import numpy as np
import math
from common.base_engine import BaseAIEngine
from common.image_utils import preprocess_for_ai
from config import FACE_SHAPE_MODELS

class FaceShapeEngine(BaseAIEngine):
    def __init__(self):
        super().__init__("FaceShapeClassification")
        self.detector = None
        self.predictor = None
        self.scaler = None
        self.pca = None
        self.svm = None

    def load_model(self):
        """Loads all required models for face shape classification."""
        try:
            self.detector = dlib.get_frontal_face_detector()
            self.predictor = dlib.shape_predictor(str(FACE_SHAPE_MODELS["landmarks"]))
            self.scaler = joblib.load(str(FACE_SHAPE_MODELS["scaler"]))
            self.pca = joblib.load(str(FACE_SHAPE_MODELS["pca"]))
            self.svm = joblib.load(str(FACE_SHAPE_MODELS["svm"]))
            self.is_loaded = True
            print(f"Engine {self.model_name} loaded successfully.")
        except Exception as e:
            print(f"Error loading {self.model_name}: {e}")
            self.is_loaded = False

    def process(self, image):
        """
        Processes an image and returns the predicted face shape.
        """
        if not self.is_loaded:
            self.load_model()

        gray = preprocess_for_ai(image)
        faces = self.detector(gray)
        
        if len(faces) == 0:
            return {"error": "Face not detected", "status": "failed"}

        # Detect landmarks
        landmarks = self.predictor(gray, faces[0])
        landmarks_dict = {i: (landmarks.part(i).x, landmarks.part(i).y) for i in range(68)}

        # Add hairline (Simplified version for now)
        self._add_hairline(image, landmarks_dict)
        
        # Compute features
        features = self._compute_features(landmarks_dict)
        
        # Prediction
        features_scaled = self.scaler.transform([features])
        features_pca = self.pca.transform(features_scaled)
        prediction = self.svm.predict(features_pca)
        
        return {
            "face_shape": prediction[0],
            "landmarks": landmarks_dict,
            "status": "success"
        }

    def _add_hairline(self, img, landmarks_dict):
        """Helper to add hairline point (Point 68)."""
        x_forehead = int((landmarks_dict[19][0] + landmarks_dict[24][0]) / 2)
        y_forehead = landmarks_dict[19][1] - 20
        # For MVP, using a simple offset if hairline detection logic is complex
        # In production, we'd use the more complex detect_hairline from original tool
        landmarks_dict[68] = (x_forehead, y_forehead - 30)

    def _compute_features(self, landmarks_dict):
        """Geometric feature extraction logic."""
        def dist(p1, p2):
            return math.sqrt((p1[0] - p2[0]) ** 2 + (p1[1] - p2[1]) ** 2)

        F1 = dist(landmarks_dict[8], landmarks_dict[68]) / dist(landmarks_dict[0], landmarks_dict[16])
        F2 = dist(landmarks_dict[4], landmarks_dict[12]) / dist(landmarks_dict[0], landmarks_dict[16])
        F3 = dist(landmarks_dict[8], landmarks_dict[57]) / dist(landmarks_dict[4], landmarks_dict[12])

        chin = landmarks_dict[8]
        angles = []
        for i in list(range(0, 8)) + list(range(9, 17)):
            p = landmarks_dict[i]
            angle = math.degrees(math.atan2(chin[1] - p[1], chin[0] - p[0]))
            angles.append(angle)

        return [F1, F2, F3] + angles
