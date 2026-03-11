import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PixQrWidget extends StatelessWidget {
  final String pixCode;

  const PixQrWidget({
    super.key,
    required this.pixCode,
  });

  bool get _isValidPix => pixCode.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_isValidPix) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.qr_code_2_outlined,
                size: 40,
                color: Colors.black54,
              ),
              SizedBox(height: 10),
              Text(
                'Código Pix indisponível no momento.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        const Text(
          'Escaneie o QR Code para pagar',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Você também pode copiar o código Pix logo abaixo.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.black12,
            ),
          ),
          child: QrImageView(
            data: pixCode.trim(),
            version: QrVersions.auto,
            size: 220,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.black12,
            ),
          ),
          child: SelectableText(
            pixCode.trim(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}