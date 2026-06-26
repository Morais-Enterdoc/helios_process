import 'package:flutter/material.dart';

import '../../domain/cronograma_item.dart';

class CronogramaGantt extends StatelessWidget {
  final List<CronogramaItem> itens;
  final DateTime? dataInicio;
  final DateTime? dataFim;

  const CronogramaGantt({
    super.key,
    required this.itens,
    required this.dataInicio,
    required this.dataFim,
  });

  List<DateTime> get semanas {
    if (dataInicio == null || dataFim == null) return [];

    final inicioBase = dataInicio!;
    final fimBase = dataFim!;
    final lista = <DateTime>[];

    DateTime cursor = inicioBase;
    while (!cursor.isAfter(fimBase)) {
      lista.add(cursor);
      cursor = cursor.add(const Duration(days: 7));
    }

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final semanasProjeto = semanas;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Text(
              'Visão cronológica',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Leitura visual do cronograma em semanas, semelhante ao Project.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (semanasProjeto.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Defina início e fim do projeto para visualizar o cronograma.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(
                          width: 260,
                          child: Text(
                            'Atividades',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                        ...List.generate(semanasProjeto.length, (index) {
                          return Container(
                            width: 84,
                            height: 40,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(left: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Sem ${index + 1}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...itens.map((item) {
                      final titulo = item.nivel == 0
                          ? item.atividadePrincipal
                          : item.nivel == 1
                          ? item.atividade
                          : item.subatividade;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 260,
                              child: Text(
                                titulo.isEmpty ? '-' : titulo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: item.nivel == 0
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                            ),
                            ...List.generate(semanasProjeto.length, (index) {
                              final cor = item.status == 'Concluída'
                                  ? const Color(0xFFBBF7D0)
                                  : item.status == 'Em andamento'
                                  ? const Color(0xFFBFDBFE)
                                  : item.status == 'Atenção'
                                  ? const Color(0xFFFED7AA)
                                  : const Color(0xFFE5E7EB);

                              return Container(
                                width: 84,
                                height: 34,
                                margin: const EdgeInsets.only(left: 1),
                                decoration: BoxDecoration(
                                  color: index == 0 ? cor : cor.withOpacity(0.45),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}