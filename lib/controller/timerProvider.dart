import 'package:flutter/material.dart';
import 'dart:async';

class TimerProvider with ChangeNotifier {
  Timer? _timer;
  Duration _duration = Duration(seconds: 300); // 5 Menit
  bool _isTimerActive = false;

  Duration get duration => _duration;
  bool get isTimerActive => _isTimerActive;

  void startTimer() {
    _isTimerActive = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_duration.inSeconds > 0) {
        _duration = Duration(seconds: _duration.inSeconds - 1);
        notifyListeners();
      } else {
        _timer?.cancel();
        _isTimerActive = false;
        notifyListeners();
      }
    });
  }

  void resetTimer() {
    _timer?.cancel();
    _duration = Duration(seconds: 300);
    _isTimerActive = false;
    notifyListeners();
  }
}
