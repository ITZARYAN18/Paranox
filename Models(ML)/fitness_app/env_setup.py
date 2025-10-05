import os
import warnings

# Reduce TensorFlow / TFLite verbosity before they are imported by mediapipe
os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "2")  # 0=all,1=info,2=warning,3=error
# Optionally disable oneDNN custom ops if they spam logs
os.environ.setdefault("TF_ENABLE_ONEDNN_OPTS", "0")

# Suppress common deprecation/runtime warnings from protobuf/tensorflow in console
warnings.filterwarnings("ignore", category=UserWarning, module=r"google\.protobuf\..*")
warnings.filterwarnings("ignore", category=FutureWarning)
warnings.filterwarnings("ignore", category=DeprecationWarning)

try:
    # Silence absl logging used by mediapipe
    from absl import logging as absl_logging
    absl_logging.set_verbosity(absl_logging.ERROR)
except Exception:
    pass