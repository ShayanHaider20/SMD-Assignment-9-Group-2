import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() {
  // Add error handling to the entire app
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const MyApp());
  }, (error, stack) {
    print("Global error caught: $error");
    print(stack);
  });
}

// Don't forget to add this import at the top

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battery Level App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BatteryPage(),
    );
  }
}

class BatteryPage extends StatefulWidget {
  const BatteryPage({Key? key}) : super(key: key);

  @override
  State<BatteryPage> createState() => _BatteryPageState();
}

class _BatteryPageState extends State<BatteryPage> {
  static const platform = MethodChannel('samples.flutter.dev/battery');
  String _batteryLevel = 'Checking battery level...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Delay the platform channel call to ensure proper initialization
    Future.delayed(Duration(seconds: 1), () {
      _getBatteryLevel();
    });
  }

  Future<void> _getBatteryLevel() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    String batteryLevel;
    try {
      print("Attempting to get battery level...");
      final int result = await platform.invokeMethod('getBatteryLevel');
      print("Battery level result: $result");
      batteryLevel = 'Battery level: $result%';
    } on PlatformException catch (e) {
      print("Platform Exception: ${e.message}");
      batteryLevel = "Error: ${e.message}";
    } catch (e) {
      print("Unknown error: $e");
      batteryLevel = "Error: Couldn't access battery info";
    }

    // Ensure the widget is still mounted before updating state
    if (mounted) {
      setState(() {
        _batteryLevel = batteryLevel;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Battery Level'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Text(
                _batteryLevel,
                style: const TextStyle(fontSize: 24),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getBatteryLevel,
              child: const Text('Refresh Battery Level'),
            ),
          ],
        ),
      ),
    );
  }
}
