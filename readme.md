# Setup
* It is really hard find good and updated reference. Since ONVIF is open-sourced protocol, But HikVision camera of mine seems to not following basic protocols. So i have to improvise from using PTZ to Presets.
* https://github.com/FalkTannhaeuser/python-onvif-zeep?tab=readme-ov-file
* https://github.com/FalkTannhaeuser/python-onvif-zeep/issues

```bash
git clone https://github.com/FalkTannhaeuser/python-onvif-zeep.git
pip install zeep
pip install onvif_zeep
```
# Code
* TODO : Make Multiple instance at once
```python
import logging
import time
from onvif import ONVIFCamera

class CameraControl:
    def __init__(self, ip, port, user, password):
        self.__cam_ip = ip
        self.__cam_port = port
        self.__cam_user = user
        self.__cam_password = password

    def camera_start(self):
        """
        Creates the connection to the camera using the onvif protocol
        Returns:
        Return the ptz service object and media service object
        """
        mycam = ONVIFCamera(self.__cam_ip, self.__cam_port, self.__cam_user, self.__cam_password)  ## Some cameras use port 8080
        logging.info('Create media service object')
        media = mycam.create_media_service()
        logging.info('Create ptz service object')
        ptz = mycam.create_ptz_service()
        logging.info('Get target profile')
        media_profile = media.GetProfiles()[0]
        logging.info('Camera working!')

        self.mycam = mycam
        self.camera_ptz = ptz
        self.camera_media_profile = media_profile
        self.camera_media = media

        return self.camera_ptz, self.camera_media_profile

    def set_preset(self, preset_name: str):
        """
        The command saves the current device position parameters.
        Args:
            preset_name: Name for preset.
        Returns:
            Return onvif's response.
        """
        presets = CameraControl.get_preset_complete(self)
        request = self.camera_ptz.create_type('SetPreset')
        request.ProfileToken = self.camera_media_profile.token
        request.PresetName = preset_name
        logging.info('camera_command( set_preset%s) )', preset_name)

        for i, _ in enumerate(presets):
            if str(presets[i].Name) == preset_name:
                logging.warning(
                    'Preset (\'%s\') not created. Preset already exists!', preset_name)
                return None

        ptz_set_preset = self.camera_ptz.SetPreset(request)
        logging.info('Preset (\'%s\') created!', preset_name)
        return ptz_set_preset

    def get_preset(self):
        """
        Operation to request all PTZ presets.
        Returns:
            Returns a list of tuples with the presets.
        """
        ptz_get_presets = CameraControl.get_preset_complete(self)
        logging.info('camera_command( get_preset() )')

        presets = []
        for i, _ in enumerate(ptz_get_presets):
            presets.append((i, ptz_get_presets[i].Name))
        return presets
    
    def get_preset_complete(self):
        """
        Operation to request all PTZ presets.
        Returns:
            Returns the complete presets Onvif.
        """
        request = self.camera_ptz.create_type('GetPresets')
        request.ProfileToken = self.camera_media_profile.token
        ptz_get_presets = self.camera_ptz.GetPresets(request)
        return ptz_get_presets
    def remove_preset(self, preset_name: str):
        """
        Operation to remove a PTZ preset.
        Args:
            preset_name: Preset name.
        Returns:
            Return onvif's response.
        """
        presets = CameraControl.get_preset_complete(self)
        request = self.camera_ptz.create_type('RemovePreset')
        request.ProfileToken = self.camera_media_profile.token
        logging.info('camera_command( remove_preset(%s) )', preset_name)
        for i, _ in enumerate(presets):
            if str(presets[i].Name) == preset_name:
                request.PresetToken = presets[i].token
                ptz_remove_preset = self.camera_ptz.RemovePreset(request)
                logging.info('Preset (\'%s\') removed!', preset_name)
                return ptz_remove_preset
        logging.warning("Preset (\'%s\') not found!", preset_name)
        return None

    def go_to_preset(self, preset_position: str):
        """
        Operation to go to a saved preset position.
        Args:
            preset_position: preset name.
        Returns:
            Return onvif's response.
        """
        presets = CameraControl.get_preset_complete(self)
        request = self.camera_ptz.create_type('GotoPreset')
        request.ProfileToken = self.camera_media_profile.token
        logging.info('camera_command( go_to_preset(%s) )', preset_position)
        for i, _ in enumerate(presets):
            str1 = str(presets[i].Name)
            if str1 == preset_position:
                request.PresetToken = presets[i].token
                resp = self.camera_ptz.GotoPreset(request)
                logging.info("Goes to (\'%s\')", preset_position)
                return resp
        logging.warning("Preset (\'%s\') not found!", preset_position)
        return None

if __name__ == "__main__":
    ptz_cam_218 = CameraControl("192.168.1.218", 218, "admin", "peal2024")
    ptz_cam_218.camera_start()

    print(ptz_cam_218.get_preset())

    for i in range(5):
        ptz_cam_218.go_to_preset("Preset 1")
        time.sleep(2)

        ptz_cam_218.go_to_preset("Preset 2")
        time.sleep(2)
```
# Result
* video at media folder(media/KakaoTalk_20250922_224018500.mp4)

