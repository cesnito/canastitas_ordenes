import 'package:vibration/vibration.dart';

class Haptic {
  static final Iterable<Duration> pauses = [
    const Duration(milliseconds: 30),
  ];

  static void sense() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 200); // duración en ms
    }
  }
}