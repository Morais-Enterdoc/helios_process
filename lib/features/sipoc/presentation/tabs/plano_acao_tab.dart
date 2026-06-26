import 'package:flutter/material.dart';
import '../../domain/sipoc_detalhe.dart';

class PlanoAcaoTab extends StatelessWidget {
  final SipocDetalhe sipocDetalhe;

  const PlanoAcaoTab({
    super.key,
    required this.sipocDetalhe,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Tela Plano de Ação em construção.'),
        ),
      ),
    );
  }
}