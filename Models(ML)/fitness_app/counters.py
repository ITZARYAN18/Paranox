# counters.py

import cv2
import mediapipe as mp
import numpy as np
from collections import deque

# Corrected EMASmooth    --er class
class EMASmoother:
    def __init__(self, alpha: float = 0.15) -> None:
        self.alpha = float(alpha)
        self.smoothed_value = None

    def smooth(self, new_value: float) -> float:
        if self.smoothed_value is None:
            self.smoothed_value = float(new_value)
        else:
            self.smoothed_value = self.alpha * float(new_value) + (1.0 - self.alpha) * float(self.smoothed_value)
        return float(self.smoothed_value)


def calculate_angle(a, b, c) -> float:
    a = np.array(a)
    b = np.array(b)
    c = np.array(c)
    radians = np.arctan2(c[1] - b[1], c[0] - b[0]) - np.arctan2(a[1] - b[1], a[0] - b[0])
    angle = np.abs(radians * 180.0 / np.pi)
    if angle > 180.0:
        angle = 360.0 - angle
    return float(angle)


# Corrected BaseCounter class with __init__
class BaseCounter:
    def __init__(self) -> None:
        self.mp_pose = mp.solutions.pose
        self.pose = self.mp_pose.Pose(min_detection_confidence=0.6, min_tracking_confidence=0.6)
        self.mp_drawing = mp.solutions.drawing_utils

    def close(self) -> None:
        if hasattr(self, 'pose') and self.pose:
            self.pose.close()

    def draw_landmarks(self, frame, results) -> None:
        if results.pose_landmarks:
            self.mp_drawing.draw_landmarks(
                frame,
                results.pose_landmarks,
                self.mp_pose.POSE_CONNECTIONS,
            )


# Unchanged SitupCounter class
class SitupCounter(BaseCounter):
    def __init__(self) -> None:
        super().__init__()
        self.counter = 0
        self.stage = "up"
        self.ema = EMASmoother(alpha=0.15)

    @staticmethod
    def _best_side_landmarks(landmarks, mp_pose):
        left_vis = np.mean([
            landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER.value].visibility,
            landmarks[mp_pose.PoseLandmark.LEFT_HIP.value].visibility,
            landmarks[mp_pose.PoseLandmark.LEFT_KNEE.value].visibility,
        ])
        right_vis = np.mean([
            landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER.value].visibility,
            landmarks[mp_pose.PoseLandmark.RIGHT_HIP.value].visibility,
            landmarks[mp_pose.PoseLandmark.RIGHT_KNEE.value].visibility,
        ])
        min_vis = 0.3
        if left_vis >= right_vis and left_vis > min_vis:
            return (
                [landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER.value].x, landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER.value].y],
                [landmarks[mp_pose.PoseLandmark.LEFT_HIP.value].x, landmarks[mp_pose.PoseLandmark.LEFT_HIP.value].y],
                [landmarks[mp_pose.PoseLandmark.LEFT_KNEE.value].x, landmarks[mp_pose.PoseLandmark.LEFT_KNEE.value].y],
            )
        if right_vis > min_vis:
            return (
                [landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER.value].x, landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER.value].y],
                [landmarks[mp_pose.PoseLandmark.RIGHT_HIP.value].x, landmarks[mp_pose.PoseLandmark.RIGHT_HIP.value].y],
                [landmarks[mp_pose.PoseLandmark.RIGHT_KNEE.value].x, landmarks[mp_pose.PoseLandmark.RIGHT_KNEE.value].y],
            )
        if left_vis >= right_vis:
            return (
                [landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER.value].x, landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER.value].y],
                [landmarks[mp_pose.PoseLandmark.LEFT_HIP.value].x, landmarks[mp_pose.PoseLandmark.LEFT_HIP.value].y],
                [landmarks[mp_pose.PoseLandmark.LEFT_KNEE.value].x, landmarks[mp_pose.PoseLandmark.LEFT_KNEE.value].y],
            )
        return (
            [landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER.value].x, landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER.value].y],
            [landmarks[mp_pose.PoseLandmark.RIGHT_HIP.value].x, landmarks[mp_pose.PoseLandmark.RIGHT_HIP.value].y],
            [landmarks[mp_pose.PoseLandmark.RIGHT_KNEE.value].x, landmarks[mp_pose.PoseLandmark.RIGHT_KNEE.value].y],
        )

    def process_frame(self, frame):
        image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        image.flags.writeable = False
        results = self.pose.process(image)
        image.flags.writeable = True
        output = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)

        angle = None
        if results.pose_landmarks:
            lm = results.pose_landmarks.landmark
            sel = self._best_side_landmarks(lm, self.mp_pose)
            if sel:
                shoulder, hip, knee = sel
                angle = calculate_angle(shoulder, hip, knee)
                s_angle = self.ema.smooth(angle)
                if s_angle < 90:
                    if self.stage == "up":
                        self.stage = "down"
                if s_angle > 150:
                    if self.stage == "down":
                        self.counter += 1
                        self.stage = "up"

        self.draw_landmarks(output, results)
        cv2.putText(output, f"Reps: {self.counter}", (30, 60), cv2.FONT_HERSHEY_SIMPLEX, 1.2, (0, 0, 0), 3, cv2.LINE_AA)
        cv2.putText(output, f"Stage: {self.stage}", (30, 100), cv2.FONT_HERSHEY_SIMPLEX, 1.2, (0, 0, 0), 3, cv2.LINE_AA)
        return output, {"count": self.counter, "stage": self.stage, "angle": angle}


