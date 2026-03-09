import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PixQrWidget extends StatelessWidget {
  final String pixCode;

  const PixQrWidget({
    super.key,
    required this.pixCode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Escaneie o QR Code para pagar',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: QrImageView(
            data: pixCode,
            version: QrVersions.auto,
            size: 220,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SelectableText(
          pixCode,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}