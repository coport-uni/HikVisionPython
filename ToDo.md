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
- [ ] Commit and push
