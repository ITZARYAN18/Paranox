import os
import uuid
import tempfile
import cv2
import uvicorn
from fastapi import FastAPI, UploadFile, File, Body
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse

# Import your logic classes from your other file
from counters import SitupCounter, JumpCounter

# --- FastAPI Application Setup ---
app = FastAPI(title="Fitness AI Trainer")
os.makedirs("processed_videos", exist_ok=True)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Endpoint to Serve the Processed Videos ---
@app.get("/get_video/{video_name}")
def get_video(video_name: str):
    video_path = os.path.join("processed_videos", video_name)
    if os.path.exists(video_path):
        return FileResponse(video_path, media_type="video/mp4")
    return {"error": "File not found"}


# --- Simplified, Reliable Video Processing Function ---
def process_video_with_counter(video_path, counter_instance, base_url):
    cap = cv2.VideoCapture(video_path)
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = int(cap.get(cv2.CAP_PROP_FPS))

    output_filename = f"{uuid.uuid4()}.mp4"
    output_path = os.path.join("processed_videos", output_filename)
    
    fourcc = cv2.VideoWriter_fourcc(*'avc1')
    out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))
    
    final_info = {}
    try:
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break
            
            processed_frame, info = counter_instance.process_frame(frame)
            final_info = info
            out.write(processed_frame)
    finally:
        print("Releasing video resources.")
        cap.release()
        out.release()
        counter_instance.close()

    # --- NEW: Add placeholder metrics to the response ---
    # TODO: Connect these to your actual model's output in counters.py
    final_info["consistency_score"] = 0.85 
    final_info["average_depth_angle"] = 45.3

    final_info["processed_video_url"] = f"{base_url}get_video/{output_filename}"
    return final_info


# --- NEW: Endpoint to Generate Detailed Feedback ---
@app.post("/generate_feedback")
async def generate_feedback(stats: dict = Body(...)):
    reps = stats.get("count", 0)
    consistency = stats.get("consistency_score", 0)
    angle = stats.get("average_depth_angle", 90)

    # In a real app, you would call an AI Language Model API (like Gemini) here.
    # For now, we'll simulate the AI's response with formatted text.
    simulated_ai_response = (
        f"Great set! You hit {reps} reps with a solid {int(consistency * 100)}% consistency score. "
        f"Your average depth was excellent. To improve further, focus on keeping your core tight throughout the entire movement. "
        "Keep up the great work!"
    )
    
    return {"feedback": simulated_ai_response}


# --- API Prediction Endpoints (Unchanged) ---
@app.post("/predict_situp")
async def predict_situp(file: UploadFile = File(...)):
    base_url = "http://10.223.35.72:8000/"
    with tempfile.NamedTemporaryFile(delete=False, suffix=".mp4") as tmp:
        tmp.write(await file.read())
        tmp_path = tmp.name
    result = process_video_with_counter(tmp_path, SitupCounter(), base_url)
    os.remove(tmp_path)
    return result

@app.post("/predict_jump")
async def predict_jump(file: UploadFile = File(...)):
    base_url = "http://10.223.35.72:8000/"
    with tempfile.NamedTemporaryFile(delete=False, suffix=".mp4") as tmp:
        tmp.write(await file.read())
        tmp_path = tmp.name
    result = process_video_with_counter(tmp_path, JumpCounter(), base_url)
    os.remove(tmp_path)
    return result

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)