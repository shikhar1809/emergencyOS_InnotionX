import 'package:flutter/material.dart';

void main() {
  runApp(const EmergencyOsApp());
}

class EmergencyOsApp extends StatelessWidget {
  const EmergencyOsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Emergency OS',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _reportsSent = 0;
  bool _sirenOn = false;

  void _sendReport() {
    setState(() {
      // Intentional beginner bug: this should increase by 1.
      _reportsSent = _reportsSent - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Reports sent: $_reportsSent'),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Siren'),
                      subtitle: const Text('Tap to turn on/off'),
                      value: _sirenOn,
                      onChanged: (value) {
                        setState(() {
                          // Intentional beginner bug: this should use "value".
                          _sirenOn = false;
                        });
                      },
                    ),
                    Text(
                      // Intentional beginner bug: labels are reversed.
                      _sirenOn ? 'Siren is OFF' : 'Siren is ON',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendReport,
              child: const Text('Send Report'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Very basic student-style UI.\nTwo small debug pratice bugs are intentionally added.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
