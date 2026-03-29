import cv2
import numpy as np
import hashlib

img = np.zeros((100, 100, 3), np.uint8)
img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
img_bytes = img_gray.tobytes()
checksum = hashlib.sha256(img_bytes).hexdigest()

print(f"Checksum: {checksum}")
