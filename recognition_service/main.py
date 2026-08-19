from fastapi import FastAPI, UploadFile, File
from engines.face_shape.engine import FaceShapeEngine
from common.image_utils import load_image
import uvicorn
from config import API_HOST, API_PORT

app = FastAPI(title="TRIME Recognition Service")

# Initialize engines
face_shape_engine = FaceShapeEngine()

@app.on_event("startup")
async def startup_event():
    face_shape_engine.load_model()

@app.get("/")
async def root():
    return {"message": "TRIME Recognition Service is running"}

@app.post("/analyze/face-shape")
async def analyze_face_shape(file: UploadFile = File(...)):
    contents = await file.read()
    image = load_image(contents)
    
    if image is None:
        return {"error": "Invalid image format"}
    
    result = face_shape_engine.process(image)
    
    # Remove landmarks from response for cleaner output, 
    # or keep if needed for debugging UI
    if "landmarks" in result:
        del result["landmarks"]
        
    return result

if __name__ == "__main__":
    uvicorn.run(app, host=API_HOST, port=API_PORT)
