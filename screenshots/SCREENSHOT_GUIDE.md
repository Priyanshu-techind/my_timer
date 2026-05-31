# Screenshot capture guide

This folder holds the images referenced from the main `README.md` and the
`screenshots:` field of `pubspec.yaml`. You need to capture the following
files using the example app (`example/lib/main.dart` — already wired up
with all four scenarios as tabs).

> This file (`SCREENSHOT_GUIDE.md`) is excluded from the published package
> via `.pubignore`. The PNG/GIF files in this folder **are** published.

## How to capture

1. Run the example app on an Android or iOS device / emulator:
   ```bash
   cd example
   flutter run
   ```
2. For static screenshots:
   - On macOS iOS Simulator: Cmd+S saves a PNG to the Desktop.
   - On Android emulator: click the camera icon in the side toolbar.
   - On a real device: use the device's screenshot shortcut.
3. For the hero GIF:
   - Use [Kap](https://getkap.co/) (macOS), [ScreenToGif](https://www.screentogif.com/) (Windows), or [Peek](https://github.com/phw/peek) (Linux).
   - Record ~10 seconds of the countdown tab — start the timer, hit pause, hit add+10s, hit reset.
   - Export at < 5 MB and < 800px wide for snappy README loads.

## Required files

| File | What it should show | Source tab |
|---|---|---|
| `hero.gif` | Animated 10-second loop demonstrating pause/resume/reset/add | Countdown tab |
| `countdown.png` | The big purple `00:30` countdown text with the 6 control buttons visible underneath | Countdown tab |
| `stopwatch.png` | The monospace `01:23.456` count-up display with Start/Pause/Reset buttons | Stopwatch tab |
| `custom_builder.png` | The `20s` text with linear progress bar mid-way through | Custom builder tab |
| `formats.png` | The scrolling list of all six format presets side-by-side | Formats tab |

## Recommended dimensions

- Static screenshots: **portrait orientation, ~750×1334** (matches a phone aspect ratio).
- Hero GIF: **800×450** landscape, < 5 MB.
- Keep the device frame OFF — pub.dev already crops them. Use the device's "no frame" screenshot mode or crop in any image editor.

## After capturing

1. Drop the PNG/GIF files in this `screenshots/` folder with the exact filenames above.
2. Run `flutter pub publish --dry-run` to confirm pub.dev recognizes them.
3. Optionally compress with [TinyPNG](https://tinypng.com/) — pub.dev caps the package archive at 100 MB but smaller is friendlier.
