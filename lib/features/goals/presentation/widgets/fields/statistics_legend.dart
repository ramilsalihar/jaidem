import 'package:flutter/material.dart';

class StatisticsLegend extends StatelessWidget {
  const StatisticsLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(label: 'Выполнено', color: Colors.green),
        const SizedBox(width: 16),
        _LegendItem(label: 'В процессе', color: Colors.amber),
        const SizedBox(width: 16),
        _LegendItem(label: 'Не начато', color: Colors.red.shade400),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
