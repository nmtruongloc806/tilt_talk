import 'dart:async';
import 'package:phone_state/phone_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../screens/incoming_call_screen.dart';

class CallService {
  static const platform = MethodChannel('com.example.tilt_talk/call_background');
  Function(PhoneState)? onCallStateChanged;
  StreamSubscription<PhoneState>? _phoneStateSubscription;
  bool _isBackgroundServiceRunning = false;
  BuildContext? _context;
  OverlayEntry? _overlayEntry;

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> initialize() async {
    // Request necessary permissions
    await Permission.phone.request();
    await Permission.systemAlertWindow.request();
    
    // Start background service
    await _startBackgroundService();
    
    // Listen for phone state changes
    _phoneStateSubscription = PhoneState.stream.listen((PhoneState state) {
      onCallStateChanged?.call(state);
      if (state.status == PhoneStateStatus.CALL_INCOMING) {
        _showIncomingCallScreen(state.number);
      } else if (state.status == PhoneStateStatus.CALL_ENDED) {
        _hideIncomingCallScreen();
      }
    });

    // Listen for background service callbacks
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onIncomingCall':
          final phoneNumber = call.arguments['phoneNumber'] as String?;
          final state = PhoneState.nothing();
          state.status = PhoneStateStatus.CALL_INCOMING;
          state.number = phoneNumber;
          onCallStateChanged?.call(state);
          _showIncomingCallScreen(phoneNumber);
          break;
        case 'onCallAnswered':
          final state = PhoneState.nothing();
          state.status = PhoneStateStatus.CALL_STARTED;
          onCallStateChanged?.call(state);
          _hideIncomingCallScreen();
          break;
        case 'onCallEnded':
          final state = PhoneState.nothing();
          state.status = PhoneStateStatus.CALL_ENDED;
          onCallStateChanged?.call(state);
          _hideIncomingCallScreen();
          break;
        default:
          throw PlatformException(
            code: 'Unimplemented',
            message: 'Method ${call.method} not implemented',
          );
      }
    });
  }

  void _showIncomingCallScreen(String? phoneNumber) {
    if (_context == null) return;

    _hideIncomingCallScreen();

    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: IncomingCallScreen(
          phoneNumber: phoneNumber,
          onCallAction: handleIncomingCall,
        ),
      ),
    );

    Overlay.of(_context!).insert(_overlayEntry!);
  }

  void _hideIncomingCallScreen() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _startBackgroundService() async {
    try {
      final bool result = await platform.invokeMethod('startBackgroundService');
      _isBackgroundServiceRunning = result;
    } on PlatformException catch (e) {
      print('Failed to start background service: ${e.message}');
    }
  }

  Future<void> handleIncomingCall(bool accept) async {
    if (accept) {
      // Launch phone dialer
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: '1234567890', // Replace with actual phone number
      );
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    } else {
      // Handle call rejection
      print('Rejecting call');
    }
    _hideIncomingCallScreen();
  }

  void dispose() {
    _phoneStateSubscription?.cancel();
    platform.setMethodCallHandler(null);
    _hideIncomingCallScreen();
  }
}
