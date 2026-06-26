import 'package:flutter/material.dart';

import '../../domain/as_is.dart';

class AsIsFormDialog extends StatefulWidget {
  final int sipocId;
  final AsIs? item;

  const AsIsFormDialog({
    super.key,
    required this.sipocId,
    this.item,
  });

  @override
  State<AsIsFormDialog> createState() => _AsIsFormDialogState();
}

class _AsIsFormDialogState extends State<AsIsFormDialog> {
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController processoController = TextEditingController();
  final TextEditingController fluxoController = TextEditingController();
  final TextEditingController ordemFluxoController = TextEditingController();
  final TextEditingController responsavelController = TextEditingController();
  final TextEditingController dataRegistroController = TextEditingController();
  final TextEditingController observacoesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.item != null) {
      tituloController.text = widget.item!.titulo;
      descricaoController.text = widget.item!.descricao;
      processoController.text = widget.item!.processo;
      fluxoController.text = widget.item!.fluxo;
      ordemFluxoController.text = widget.item!.ordemFluxo.toString();
      responsavelController.text = widget.item!.responsavel;
      dataRegistroController.text = widget.item!.dataRegistro;
      observacoesController.text = widget.item!.observacoes;
    }
  }

  @override
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    processoController.dispose();
    fluxoController.dispose();
    ordemFluxoController.dispose();
    responsavelController.dispose();
    dataRegistroController.dispose();
    observacoesController.dispose();
    super.dispose();
  }

  InputDecoration buildInputDecoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      alignLabelWithHint: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF1D4ED8), width: 1.4),
      ),
    );
  }

  void salvar() {
    final novoItem = AsIs(
      id: widget.item?.id,
      sipocId: widget.sipocId,
      titulo: tituloController.text.trim(),
      descricao: descricaoController.text.trim(),
      processo: processoController.text.trim(),
      fluxo: fluxoController.text.trim(),
      ordemFluxo: int.tryParse(ordemFluxoController.text.trim()) ?? 0,
      responsavel: responsavelController.text.trim(),
      dataRegistro: dataRegistroController.text.trim(),
      observacoes: observacoesController.text.trim(),
    );

    Navigator.of(context).pop(novoItem);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.item == null ? 'Novo AS-IS' : 'Editar AS-IS',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Descreva a situação atual do processo vinculado a este SIPOC.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: tituloController,
                    decoration: buildInputDecoration(
                      label: 'Título',
                      hint: 'Ex: Situação atual do processo',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descricaoController,
                    maxLines: 4,
                    decoration: buildInputDecoration(
                      label: 'Descrição',
                      hint: 'Descreva como o processo funciona hoje',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: processoController,
                    maxLines: 6,
                    decoration: buildInputDecoration(
                      label: 'Processo',
                      hint: 'Descreva o processo operacional detalhado',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: fluxoController,
                          decoration: buildInputDecoration(
                            label: 'Fluxo',
                            hint: 'Ex: Emissão',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: ordemFluxoController,
                          keyboardType: TextInputType.number,
                          decoration: buildInputDecoration(
                            label: 'Ordem do fluxo',
                            hint: 'Ex: 1',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: responsavelController,
                          decoration: buildInputDecoration(
                            label: 'Responsável',
                            hint: 'Ex: Wesley',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: dataRegistroController,
                          decoration: buildInputDecoration(
                            label: 'Data do registro',
                            hint: 'Ex: 11/05/2026',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: observacoesController,
                    maxLines: 4,
                    decoration: buildInputDecoration(
                      label: 'Observações',
                      hint: 'Informações complementares',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                label: const Text('Cancelar'),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: salvar,
                icon: const Icon(Icons.save),
                label: const Text('Salvar'),
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
            ],
          ),
        ],
      ),
    );
  }
}