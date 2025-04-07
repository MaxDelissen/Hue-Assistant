import 'package:flutter/material.dart';
import 'package:flutter_hue/domain/models/light/light.dart';
import 'package:hue_assistant/utils/hue_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/setting_switch.dart';
import '../widgets/light_dropdown.dart';
import '../widgets/light_control_section.dart';
import '../widgets/light_color_section.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _startTalkingOnLaunch = false;
  bool _isLoading = true;
  Light? _selectedLight;
  List<Light> _lights = [];
  late HueActions _hueActions;

  @override
  void initState() {
    super.initState();
    _initializeHue();
  }

  Future<void> _initializeHue() async {
    try {
      _hueActions = await HueActions.create();
      await _loadSettings();
      await _loadLightState();
    } catch (e) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _startTalkingOnLaunch = prefs.getBool('startTalkingOnLaunch') ?? false;
    });
  }

  Future<void> _loadLightState() async {
    try {
      final lights = await _hueActions.getLights();
      final prefs = await SharedPreferences.getInstance();
      final savedLightId = prefs.getString('selectedLightId');

      Light? selectedLight;
      if (lights.isNotEmpty) {
        selectedLight = lights.firstWhere(
              (light) => light.id == savedLightId,
          orElse: () => lights.first,
        );

        if (selectedLight.id != savedLightId) {
          await prefs.setString('selectedLightId', selectedLight.id);
        }
      }

      setState(() {
        _lights = lights;
        _selectedLight = selectedLight;
      });
    } catch (e) {
      _showErrorSnackbar('Failed to load lights: ${e.toString()}');
    }
  }

  Future<void> _handleLightToggle(bool value) async {
    if (_selectedLight == null) return;
    setState(() => _isLoading = true);
    try {
      await _hueActions.updateLightState(_selectedLight!, on: value);
      await _hueActions.refreshNetwork();
      final updatedLights = await _hueActions.getLights(forceRefresh: true);
      final updatedLight = updatedLights.firstWhere(
            (light) => light.id == _selectedLight!.id,
        orElse: () => _selectedLight!,
      );
      setState(() => _selectedLight = updatedLight);
    } catch (e) {
      _showErrorSnackbar('Light update failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleColorChange(Color color) async {
    if (_selectedLight == null) return;
    setState(() => _isLoading = true);
    try {
      await _hueActions.updateLightState(_selectedLight!, color: color);
      await _hueActions.refreshNetwork();
    } catch (e) {
      _showErrorSnackbar('Color change failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBrightnessChange(double brightness) async {
    if (_selectedLight == null) return;
    setState(() => _isLoading = true);
    try {
      await _hueActions.updateLightState(_selectedLight!, brightness: brightness);
      await _hueActions.refreshNetwork();
      final updatedLights = await _hueActions.getLights(forceRefresh: true);
      final updatedLight = updatedLights.firstWhere(
            (light) => light.id == _selectedLight!.id,
        orElse: () => _selectedLight!,
      );
      setState(() => _selectedLight = updatedLight);
    } catch (e) {
      _showErrorSnackbar('Brightness update failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          SettingSwitch(
            title: 'Start Talking on Launch',
            value: _startTalkingOnLaunch,
            onChanged: (value) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('startTalkingOnLaunch', value);
              setState(() => _startTalkingOnLaunch = value);
            },
          ),
          if (_lights.isNotEmpty)
            LightDropdown(
              lights: _lights,
              selectedLightId: _selectedLight?.id,
              onChanged: (light) async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('selectedLightId', light.id);
                setState(() => _selectedLight = light);
              },
            ),
          if (_selectedLight != null) ...[
            LightControlSection(
              light: _selectedLight!,
              onToggle: _handleLightToggle,
              onBrightnessChange: _handleBrightnessChange,
            ),
            ColorControlSection(
              onColorChange: _handleColorChange,
            ),
          ]
        ],
      ),
    );
  }
}
