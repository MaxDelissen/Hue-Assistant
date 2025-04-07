import 'package:flutter/material.dart';

class ColorControlSection extends StatelessWidget {
  final ValueChanged<Color> onColorChange;

  const ColorControlSection({
    super.key,
    required this.onColorChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Light Colors:', style: TextStyle(fontSize: 16)),
          Wrap(
            spacing: 8,
            children: [
              _ColorButton(color: Colors.red, onPressed: () => onColorChange(Colors.red)),
              _ColorButton(color: Colors.green, onPressed: () => onColorChange(Colors.green)),
              _ColorButton(color: Colors.blue, onPressed: () => onColorChange(Colors.blue)),
              _ColorButton(color: Colors.white, onPressed: () => onColorChange(Colors.white)),
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
