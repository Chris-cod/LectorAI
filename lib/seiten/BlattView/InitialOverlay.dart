import 'package:flutter/material.dart';

class InitialOverlay extends StatelessWidget {
  final VoidCallback onEintragenPressed;
  final VoidCallback onAuswaehlenPressed;

  InitialOverlay({
    required this.onEintragenPressed,
    required this.onAuswaehlenPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Color(0xff3d7c88),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bitte wählen Sie eine Option:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAuswaehlenPressed,
              child: Text('Auswählen'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: onEintragenPressed,
              child: Text('Eintragen'),
            ),
          ],
        ),
      ),
    );
  }
}
