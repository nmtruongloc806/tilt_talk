import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  static const double _threshold = 15.0;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  Function(bool)? onGestureDetected;

  void startListening() {
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      // Phát hiện lắc lên (reject call)
      if (event.y < -_threshold) {
        onGestureDetected?.call(false);
      }
      // Phát hiện lắc xuống (accept call)
      else if (event.y > _threshold) {
        onGestureDetected?.call(true);
      }
    });
  }

  void stopListening() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }

  void dispose() {
    stopListening();
  }
} 