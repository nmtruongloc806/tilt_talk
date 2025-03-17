import 'dart:async';
import 'package:phone_state/phone_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class CallService {
  Function(PhoneState)? onCallStateChanged;
  StreamSubscription<PhoneState>? _phoneStateSubscription;

  Future<void> initialize() async {
    await Permission.phone.request();
    
    PhoneState.phoneStateStream.listen((PhoneState state) {
      onCallStateChanged?.call(state);
    });
  }

  Future<void> handleIncomingCall(bool accept) async {
    if (accept) {
      // Mô phỏng việc chấp nhận cuộc gọi
      // Lưu ý: API thực tế có thể khác nhau trên iOS và Android
      print('Accepting call');
    } else {
      // Mô phỏng việc từ chối cuộc gọi
      print('Rejecting call');
    }
  }

  void dispose() {
    _phoneStateSubscription?.cancel();
  }
} 