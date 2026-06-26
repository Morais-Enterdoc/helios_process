import 'package:flutter/material.dart';
import '../../domain/sipoc_detalhe.dart';

class SipocTab extends StatelessWidget {
  final SipocDetalhe sipocDetalhe;

  const SipocTab({
    super.key,
    required this.sipocDetalhe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Aqui ficará o conteúdo atual do SIPOC: formulário, preview, fluxo textual e exportação PDF.',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}