# Corrected JumpCounter class with __init__
class JumpCounter(BaseCounter):
    def __init__(self) -> None:
        super().__init__()
        self.jump_counter = 0
        self.state = "CALIBRATING"
        self.feedback = "Stand Still for Calibration"
        self.calibrated = False
        self.calibration_frames = 60
        self.calib_hip = []
        self.calib_shoulder = []
        self.standing_y_hip = 0.0
        self.crouch_threshold = 0.0
        self.pixels_to_cm_ratio = 1.0
        self.current_jump_peak = 0.0
        self.last_jump_height_cm = 0.0
        self.hip_y_history = deque(maxlen=5)
        self.previous_hip_y = 0.0
        self.hip_ema = EMASmoother(alpha=0.4)

    def process_frame(self, frame):
        h, w, _ = frame.shape
        image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        image.flags.writeable = False
        results = self.pose.process(image)
        image.flags.writeable = True
        output = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)

        try:
            landmarks = results.pose_landmarks.landmark
            left_hip = landmarks[self.mp_pose.PoseLandmark.LEFT_HIP.value]
            right_hip = landmarks[self.mp_pose.PoseLandmark.RIGHT_HIP.value]
            left_shoulder = landmarks[self.mp_pose.PoseLandmark.LEFT_SHOULDER.value]
            right_shoulder = landmarks[self.mp_pose.PoseLandmark.RIGHT_SHOULDER.value]

            hip_y_raw = ((left_hip.y + right_hip.y) / 2.0) * h
            shoulder_y_raw = ((left_shoulder.y + right_shoulder.y) / 2.0) * h

            self.hip_y_history.append(hip_y_raw)
            hip_y = float(np.mean(self.hip_y_history))

            if self.calibration_frames > 0:
                self.state = "CALIBRATING"
                self.feedback = f"Stand Still for Calibration ({self.calibration_frames // 30}s)"
                self.calib_hip.append(hip_y)
                self.calib_shoulder.append(shoulder_y_raw)
                self.calibration_frames -= 1
            elif not self.calibrated:
                self.standing_y_hip = float(np.mean(self.calib_hip)) if self.calib_hip else hip_y
                standing_y_shoulder = float(np.mean(self.calib_shoulder)) if self.calib_shoulder else shoulder_y_raw
                torso_height_pixels = abs(self.standing_y_hip - standing_y_shoulder)
                if torso_height_pixels > 0:
                    self.pixels_to_cm_ratio = 50.0 / torso_height_pixels
                self.crouch_threshold = self.standing_y_hip + (10.0 / self.pixels_to_cm_ratio)
                self.calibrated = True
                self.state = "IDLE"
                self.feedback = "Calibration Complete! Ready to Jump."
                self.previous_hip_y = self.standing_y_hip

            if self.calibrated:
                hip_smoothed = self.hip_ema.smooth(hip_y)
                velocity = hip_smoothed - self.previous_hip_y
                self.previous_hip_y = hip_y
                if self.state == "IDLE":
                    if hip_y > self.crouch_threshold:
                        self.state = "CROUCHING"
                        self.feedback = "Crouching..."
                elif self.state == "CROUCHING":
                    if velocity < -2.0:
                        self.state = "JUMPING"
                        self.feedback = "JUMP!"
                        self.current_jump_peak = hip_y
                elif self.state == "JUMPING":
                    self.current_jump_peak = min(self.current_jump_peak, hip_y)
                    if velocity > 0.5:
                        jump_height_pixels = self.standing_y_hip - self.current_jump_peak
                        self.last_jump_height_cm = jump_height_pixels * self.pixels_to_cm_ratio
                        self.jump_counter += 1
                        self.state = "IDLE"
                        self.feedback = "Nice jump!"
        except Exception:
            self.feedback = "Body not visible. Please step back."

        overlay = output.copy()
        alpha = 0.7
        cv2.rectangle(overlay, (20, 20), (340, 160), (29, 29, 29), -1)
        cv2.putText(overlay, 'JUMP COUNT', (40, 50), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (200, 200, 200), 2, cv2.LINE_AA)
        cv2.putText(overlay, str(self.jump_counter), (45, 125), cv2.FONT_HERSHEY_SIMPLEX, 2.5, (255, 255, 255), 4, cv2.LINE_AA)
        cv2.putText(overlay, 'LAST JUMP (CM)', (160, 50), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (200, 200, 200), 2, cv2.LINE_AA)
        cv2.putText(overlay, f"{self.last_jump_height_cm:.1f}", (165, 125), cv2.FONT_HERSHEY_SIMPLEX, 2.5, (255, 255, 255), 4, cv2.LINE_AA)

        bar_color = (29, 29, 29)
        text_color = (255, 255, 255)
        if self.state == 'JUMPING': bar_color = (0, 255, 0)
        elif self.state == 'CALIBRATING':
            bar_color = (0, 255, 255)
            text_color = (0, 0, 0)

        cv2.rectangle(overlay, (20, h - 70), (w - 20, h - 20), bar_color, -1)
        (text_w, _), _ = cv2.getTextSize(self.feedback, cv2.FONT_HERSHEY_SIMPLEX, 0.9, 2)
        cv2.putText(overlay, self.feedback, (int((w - text_w) / 2), h - 38), cv2.FONT_HERSHEY_SIMPLEX, 0.9, text_color, 2, cv2.LINE_AA)
        output = cv2.addWeighted(overlay, alpha, output, 1 - alpha, 0)

        self.draw_landmarks(output, results)
        if self.calibrated:
            cv2.line(output, (0, int(self.crouch_threshold)), (w, int(self.crouch_threshold)), (0, 0, 255), 2, cv2.LINE_AA)

        return output, {
            "count": self.jump_counter,
            "state": self.state,
            "last_jump_cm": round(float(self.last_jump_height_cm), 1),
        }