import 'dart:ui';

class MyTimerController {
  late Duration Function() getTimer;
  late void Function() stop;
  late void Function() start;
  void Function(Duration)? onTick;
  VoidCallback? onComplete;

  MyTimerController({this.onTick, this.onComplete});
}
