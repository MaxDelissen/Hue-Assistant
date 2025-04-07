import 'package:flutter/material.dart';
import 'package:flutter_hue/domain/models/light/light.dart';

class LightControlSection extends StatelessWidget {
  final Light light;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onBrightnessChange;

  const LightControlSection({
    super.key,
    required this.light,
    required this.onToggle,
    required this.onBrightnessChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Light Controls', style: TextStyle(fontSize: 18)),
        ),
        SwitchListTile(
          title: const Text('Toggle Light'),
          value: light.on.isOn,
          onChanged: onToggle,
        ),
        if (light.dimming != null) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Brightness', style: TextStyle(fontSize: 16)),
          ),
          Slider(
            value: light.dimming.brightness,
            min: 0,
            max: 100,
            divisions: 100,
            label: '${light.dimming.brightness.round()}',
            onChanged: (_) {},
            onChangeEnd: onBrightnessChange,
          ),
        ],
      ],
    );
  }
}
