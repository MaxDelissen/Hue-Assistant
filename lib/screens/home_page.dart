import 'package:flutter/material.dart';
import 'package:hue_assistant/screens/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _startTalkingOnLaunch = false;

  final String _nextActionTitle = "Turn on bathroom lights";
  final String _nextActionSubtitle = "Turning on 2 lights in the bathroom";
  final List<Widget> _leadingIconOptions = [
    const Icon(Icons.lightbulb),
    const Icon(Icons.color_lens),
    const Icon(Icons.brightness_6),
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Loads the saved preference for "Start Talking on Launch".
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _startTalkingOnLaunch = prefs.getBool('startTalkingOnLaunch') ?? false;
    });

    // Simulate auto-starting the talking functionality if enabled.
    if (_startTalkingOnLaunch) {
      debugPrint("Start Talking activated on launch!");
    }
  }

  Future<void> _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
    // After navigating back, reload the settings to apply any changes
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: ListTile(
                title: Text(_nextActionTitle),
                subtitle: Text(_nextActionSubtitle),
                leading: const Icon(Icons.lightbulb),
                trailing: IconButton(
                  icon: const Icon(Icons.play_circle_fill_rounded),
                  onPressed: _navigateToSettings,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                debugPrint("Start Talking pressed!");
                // Placeholder for microphone functionality
              },
              icon: const Icon(Icons.mic),
              label: const Text('Start Talking'),
            ),
          ],
        ),
      ),
    );
  }
}
