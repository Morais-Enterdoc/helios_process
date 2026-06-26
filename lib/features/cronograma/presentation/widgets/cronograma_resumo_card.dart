import 'package:flutter/material.dart';

class CronogramaResumoCard extends StatelessWidget {
  final String cliente;
  final String setor;
  final String projeto;
  final String periodo;
  final int diasUteis;
  final int diasCorridos;
  final double realizadoMedio;

  const CronogramaResumoCard({
    super.key,
    required this.cliente,
    required this.setor,
    required this.projeto,
    required this.periodo,
    required this.diasUteis,
    required this.diasCorridos,
    required this.realizadoMedio,
  });

  String get percentualFormatado {
    return '${(realizadoMedio * 100).toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  titulo: 'Cliente',
                  valor: cliente.isEmpty ? '-' : cliente,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                  titulo: 'Setor',
                  valor: setor.isEmpty ? '-' : setor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                  titulo: 'Projeto',
                  valor: projeto.isEmpty ? '-' : projeto,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                  titulo: 'Período',
                  valor: periodo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _KpiTile(
                  titulo: 'Dias úteis',
                  valor: diasUteis.toString(),
                  cor: const Color(0xFF0F766E),
                  fundo: const Color(0xFFCCFBF1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KpiTile(
                  titulo: 'Dias corridos',
                  valor: diasCorridos.toString(),
                  cor: const Color(0xFF1D4ED8),
                  fundo: const Color(0xFFDBEAFE),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KpiTile(
                  titulo: 'Realizado médio',
                  valor: percentualFormatado,
                  cor: const Color(0xFFB45309),
                  fundo: const Color(0xFFFEF3C7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String titulo;
  final String valor;

  const _InfoTile({
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color cor;
  final Color fundo;

  const _KpiTile({
    required this.titulo,
    required this.valor,
    required this.cor,
    required this.fundo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}