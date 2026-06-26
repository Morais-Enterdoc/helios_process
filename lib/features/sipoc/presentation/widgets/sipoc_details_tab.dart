import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/sipoc_detalhe.dart';

class SipocDetailsTab extends StatelessWidget {
  final SipocDetalhe item;

  const SipocDetailsTab({
    super.key,
    required this.item,
  });

  Widget _buildInfo(String titulo, String valor, {int maxLines = 10}) {
    return Column(
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
          valor.isEmpty ? '-' : valor,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF111827),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sipoc = item.sipoc;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: item.clienteLogoPath.isNotEmpty
                      ? Image.file(
                    File(item.clienteLogoPath),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.business,
                        color: Color(0xFF6B7280),
                      );
                    },
                  )
                      : const Icon(
                    Icons.business,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sipoc.titulo.isEmpty ? 'Sem título' : sipoc.titulo,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.clienteNome.isEmpty ? 'Cliente não informado' : item.clienteNome,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.setorNome.isEmpty ? 'Setor não informado' : item.setorNome,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildInfo('Parte', sipoc.parte)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInfo('Código', sipoc.codigo)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInfo('Revisão', sipoc.revisao)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInfo('Data', sipoc.dataEmissao)),
                  ],
                ),
                const SizedBox(height: 18),
                _buildInfo('Responsáveis', sipoc.responsaveis),
                const SizedBox(height: 18),
                _buildInfo('Objetivo', sipoc.objetivo),
                const SizedBox(height: 18),
                _buildInfo('Fornecedores', sipoc.fornecedores),
                const SizedBox(height: 18),
                _buildInfo('Entradas', sipoc.entradas),
                const SizedBox(height: 18),
                _buildInfo('Processo', sipoc.processo),
                const SizedBox(height: 18),
                _buildInfo('Saídas', sipoc.saidas),
                const SizedBox(height: 18),
                _buildInfo('Clientes', sipoc.clientes),
                const SizedBox(height: 18),
                _buildInfo('Indicadores', sipoc.indicadores),
                const SizedBox(height: 18),
                _buildInfo('Fluxo texto', sipoc.fluxoTexto),
              ],
            ),
          ),
        ],
      ),
    );
  }
}