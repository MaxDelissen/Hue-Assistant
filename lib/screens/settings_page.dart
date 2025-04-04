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
  bool isOn = false;
  Light? _light;
  Light? _colorLight;

  @override
  void initState() {
    super.initState();
    _loadLightState();
  }

  /// Loads the saved setting value.
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _startTalkingOnLaunch = prefs.getBool('startTalkingOnLaunch') ?? false;
    });
  }

  /// Loads the initial state of the light.
  Future<void> _loadLightState() async {
    HueActions actions = await HueActions.create();
    List<Light> lights = await actions.getLights();
    if (lights.isNotEmpty) {
      setState(() {
        _light = lights.first;
        _colorLight = lights[1];
        isOn = _light!.on.isOn;
      });
    }
  }

  /// Saves the setting when toggled.
  Future<void> _saveSettings(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('startTalkingOnLaunch', value);
    setState(() {
      _startTalkingOnLaunch = value;
    });
  }

  /// Toggles the light state.
  Future<void> _toggleLight(bool value) async {
    if (_light != null) {
      HueActions actions = await HueActions.create();
      await actions.setLightState(_light!, value);
      setState(() {
        isOn = value;
      });
    }
  }

  bool lightColor = false;
  Future<void> _toggleLightColor() async {
    if (_light != null) {
      if (lightColor) {
        await _resetLightColor();
      } else {
        await _redLightColor();
      }
    }
  }

  Future<void> _redLightColor() async {
    if (_light != null) {
      HueActions actions = await HueActions.create();
      Color color = Colors.red; // Example color
      await actions.setLightColor(_colorLight!, color);
    }
  }

  Future<void> _resetLightColor() async {
    if (_light != null) {
      HueActions actions = await HueActions.create();
      Color color = Colors.white; // Example color
      await actions.setLightColor(_colorLight!, color);
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
            value: isOn,
            onChanged: (value) {
              _toggleLight(value);
            },
          ),
          SwitchListTile(
            title: const Text('Change color of first found light (debug)'),
            value: lightColor,
            onChanged: (value) {
              setState(() {
                lightColor = !lightColor;
              });
              _toggleLightColor();
            },
          ),
        ],
      ),
    );
  }
}