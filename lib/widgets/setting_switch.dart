import 'package:flutter/material.dart';

class SettingSwitch extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingSwitch({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}
