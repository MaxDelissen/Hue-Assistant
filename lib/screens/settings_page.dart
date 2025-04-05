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
  bool _isLoading = true;
  Light? _selectedLight;
  late HueActions _hueActions;

  @override
  void initState() {
    super.initState();
    _initializeHue();
  }

  Future<void> _initializeHue() async {
    try {
      // Initialize HueActions first
      _hueActions = await HueActions.create();
      await _loadSettings();
      await _loadLightState();
    } catch (e) {
      _showErrorSnackbar('Hue initialization failed: ${e.toString()}');
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
      if (lights.isNotEmpty) {
        setState(() => _selectedLight = lights[1]);
      }
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

      // Find the matching light by ID
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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
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
          _buildSettingSwitch(
            title: 'Start Talking on Launch',
            value: _startTalkingOnLaunch,
            onChanged: (value) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('startTalkingOnLaunch', value);
              setState(() => _startTalkingOnLaunch = value);
            },
          ),
          if (_selectedLight != null) ...[
            _buildLightControlSection(),
            _buildColorControlSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildLightControlSection() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Light Controls', style: TextStyle(fontSize: 18)),
        ),
        SwitchListTile(
          title: const Text('Toggle Light'),
          value: _selectedLight?.on.isOn ?? false,
          onChanged: _handleLightToggle,
        ),
      ],
    );
  }

  Widget _buildColorControlSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Light Colors:', style: TextStyle(fontSize: 16)),
          Wrap(
            spacing: 8,
            children: [
              _ColorButton(
                color: Colors.red,
                onPressed: () => _handleColorChange(Colors.red),
              ),
              _ColorButton(
                color: Colors.green,
                onPressed: () => _handleColorChange(Colors.green),
              ),
              _ColorButton(
                color: Colors.blue,
                onPressed: () => _handleColorChange(Colors.blue),
              ),
              _ColorButton(
                color: Colors.white,
                onPressed: () => _handleColorChange(Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final VoidCallback onPressed;

  const _ColorButton({required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}