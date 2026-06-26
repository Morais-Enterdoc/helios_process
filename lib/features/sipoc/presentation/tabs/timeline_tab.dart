import 'package:flutter/material.dart';
import '../../domain/sipoc_detalhe.dart';

class TimelineTab extends StatelessWidget {
  final SipocDetalhe sipocDetalhe;

  const TimelineTab({
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
          child: Text('Tela Timeline em construção.'),
        ),
      ),
    );
  }
}