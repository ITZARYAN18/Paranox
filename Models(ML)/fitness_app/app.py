# app.py
# Fixes:
# 1. Corrected import to `from counters import ...`
# 2. Corrected the final block to `if __name__ == "__main__":`

import env_setup  # noqa: F401  Ensure env variables & warnings suppressed early
import time
from pathlib import Path
import tempfile

import cv2
import numpy as np
import streamlit as st
from counters import SitupCounter, JumpCounter


st.set_page_config(page_title="Fitness Counter", layout="wide")


def main():
    st.title("Fitness Counter: Sit-ups and Jumps")

    with st.sidebar:
        st.header("Mode")
        kind = st.selectbox("Choose activity", ["situp", "jump"])  # situp or jump
        input_mode = st.radio("Input", ["Webcam (local)", "Upload video (local)"])

    col1, col2 = st.columns([2, 1])

    if input_mode == "Webcam (local)":
        with col1:
            st.subheader("Local Webcam")
            start_cam = st.button("Start Webcam")
            stop_cam = st.button("Stop Webcam")
            frame_box = st.empty()
        with col2:
            st.subheader("Live Count")
            count_box = st.empty()

        if "cam_running" not in st.session_state:
            st.session_state.cam_running = False
        if start_cam:
            st.session_state.cam_running = True
        if stop_cam:
            st.session_state.cam_running = False

        if st.session_state.cam_running:
            counter = SitupCounter() if kind == "situp" else JumpCounter()
            cap = cv2.VideoCapture(0)
            if not cap.isOpened():
                st.error("Could not open webcam 0. Try another index.")
            else:
                try:
                    while st.session_state.cam_running:
                        ok, frame = cap.read()
                        if not ok:
                            st.warning("Webcam frame not read. Stopping.")
                            break
                        frame, info = counter.process_frame(frame)
                        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                        frame_box.image(frame_rgb, caption=f"Count: {info.get('count', 0)}", use_column_width=True)
                        count_box.metric("Count", int(info.get("count", 0)))
                        time.sleep(0.01) # A small sleep to prevent high CPU usage
                finally:
                    cap.release()
                    counter.close()

    elif input_mode == "Upload video (local)":
        with col1:
            st.subheader("Upload a video")
            uploaded = st.file_uploader("Choose a video file", type=["mp4", "mov", "avi", "mkv"])
            start = st.button("Process")
        with col2:
            st.subheader("Result")
            result_box = st.empty()
            preview = st.empty()
            live_count = st.empty()

        if start and uploaded is not None:
            # Create a safe temporary file path
            suffix = Path(uploaded.name).suffix or ".mp4"
            with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
                tmp.write(uploaded.getvalue())
                tmp_path = tmp.name

            counter = SitupCounter() if kind == "situp" else JumpCounter()
            cap = cv2.VideoCapture(tmp_path)
            if not cap.isOpened():
                result_box.error("Failed to open uploaded video.")
            else:
                try:
                    frame_placeholder = preview.image(np.zeros((480, 640, 3), dtype=np.uint8), caption="Processing...", use_column_width=True)
                    while cap.isOpened():
                        ok, frame = cap.read()
                        if not ok:
                            break
                        frame, info = counter.process_frame(frame)
                        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                        frame_placeholder.image(frame_rgb, caption=f"Count: {info.get('count', 0)}", use_column_width=True)
                        live_count.metric(label="Live Count", value=int(info.get("count", 0)))
                        time.sleep(0.01) # A small sleep to mimic video frame rate
                    result_box.success("Processing Done.")
                finally:
                    cap.release()
                    counter.close()
                    try:
                        Path(tmp_path).unlink()
                    except Exception:
                        pass


if __name__ == "__main__":
    main()