import 'package:flutter/material.dart';

class PremiumStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? footer;

  const PremiumStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        constraints: const BoxConstraints(minHeight: 150),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFF2C300).withOpacity(0.18),
              child: Icon(icon, color: Colors.black87),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (footer != null) ...[
              const SizedBox(height: 10),
              Text(
                footer!,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}