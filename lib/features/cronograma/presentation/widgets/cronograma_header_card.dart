import 'package:flutter/material.dart';

class CronogramaHeaderCard extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final VoidCallback onNovoPrincipal;
  final VoidCallback onNovaAtividade;
  final VoidCallback onNovaSubatividade;

  const CronogramaHeaderCard({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.onNovoPrincipal,
    required this.onNovaAtividade,
    required this.onNovaSubatividade,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitulo,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'principal') onNovoPrincipal();
            if (value == 'atividade') onNovaAtividade();
            if (value == 'subatividade') onNovaSubatividade();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'principal',
              child: Text('Nova etapa principal'),
            ),
            PopupMenuItem(
              value: 'atividade',
              child: Text('Nova atividade'),
            ),
            PopupMenuItem(
              value: 'subatividade',
              child: Text('Nova subatividade'),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF12324A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Novo item',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}