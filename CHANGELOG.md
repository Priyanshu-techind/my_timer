## [2.0.0] - 2026-05-31

### Breaking changes
- **Removed the `provider` dependency.** State is now managed internally with
  `ValueNotifier` and rebuilt via `ValueListenableBuilder`. If you were
  reaching into the package's internal `MyTimerProvider`, that type no longer
  exists — use [`MyTimerController`](lib/controller/my_timer_controller.dart)
  instead.
- **`tickInSecond` is now purely a UI refresh cadence.** In 1.x it was
  incorrectly used as a "step size," so passing `Duration(milliseconds: 500)`
  made the timer count two seconds per real second. The new implementation
  tracks real wall-clock time via `Stopwatch`, so the displayed value is
  always accurate regardless of tick interval. `tickInSecond` is now
  deprecated in favor of `tickInterval`.
- **Default text format changed from `HH:MM:SS` to `auto`** (which picks
  `mm:ss` under an hour, `hh:mm:ss` under a day, `dd:hh:mm:ss` beyond). Pass
  `format: TimerFormat.hoursMinutesSeconds` to keep the old behavior.
- **The `builder` parameter now uses positional `Duration` arguments**:
  `(BuildContext, Duration remaining, Duration elapsed) => Widget`. The
  1.x-style named `int remainingTime` builder is still available under the
  new name `legacyBuilder`.

### Added
- `MyTimerController.pause()`, `resume()`, `reset()`, `seek()`, `add()`,
  `subtract()` — the things 1.x was missing.
- `MyTimerController.isRunning`, `isPaused`, `isCompleted`, `isAttached`,
  `elapsed`, `remaining` getters.
- `autoStart: bool` parameter — set `false` to keep the timer paused until
  you call `controller.start()`.
- `format: TimerFormat` and `formatter: String Function(Duration)` for
  built-in and custom formatting (`auto`, `seconds`, `minutesSeconds`,
  `hoursMinutesSeconds`, `minutesSecondsMillis`, `daysHoursMinutesSeconds`).
- `direction: TimerDirection` and `duration: Duration` — modern
  `Duration`-typed API. The 1.x `isIncrementing` / `startTimerInSeconds` /
  `endTimerInSeconds` / `tickInSecond` parameters are kept as `@Deprecated`
  aliases.
- `onComplete` and `onTick` are now available directly on the widget as
  well as on the controller.
- `resyncOnResume: bool` — on `AppLifecycleState.resumed`, the widget asks
  the engine to recompute elapsed time, so countdowns stay correct after
  the OS throttles the periodic ticker.
- Drift-free ticking via `Stopwatch` — long-running timers no longer drift.

### Fixed
- Calling `controller.start()` before the widget mounted threw a
  `LateInitializationError`. Method calls on an unattached controller are
  now safe no-ops.
- `stop()` followed by `start()` reset elapsed time inconsistently. The
  new `pause()` / `resume()` pair preserves state cleanly.
- The 1.0.1 widget tests asserted `'00:00'` while the widget actually
  rendered `'00:00:00'`. Tests now pass.

## [1.0.1] - 2025-03-20
### Added
- **Builder Support:** Added a builder to access `remainingTimeInSeconds` and `BuildContext`, allowing more flexible UI updates.
- **Provider Integration:** Refactored the `MyTimer` widget to use `Provider` for improved state management and access.
- **New Callbacks:** Enhanced the `MyTimerController` with additional callbacks for better timer control.
- **Code Refactoring:** Improved code structure and readability.

### Fixed
- Fixed a bug where multiple timers could start without stopping the previous one.
- Optimized timer performance by reducing unnecessary `setState` calls.

## [1.0.0] - Initial Release
- Added `MyTimer` widget that allows incrementing and decrementing time.
- Supports custom tick intervals via the `tickInSecond` property.
- Added start, stop, and complete callbacks through the `MyTimerController`.
- Allows customizable child widget or default time display.
- Accepts styling options for the time display text.
- Supports both incrementing and decrementing modes with start and end time.
