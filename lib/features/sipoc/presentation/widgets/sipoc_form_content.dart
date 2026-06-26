import 'dart:io';
import 'package:flutter/material.dart';
import '../../../clientes/domain/cliente.dart';
import '../../../clientes/domain/setor.dart';
import '../../domain/sipoc_detalhe.dart';

class SipocFormContent extends StatefulWidget {
  final SipocDetalhe? item;
  final List<Cliente> clientes;
  final List<Setor> setores;
  final Cliente? clienteSelecionado;
  final Setor? setorSelecionado;

  final TextEditingController tituloController;
  final TextEditingController parteController;
  final TextEditingController codigoController;
  final TextEditingController revisaoController;
  final TextEditingController dataController;
  final TextEditingController responsaveisController;
  final TextEditingController objetivoController;
  final TextEditingController fornecedoresController;
  final TextEditingController entradasController;
  final TextEditingController processoController;
  final TextEditingController saidasController;
  final TextEditingController clientesController;
  final TextEditingController indicadoresController;
  final TextEditingController fluxoTextoController;

  final ValueChanged<Cliente?> onClienteChanged;
  final ValueChanged<Setor?> onSetorChanged;
  final Future<void> Function() onSalvar;

  final InputDecoration Function({
  required String label,
  required String hint,
  }) buildInputDecoration;

  final List<String> Function(String texto) extrairBlocosFluxo;

  const SipocFormContent({
    super.key,
    required this.item,
    required this.clientes,
    required this.setores,
    required this.clienteSelecionado,
    required this.setorSelecionado,
    required this.tituloController,
    required this.parteController,
    required this.codigoController,
    required this.revisaoController,
    required this.dataController,
    required this.responsaveisController,
    required this.objetivoController,
    required this.fornecedoresController,
    required this.entradasController,
    required this.processoController,
    required this.saidasController,
    required this.clientesController,
    required this.indicadoresController,
    required this.fluxoTextoController,
    required this.onClienteChanged,
    required this.onSetorChanged,
    required this.onSalvar,
    required this.buildInputDecoration,
    required this.extrairBlocosFluxo,
  });

  @override
  State<SipocFormContent> createState() => _SipocFormContentState();
}

