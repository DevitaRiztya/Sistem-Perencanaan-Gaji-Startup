import 'package:flutter/material.dart';

class HasilRincianCard extends StatelessWidget {
  final String label;
  final String nilai;
  final String rumus;
  final IconData icon;
  final Color color;

  const HasilRincianCard({
    super.key,
    required this.label,
    required this.nilai,
    required this.rumus,
    required this.icon,
    this.color = Colors.indigo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: color.withValues(alpha: 0.9),
                  ),
                ),
              ),
              SelectableText(
                nilai,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              "Rumus: $rumus",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
