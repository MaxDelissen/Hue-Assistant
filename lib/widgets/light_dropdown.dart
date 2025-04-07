import 'package:flutter/material.dart';
import 'package:flutter_hue/domain/models/light/light.dart';

class LightDropdown extends StatelessWidget {
  final List<Light> lights;
  final String? selectedLightId;
  final ValueChanged<Light> onChanged;

  const LightDropdown({
    super.key,
    required this.lights,
    required this.selectedLightId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Light', style: TextStyle(fontSize: 16)),
          DropdownButton<String>(
            value: selectedLightId,
            items: lights.map((light) {
              return DropdownMenuItem<String>(
                value: light.id,
                child: Text(light.metadata.name),
              );
            }).toList(),
            onChanged: (newId) {
              if (newId != null) {
                final selected = lights.firstWhere((l) => l.id == newId);
                onChanged(selected);
              }
            },
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}
