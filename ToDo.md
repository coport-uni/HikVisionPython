# ToDo

Cumulative command history for Claude's actions. New tasks are appended
below, never overwritten (see CLAUDE.md Section 3).

---

## 2026-04-15 — Move all 3 HikVision cameras to "Preset 1"

Goal: add a thin script that sequentially drives three PTZ cameras to
the preset named "Preset 1", reusing `ONVIFController` from
`onvif_controller.py`.

Cameras:

| # | IP            | Port | User  | Password |
|---|---------------|------|-------|----------|
| 1 | 192.168.1.218 | 218  | admin | peal2024 |
| 2 | 192.168.1.219 | 219  | admin | peal2024 |
| 3 | 192.168.1.220 | 220  | admin | peal2024 |

- [x] Create GitHub issue via `gh issue create`
      (https://github.com/coport-uni/HikVisionPython/issues/1)
- [x] Add `goto_preset_all.py` (sequential for-loop, per-camera
      exception isolation, Google-style docstring, 80-col)
- [x] `ruff check goto_preset_all.py` passes
- [x] `ruff format --check goto_preset_all.py` passes
- [x] Commit and push

---

## 2026-04-15 — Expose RTSP stream as /dev/video10 (v4l2loopback)

Goal: HikVision RTSP 스트림
(`rtsp://admin:peal2024@192.168.1.218:554/ISAPI/streaming/channels/02`)을
v4l2loopback + ffmpeg로 `/dev/video10` 가상 카메라로 노출시켜, 다른
프로그램(OpenCV, Zoom, OBS 등)에서 일반 V4L2 디바이스처럼 사용하게 함.

Reference: `/root/.claude/plans/reflective-kindling-diffie.md`

- [x] Create GitHub issue via `gh issue create`
      (https://github.com/coport-uni/HikVisionPython/issues/2)
- [x] Add `rtsp_to_v4l2.sh` (modprobe v4l2loopback + ffmpeg pipe)
      - hardcoded IP/credentials는 기존 스크립트 패턴 유지
      - `-rtsp_transport tcp`, `-pix_fmt yuv420p`, `video_nr=10`,
        `exclusive_caps=1`
- [x] `chmod +x rtsp_to_v4l2.sh`
- [x] Verify: `ls /dev/video10` 및 `ffplay /dev/video10`
      (사용자가 호스트에서 직접 실행)
- [x] Commit and push

---

## 2026-04-15 — MIT convention 검증 + README 업데이트

Goal: 이번 세션에서 추가/수정한 파일들이 CLAUDE.md §1 (MIT convention)
및 §5 (Ruff)에 부합하는지 점검하고, 새로 추가된 v4l2loopback 유틸리티
3종을 README에 반영.

- [x] Create GitHub issue via `gh issue create`
      (https://github.com/coport-uni/HikVisionPython/issues/4)
- [x] Lint 점검: shell scripts — 80-col OK, 탭 없음, 영문 주석 OK
- [x] Lint 점검: `goto_preset_all_ipcamera.py` ruff clean.
      `onvif_controller.py`/`hkvisionapi_example.py` 는 사전부터
      누적된 lint debt가 있음 (이번 세션 미수정, 별도 후속 필요).
- [x] readme.md: v4l2loopback section 추가
- [x] Commit and push

---

## 2026-04-15 — Teardown + 3-camera v4l2loopback mapping

Goal:
1. `rtsp_to_v4l2_.sh` 로 만든 `/dev/videoN` 가상 디바이스를 깨끗하게
   해제하는 teardown 스크립트 추가.
2. 3대 카메라 (`192.168.1.218/.219/.220`)의 RTSP 스트림을 각각
   `/dev/video18`, `/dev/video19`, `/dev/video20` 에 매핑하는
   멀티카메라 변형 스크립트 추가 (기존 `rtsp_to_v4l2_.sh` 패턴 유지).

- [x] Create GitHub issue via `gh issue create`
      (https://github.com/coport-uni/HikVisionPython/issues/3)
- [x] Add `rtsp_to_v4l2_teardown.sh` — kill running ffmpeg writers +
      `modprobe -r v4l2loopback`
- [x] Add `rtsp_to_v4l2_multi.sh` — `devices=3 video_nr=18,19,20`,
      camera_label에 IP 포함, 3개 ffmpeg를 background로 기동
- [x] `chmod +x` 두 파일
- [x] Commit and push
