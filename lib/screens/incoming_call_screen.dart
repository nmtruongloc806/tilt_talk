import 'package:flutter/material.dart';
import 'package:phone_state/phone_state.dart';

class IncomingCallScreen extends StatelessWidget {
  final String? phoneNumber;
  final Function(bool) onCallAction;

  const IncomingCallScreen({
    super.key,
    this.phoneNumber,
    required this.onCallAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.phone_in_talk,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              phoneNumber ?? 'Unknown Caller',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.call_end,
                  color: Colors.red,
                  onTap: () => onCallAction(false),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.call,
                  color: Colors.green,
                  onTap: () => onCallAction(true),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Lắc điện thoại xuống để chấp nhận cuộc gọi\nLắc điện thoại lên để từ chối cuộc gọi',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