# Multi-camera control

`goto_preset_all_ipcamera.py` drives three cameras
(`192.168.1.218 / .219 / .220`, all admin / peal2024) sequentially to
the preset named `Preset 1`, reusing `ONVIFController` from
`onvif_controller.py`. Per-camera errors are isolated so one offline
camera does not abort the rest.

```bash
python goto_preset_all_ipcamera.py
```

# Virtual webcam (v4l2loopback)

These helpers expose the HikVision RTSP streams as standard
`/dev/videoN` devices so any V4L2 consumer (OpenCV, Zoom, OBS, ...)
can use the camera as if it were a regular webcam. They depend on
the `v4l2loopback` kernel module and `ffmpeg`, both installed on
first run.

| Script                       | Purpose                                                           |
|------------------------------|-------------------------------------------------------------------|
| `rtsp_to_v4l2_.sh`           | Single camera (`.218`) → `/dev/video10`                            |
| `rtsp_to_v4l2_multi.sh`      | Three cameras → `/dev/video18`, `/dev/video19`, `/dev/video20`     |
| `rtsp_to_v4l2_teardown.sh`   | Stop ffmpeg writers and unload `v4l2loopback`                      |

Camera ↔ device mapping for the multi variant mirrors the last
octet of the IP, so the device number always identifies the source:

| Camera IP        | Device         | card_label        |
|------------------|----------------|-------------------|
| 192.168.1.218    | `/dev/video18` | `HikVision .218`  |
| 192.168.1.219    | `/dev/video19` | `HikVision .219`  |
| 192.168.1.220    | `/dev/video20` | `HikVision .220`  |

## Usage

```bash
# Single camera
./rtsp_to_v4l2_.sh                  # setup module + start ffmpeg pipe
./rtsp_to_v4l2_.sh setup            # install deps + load module only
./rtsp_to_v4l2_.sh stream           # stream only (foreground)

# Three cameras at once (ffmpeg runs in background)
./rtsp_to_v4l2_multi.sh             # setup + spawn 3 ffmpeg writers
# Per-camera ffmpeg logs land in /tmp/rtsp_to_v4l2/cam_<NR>.log

# Release the devices
./rtsp_to_v4l2_teardown.sh          # kill ffmpeg + modprobe -r
./rtsp_to_v4l2_teardown.sh kill-only # only stop ffmpeg, keep module
```

## Verification

```bash
ls /dev/video18 /dev/video19 /dev/video20
v4l2-ctl --list-devices
ffplay /dev/video18                  # or any other mapped device
```

```python
import cv2
cap = cv2.VideoCapture("/dev/video18")
ok, _ = cap.read()
print(ok)                            # True if the pipe is live
```

## Notes

- Requires a privileged container (or host) so that
  `modprobe v4l2loopback` succeeds.
- The scripts force `-rtsp_transport tcp` because the HikVision
  RTSP server drops UDP packets aggressively under load.
- v4l2loopback only accepts uncompressed frames, so ffmpeg
  decodes to `rawvideo` / `yuv420p` before writing to the device.
- Existing `/dev/videoN` targets are left in place if they are
  already present, to avoid disrupting a consumer that is mid-session.