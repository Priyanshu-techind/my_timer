## [1.0.0] - Initial Release
- Added `MyTimer` widget that allows incrementing and decrementing time.
- Supports custom tick intervals via the `tickInSecond` property.
- Added start, stop, and complete callbacks through the `MyTimerController`.
- Allows customizable child widget or default time display.
- Accepts styling options for the time display text.
- Supports both incrementing and decrementing modes with start and end time.

## [1.0.1] - 2025-03-20
### Added
- **Builder Support:** Added a builder to access `remainingTimeInSeconds` and `BuildContext`, allowing more flexible UI updates.
- **Provider Integration:** Refactored the `MyTimer` widget to use `Provider` for improved state management and access.
- **New Callbacks:** Enhanced the `MyTimerController` with additional callbacks for better timer control.
- **Code Refactoring:** Improved code structure and readability.

### Fixed
- Fixed a bug where multiple timers could start without stopping the previous one.
- Optimized timer performance by reducing unnecessary `setState` calls.
