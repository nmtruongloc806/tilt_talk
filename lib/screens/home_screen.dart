import 'package:flutter/material.dart';
import 'package:phone_state/phone_state.dart';
import '../services/sensor_service.dart';
import '../services/call_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SensorService _sensorService = SensorService();
  final CallService _callService = CallService();
  String _callState = 'Không có cuộc gọi';
  bool _isCallActive = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _callService.initialize();

    _callService.onCallStateChanged = (PhoneState state) {
      setState(() {
        _isCallActive = state.status == PhoneStateStatus.CALL_INCOMING;
        _callState = state.status == PhoneStateStatus.CALL_INCOMING
            ? 'Có cuộc gọi đến'
            : 'Không có cuộc gọi';
      });

      if (state.status == PhoneStateStatus.CALL_INCOMING) {
        _sensorService.startListening();
      } else {
        _sensorService.stopListening();
      }
    };

    _sensorService.onGestureDetected = (bool accept) {
      if (_isCallActive) {
        _callService.handleIncomingCall(accept);
        setState(() {
          _callState = accept ? 'Chấp nhận cuộc gọi' : 'Từ chối cuộc gọi';
          _isCallActive = false;
        });
      }
    };
  }

  @override
  void dispose() {
    _sensorService.dispose();
    _callService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tilt Talk'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.phone_in_talk,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            Text(
              _callState,
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Lắc điện thoại xuống để chấp nhận cuộc gọi\nLắc điện thoại lên để từ chối cuộc gọi',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 