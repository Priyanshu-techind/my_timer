/// Built-in formats for rendering a [Duration] as a timer string.
enum TimerFormat {
  /// Picks the smallest sensible format that still fits the value:
  /// `mm:ss` under an hour, `hh:mm:ss` under a day, `dd:hh:mm:ss` beyond.
  auto,

  /// Total seconds as a plain integer, e.g. `93`.
  seconds,

  /// `mm:ss`, e.g. `01:33`.
  minutesSeconds,

  /// `hh:mm:ss`, e.g. `00:01:33`.
  hoursMinutesSeconds,

  /// `mm:ss.mmm`, e.g. `01:33.250`.
  minutesSecondsMillis,

  /// `dd:hh:mm:ss`, e.g. `00:00:01:33`.
  daysHoursMinutesSeconds,
}

/// Formats [d] according to [format].
String formatDuration(Duration d, TimerFormat format) {
  final negative = d.isNegative;
  if (negative) d = -d;

  final totalMs = d.inMilliseconds;
  final days = totalMs ~/ Duration.millisecondsPerDay;
  final hours = (totalMs % Duration.millisecondsPerDay) ~/ Duration.millisecondsPerHour;
  final minutes = (totalMs % Duration.millisecondsPerHour) ~/ Duration.millisecondsPerMinute;
  final seconds = (totalMs % Duration.millisecondsPerMinute) ~/ Duration.millisecondsPerSecond;
  final millis = totalMs % Duration.millisecondsPerSecond;

  String two(int n) => n.toString().padLeft(2, '0');
  String three(int n) => n.toString().padLeft(3, '0');

  String result;
  switch (format) {
    case TimerFormat.seconds:
      result = '${d.inSeconds}';
      break;
    case TimerFormat.minutesSeconds:
      result = '${two(d.inMinutes)}:${two(seconds)}';
      break;
    case TimerFormat.hoursMinutesSeconds:
      result = '${two(d.inHours)}:${two(minutes)}:${two(seconds)}';
      break;
    case TimerFormat.minutesSecondsMillis:
      result = '${two(d.inMinutes)}:${two(seconds)}.${three(millis)}';
      break;
    case TimerFormat.daysHoursMinutesSeconds:
      result = '${two(days)}:${two(hours)}:${two(minutes)}:${two(seconds)}';
      break;
    case TimerFormat.auto:
      if (days > 0) {
        result = '${two(days)}:${two(hours)}:${two(minutes)}:${two(seconds)}';
      } else if (d.inHours > 0) {
        result = '${two(d.inHours)}:${two(minutes)}:${two(seconds)}';
      } else {
        result = '${two(d.inMinutes)}:${two(seconds)}';
      }
      break;
  }

  return negative ? '-$result' : result;
}
