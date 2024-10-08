# MyTimer

MyTimer is a flexible and customizable timer widget for Flutter. It allows developers to easily
integrate timer functionality into their apps, supporting both incrementing and decrementing timers.
With control over start/stop functionality, tick intervals, and callbacks for each tick and
completion, MyTimer is an ideal solution for timed events, countdowns, and more.

## Features

- Increment or decrement timer functionality.
- Customizable tick interval (e.g., every second, minute, etc.).
- Start, stop, and reset timer programmatically with MyTimerController.
- Callback function for each tick.
- Callback function when the timer completes.
- Pass a custom child widget to display in place of the default time.
- Customize text style for the timer's display.
- Ideal for countdown timers, time trackers, or event timers.

## Installation

command:

```yaml
 $ flutter pub add my_timer
```
pubspec.yaml:

```yaml
dependencies:
my_timer: ^1.0.0
``` 

## Usage

```dart
import 'package:my_timer/my_timer.dart';
import 'my_timer_controller/my_timer_controller.dart';

MyTimer(
  isIncrementing: true,
  startTimerInSeconds: 0,
  endTimerInSeconds: 60,
  tickInSecond: const Duration(seconds: 1),
  controller: _timerController,
  style: const TextStyle(color: Colors.red, fontSize: 24),
  child: const Text('Custom Timer'),
)

ElevatedButton(
  onPressed: () {
    _timerController.start();
  },
  child: const Text('Start Timer'),
),

ElevatedButton(
  onPressed: () {
    _timerController.stop();
  },
  child: const Text('Stop Timer'),
)
```

## Customizing the Timer

You can customize `MyTimer` to suit your specific needs by adjusting various properties:

1. **tickInSecond**: Define the tick interval. The default is 1 second.
2. **isIncrementing**: Specify whether the timer should count up (`true`) or count down (`false`).
3. **startTimerInSeconds**: Set the starting time in seconds.
4. **endTimerInSeconds**: Define when the timer should end.
5. **controller**: Use a `MyTimerController` to start and stop the timer programmatically.
6. **child**: Pass a custom widget to display instead of the default timer.
7. **style**: Customize the text style for the time display.


## Example: Decrementing Timer

Here's an example of using the decrementing timer:

```dart
MyTimer(
  isIncrementing: false,
  startTimerInSeconds: 120,
  endTimerInSeconds: 0,
  tickInSecond: const Duration(seconds: 1),
  controller: _timerController,
  style: const TextStyle(color: Colors.green, fontSize: 24),
)
```

# MyTimerController

The `MyTimerController` allows you to control the timer programmatically. You can start, stop, or retrieve the current time with the following methods:

- **`start()`**: Start the timer.
- **`stop()`**: Stop the timer.
- **`getTimer()`**: Get the current remaining time as a `Duration`.

## Example: Using MyTimerController

Here's an example of using the `MyTimerController`:

```dart
final MyTimerController _timerController = MyTimerController();

ElevatedButton(
  onPressed: () {
    _timerController.start();
  },
  child: const Text('Start Timer'),
),

ElevatedButton(
  onPressed: () {
    _timerController.stop();
  },
  child: const Text('Stop Timer'),
),
```

# Additional Information

For more information, feel free to check out the source code, submit issues, or contribute to the project on GitHub. We welcome contributions and feedback from the community.

- **GitHub Repository**: [https://github.com/Priyanshu-techind/my_timer](https://github.com/Priyanshu-techind/my_timer)
- **Issue Tracker**: [https://github.com/Priyanshu-techind/my_timer/issues](https://github.com/Priyanshu-techind/my_timer/issues)
