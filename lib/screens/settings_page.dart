import 'package:flutter/material.dart';
import 'package:flutter_hue/domain/models/light/light.dart';
import 'package:hue_assistant/utils/hue_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _startTalkingOnLaunch = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Loads the saved setting value.
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _startTalkingOnLaunch = prefs.getBool('startTalkingOnLaunch') ?? false;
    });
  }

  /// Saves the setting when toggled.
  Future<void> _saveSettings(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('startTalkingOnLaunch', value);
    setState(() {
      _startTalkingOnLaunch = value;
    });
  }

  bool isOn = false;

  Future<void> _debugSwitch() async {
    HueActions actions = await HueActions.create();
    List<Light> lights = await actions.getLights();
    if (lights.isNotEmpty) {
      Light light = lights.first;
      await actions.setLightState(light, isOn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Start Talking on Launch'),
            value: _startTalkingOnLaunch,
            onChanged: _saveSettings,
          ),
          SwitchListTile(
            title: const Text('Switch first found light (debug)'),
            value: false, // Debug switch, placeholder for future implementation
            onChanged: (value)  {
              setState(() {
                isOn = value;
              });
              _debugSwitch();
            },
          )
        ],
      ),
    );
  }
}
