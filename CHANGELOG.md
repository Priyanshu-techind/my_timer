# Changelog

All notable changes to this project are documented in this file. The format
is based on [Keep a Changelog](https://keepachangelog.com/) and this project
adheres to [Semantic Versioning](https://semver.org/).

---

## [2.0.0] - 2026-05-31

> **TL;DR** — `my_timer` is now drift-free, dependency-free, and backgrounding-aware.
> The controller gains `pause` / `resume` / `reset` / `seek` / `add` / `subtract`
> plus state-inspection getters. The widget gains a modern `Duration`-typed
> API, format presets, and a custom formatter. Your 1.x code keeps compiling
> via deprecated aliases.

### Highlights

| | |
|---|---|
| Drift-free engine | Elapsed time is reconciled against the wall clock each tick — long-running timers stay accurate. |
| Background resync | `WidgetsBindingObserver` recomputes elapsed time on `AppLifecycleState.resumed`. |
| Zero dependencies | `provider` is gone. State runs on `ValueNotifier` + `ValueListenableBuilder`. |
| Real controller | `pause`, `resume`, `reset`, `seek`, `add`, `subtract` + `isRunning` / `isPaused` / `isCompleted` / `elapsed` / `remaining` getters. |
| Format presets | `auto`, `seconds`, `minutesSeconds`, `hoursMinutesSeconds`, `minutesSecondsMillis`, `daysHoursMinutesSeconds`. |

### Breaking changes

> Existing 1.x code keeps compiling thanks to `@Deprecated` aliases. The
> only signature break is the `builder` parameter — rename your old builder
> to `legacyBuilder` and you're done. See the migration table in
> [README.md](README.md#migrating-from-1x).

- **`provider` removed.** State is now managed internally with `ValueNotifier`
  and rebuilt via `ValueListenableBuilder`. If any code was reaching into
  the package's internal `MyTimerProvider`, that type no longer exists —
  use `MyTimerController` instead.
- **`tickInSecond` is now purely a UI refresh cadence.** In 1.x it was
  incorrectly used as a "step size," so passing `Duration(milliseconds: 500)`
  made the timer count two seconds per real second. The new implementation
  tracks real time, so the displayed value is always accurate regardless
  of tick interval. `tickInSecond` is deprecated in favor of `tickInterval`.
- **Default text format changed from `HH:MM:SS` to `auto`** (picks `mm:ss`
  under an hour, `hh:mm:ss` under a day, `dd:hh:mm:ss` beyond). Pass
  `format: TimerFormat.hoursMinutesSeconds` to keep the old behavior.
- **The `builder` parameter now uses positional `Duration` arguments**:
  `(BuildContext, Duration remaining, Duration elapsed) => Widget`. The
  1.x-style named `int remainingTime` builder is available under the new
  name `legacyBuilder`.

### Added — controller

- `pause()` — stops the ticker while preserving elapsed time.
- `resume()` — alias for `start()`; reads more naturally after `pause()`.
- `reset()` — zeroes elapsed time without starting the timer.
- `seek(Duration)` — jumps to a position, preserving running state.
- `add(Duration)` / `subtract(Duration)` — shift elapsed time by a delta.
- `isRunning`, `isPaused`, `isCompleted`, `isAttached` — state getters.
- `elapsed`, `remaining` — read current values without a callback.

### Added — widget

- `direction: TimerDirection` (`countUp` / `countDown`) — modern, type-safe
  replacement for `isIncrementing`.
- `duration: Duration` — modern `Duration`-typed total. Old
  `startTimerInSeconds` / `endTimerInSeconds` ints remain as deprecated aliases.
- `tickInterval: Duration` — modern replacement for `tickInSecond`.
- `autoStart: bool` — set `false` to keep the timer paused until
  `controller.start()`.
- `onTick` / `onComplete` — now available directly on the widget in addition
  to the controller.
- `resyncOnResume: bool` — opt-in/opt-out of the lifecycle resync hook.

### Added — formatting

- `TimerFormat` enum with six presets:
  `auto`, `seconds`, `minutesSeconds`, `hoursMinutesSeconds`,
  `minutesSecondsMillis`, `daysHoursMinutesSeconds`.
- `formatter: String Function(Duration)` — custom formatter escape hatch.
- `formatDuration(Duration, TimerFormat)` — exposed as a public helper for
  use outside the widget.

### Added — engine

- New internal `MyTimerEngine` (drift-free, tick-driven + wall-clock
  reconciled). Single source of truth for any UI built on the controller.
- `MyTimerEngine.elapsed` is a `ValueNotifier<Duration>` — power-users can
  subscribe directly with `ValueListenableBuilder` if they need more
  control than the widget provides.

### Added — packaging & docs

- `repository`, `issue_tracker`, `topics`, and `screenshots` fields added
  to [pubspec.yaml](pubspec.yaml) for better pub.dev visibility.
- Comprehensive dartdoc comments on every public symbol.
- README rewrite with shields.io badges, comparison table, screenshot grid,
  TOC, and migration guide.
- Example app rewritten as a 4-tab demo (countdown, stopwatch, custom
  builder, format gallery).
- [`screenshots/SCREENSHOT_GUIDE.md`](screenshots/SCREENSHOT_GUIDE.md)
  with capture specs for contributors.

### Fixed

- Calling `controller.start()` before the widget mounted threw a
  `LateInitializationError`. Method calls on an unattached controller are
  now safe no-ops.
- `stop()` followed by `start()` reset elapsed time inconsistently. The
  new `pause()` / `resume()` pair preserves state cleanly.
- The 1.0.1 widget tests asserted `'00:00'` while the widget actually
  rendered `'00:00:00'`. Tests now pass — all 20 of them.

### Migration cheatsheet

| 1.x | 2.x |
|---|---|
| `isIncrementing: true` | `direction: TimerDirection.countUp` |
| `isIncrementing: false` | `direction: TimerDirection.countDown` |
| `startTimerInSeconds` / `endTimerInSeconds` | `duration: Duration(...)` |
| `tickInSecond` | `tickInterval` |
| `builder: ({context, remainingTime}) {...}` | `legacyBuilder: ({context, remainingTime}) {...}` |

---

## [1.0.1] - 2025-03-20

### Added
- **Builder support** — access to `remainingTimeInSeconds` and `BuildContext`
  for flexible UI updates.
- **Provider integration** — refactored `MyTimer` to use `Provider` for
  state management.
- **New callbacks** — additional callbacks on `MyTimerController`.
- **Code refactor** — improved structure and readability.

### Fixed
- Multiple timers could start without stopping the previous one.
- Reduced unnecessary `setState` calls.

---

## [1.0.0] - Initial release

- `MyTimer` widget with incrementing and decrementing modes.
- Custom tick interval via `tickInSecond`.
- Start / stop / complete callbacks via `MyTimerController`.
- Custom child widget or default time display.
- Styling options for the time display text.