class _SipocFormContentState extends State<SipocFormContent> {
  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.item == null ? 'Novo SIPOC' : 'Editar SIPOC',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Digite as informações do processo nos campos do lado esquerdo da tela e coloque o fluxo com texto entre aspas no final do formulário.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<Cliente>(
                                value: widget.clienteSelecionado,
                                decoration: widget.buildInputDecoration(
                                  label: 'Cliente',
                                  hint: 'Selecione o cliente',
                                ),
                                items: widget.clientes.map((cliente) {
                                  return DropdownMenuItem<Cliente>(
                                    value: cliente,
                                    child: Text(cliente.nome),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  widget.onClienteChanged(value);
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<Setor>(
                                value: widget.setorSelecionado,
                                decoration: widget.buildInputDecoration(
                                  label: 'Setor',
                                  hint: 'Selecione o setor',
                                ),
                                items: widget.setores.map((setor) {
                                  return DropdownMenuItem<Setor>(
                                    value: setor,
                                    child: Text(setor.nome),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  widget.onSetorChanged(value);
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: widget.tituloController,
                                decoration: widget.buildInputDecoration(
                                  label: 'Título',
                                  hint: 'Ex: Emissão Documentos de Transporte',
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: widget.parteController,
                                decoration: widget.buildInputDecoration(
                                  label: 'Parte',
                                  hint: 'Ex: Parte 1',
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: widget.codigoController,
                                decoration: widget.buildInputDecoration(
                                  label: 'Código',
                                  hint: 'Ex: ASDA',
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: widget.revisaoController,
                                decoration: widget.buildInputDecoration(
                                  label: 'Revisão',
                                  hint: 'Ex: 01',
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: widget.dataController,
                                decoration: widget.buildInputDecoration(
                                  label: 'Data',
                                  hint: 'Ex: 03/03/2026',
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: widget.responsaveisController,
                                decoration: widget.buildInputDecoration(
                                  label: 'Responsáveis',
                                  hint: 'Ex: Morais Wesley',
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: widget.objetivoController,
                          maxLines: 3,
                          decoration: widget.buildInputDecoration(
                            label: 'Objetivo',
                            hint: 'Digite o objetivo',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: widget.fornecedoresController,
                          maxLines: 4,
                          decoration: widget.buildInputDecoration(
                            label: 'Fornecedores',
                            hint: 'Um ou mais fornecedores',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: widget.entradasController,
                          maxLines: 4,
                          decoration: widget.buildInputDecoration(
                            label: 'Entradas',
                            hint: 'Digite as entradas',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: widget.processoController,
                          maxLines: 6,
                          decoration: widget.buildInputDecoration(
                            label: 'Processo',
                            hint: 'Digite o processo',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: widget.saidasController,
                          maxLines: 3,
                          decoration: widget.buildInputDecoration(
                            label: 'Saídas',
                            hint: 'Digite as saídas',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: widget.clientesController,
                          maxLines: 3,
                          decoration: widget.buildInputDecoration(
                            label: 'Clientes',
                            hint: 'Digite os clientes',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: widget.indicadoresController,
                          maxLines: 2,
                          decoration: widget.buildInputDecoration(
                            label: 'Indicadores',
                            hint: 'Digite os indicadores',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),

                        const SizedBox(height: 20),

                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: widget.onSalvar,
                            icon: const Icon(Icons.save),
                            label: Text(
                              widget.item == null
                                  ? 'Salvar SIPOC'
                                  : 'Salvar alterações',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 7,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          width: 980,
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black54),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 220,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.black54),
                                            color: Colors.white,
                                          ),
                                          alignment: Alignment.center,
                                          child: widget.clienteSelecionado != null &&
                                              widget.clienteSelecionado!.logoPath.isNotEmpty
                                              ? Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Image.file(
                                              File(widget.clienteSelecionado!.logoPath),
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) {
                                                return const Icon(
                                                  Icons.business,
                                                  size: 40,
                                                );
                                              },
                                            ),
                                          )
                                              : const Icon(Icons.business, size: 40),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 90,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.black54),
                                              color: Colors.white,
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  widget.clienteSelecionado?.nome ?? '',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  widget.setorSelecionado?.nome ?? '',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  widget.parteController.text,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 220,
                                          constraints: const BoxConstraints(minHeight: 120),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.black54),
                                            color: Colors.white,
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('Código: ${widget.codigoController.text}'),
                                              Text('Revisão: ${widget.revisaoController.text}'),
                                              Text('Data: ${widget.dataController.text}'),
                                              Text(
                                                'Resp.: ${widget.responsaveisController.text}',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          width: 220,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.black54),
                                            color: Colors.white,
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: const Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'OBJETIVO',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 64,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.black54),
                                              color: Colors.white,
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              widget.objetivoController.text,
                                              style: const TextStyle(
                                                color: Color(0xFFB91C1C),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 40,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 9,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.black54),
                                                color: const Color(0xFFF9FAFB),
                                              ),
                                              alignment: Alignment.center,
                                              child: const Text(
                                                'Descrição do SIPOC',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 10,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.black54),
                                                color: const Color(0xFFF9FAFB),
                                              ),
                                              alignment: Alignment.center,
                                              child: const Text(
                                                'Fluxograma',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 560,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            flex: 9,
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                Container(
                                                  width: 36,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.black54),
                                                    color: Colors.white,
                                                  ),
                                                  child: Column(
                                                    children: const [
                                                      Expanded(
                                                        flex: 12,
                                                        child: Center(
                                                          child: Text(
                                                            'S',
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 12,
                                                        child: Center(
                                                          child: Text(
                                                            'I',
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 28,
                                                        child: Center(
                                                          child: Text(
                                                            'P',
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 10,
                                                        child: Center(
                                                          child: Text(
                                                            'O',
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 10,
                                                        child: Center(
                                                          child: Text(
                                                            'C',
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      Expanded(
                                                        flex: 12,
                                                        child: buildDescricaoLinha(
                                                          titulo: 'Fornecedores',
                                                          texto: widget.fornecedoresController.text,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 12,
                                                        child: buildDescricaoLinha(
                                                          titulo: 'Entrada',
                                                          texto: widget.entradasController.text,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 28,
                                                        child: buildDescricaoLinha(
                                                          titulo: 'Processo',
                                                          texto: widget.processoController.text,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 10,
                                                        child: buildDescricaoLinha(
                                                          titulo: 'Saída',
                                                          texto: widget.saidasController.text,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 10,
                                                        child: buildDescricaoLinha(
                                                          titulo: 'Clientes',
                                                          texto: widget.clientesController.text,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 10,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.black54),
                                                color: Colors.white,
                                              ),
                                              alignment: Alignment.topCenter,
                                              padding: const EdgeInsets.only(
                                                top: 16,
                                                left: 16,
                                                right: 16,
                                                bottom: 16,
                                              ),
                                              child: buildFluxoColuna(
                                                widget.extrairBlocosFluxo(
                                                  widget.fluxoTextoController.text,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          width: 254,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.black54),
                                            color: Colors.white,
                                          ),
                                          child: const Text(
                                            'INDICADORES DESEMPENHO',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.black54),
                                              color: Colors.white,
                                            ),
                                            child: Text(
                                              widget.indicadoresController.text,
                                              style: const TextStyle(
                                                color: Color(0xFFB91C1C),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget buildDescricaoLinha({
    required String titulo,
    required String texto,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                texto,
                style: const TextStyle(
                  color: Color(0xFFB91C1C),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFluxoColuna(List<String> blocos) {
    if (blocos.isEmpty) {
      return const Center(
        child: Text(
          'Digite frases entre aspas no campo Fluxo texto.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(blocos.length, (index) {
          final ultimo = index == blocos.length - 1;
          return Column(
            children: [
              Container(
                width: 210,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black87),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  blocos[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ),
              if (!ultimo)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Icon(
                    Icons.arrow_downward,
                    size: 20,
                    color: Colors.black87,
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}