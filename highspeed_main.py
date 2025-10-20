from hikvisionapi import Client
import cv2
import time

cam = Client('http://192.168.1.218:218', 'admin', 'peal2024', timeout=30)
response = cam.Streaming.channels[102].picture(method='get', type='opaque_data'
)

start = time.time()

with open('screen{}.jpg'.format(1), 'wb') as f:
        for chunk in response.iter_content(chunk_size=1024):
            if chunk:
                f.write(chunk)

end = time.time()
# 0.005s

print(f"{end - start:.5f} sec")