import 'package:flutter/material.dart';

import '../../domain/cronograma_item.dart';

class CronogramaGrid extends StatelessWidget {
  final List<CronogramaItem> itens;
  final void Function(int index, CronogramaItem item) onItemChanged;
  final void Function(int index) onRemoverItem;
  final String Function(DateTime? data) formatarData;

  const CronogramaGrid({
    super.key,
    required this.itens,
    required this.onItemChanged,
    required this.onRemoverItem,
    required this.formatarData,
  });

  @override
  Widget build(BuildContext context) {
    const larguras = <double>[
      300,
      180,
      120,
      95,
      105,
      120,
      120,
      110,
      150,
      60,
    ];

    final larguraTotal =
    larguras.fold<double>(0, (total, item) => total + item);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: larguraTotal,
                child: const Row(
                  children: [
                    _HeaderCell('Atividade / Tarefa', 300),
                    _HeaderCell('Responsável', 180),
                    _HeaderCell('Início', 120),
                    _HeaderCell('Dias úteis', 95),
                    _HeaderCell('Dias corridos', 105),
                    _HeaderCell('Término', 120),
                    _HeaderCell('Próx. ação', 120),
                    _HeaderCell('Realizado %', 110),
                    _HeaderCell('Status', 150),
                    _HeaderCell('', 60),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Expanded(
            child: itens.isEmpty
                ? const Center(
              child: Text(
                'Nenhum item no cronograma.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            )
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: larguraTotal,
                child: ListView.separated(
                  itemCount: itens.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: Color(0xFFE5E7EB),
                  ),
                  itemBuilder: (context, index) {
                    return _CronogramaRowEditor(
                      item: itens[index],
                      onChanged: (novo) => onItemChanged(index, novo),
                      onRemover: () => onRemoverItem(index),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double width;

  const _HeaderCell(this.label, this.width);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF374151),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _CronogramaRowEditor extends StatefulWidget {
  final CronogramaItem item;
  final ValueChanged<CronogramaItem> onChanged;
  final VoidCallback onRemover;

  const _CronogramaRowEditor({
    required this.item,
    required this.onChanged,
    required this.onRemover,
  });

  @override
  State<_CronogramaRowEditor> createState() => _CronogramaRowEditorState();
}

class _CronogramaRowEditorState extends State<_CronogramaRowEditor> {
  late final TextEditingController tituloController;
  late final TextEditingController responsavelController;
  late final TextEditingController inicioController;
  late final TextEditingController diasUteisController;
  late final TextEditingController diasCorridosController;
  late final TextEditingController terminoController;
  late final TextEditingController proximaAcaoController;
  late final TextEditingController realizadoController;

  final List<String> statusDisponiveis = const [
    'Não iniciada',
    'Em andamento',
    'Atenção',
    'Concluída',
  ];

  @override
  void initState() {
    super.initState();
    tituloController = TextEditingController(text: _tituloAtual(widget.item));
    responsavelController =
        TextEditingController(text: widget.item.responsavel);
    inicioController = TextEditingController(text: _formatar(widget.item.inicio));
    diasUteisController =
        TextEditingController(text: widget.item.diasUteis.toString());
    diasCorridosController =
        TextEditingController(text: widget.item.diasCorridos.toString());
    terminoController =
        TextEditingController(text: _formatar(widget.item.termino));
    proximaAcaoController =
        TextEditingController(text: _formatar(widget.item.dataProximaAcao));
    realizadoController = TextEditingController(
      text: (widget.item.realizadoPercentual * 100).toStringAsFixed(0),
    );
  }

  @override
  void didUpdateWidget(covariant _CronogramaRowEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item) {
      tituloController.text = _tituloAtual(widget.item);
      responsavelController.text = widget.item.responsavel;
      inicioController.text = _formatar(widget.item.inicio);
      diasUteisController.text = widget.item.diasUteis.toString();
      diasCorridosController.text = widget.item.diasCorridos.toString();
      terminoController.text = _formatar(widget.item.termino);
      proximaAcaoController.text = _formatar(widget.item.dataProximaAcao);
      realizadoController.text =
          (widget.item.realizadoPercentual * 100).toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    tituloController.dispose();
    responsavelController.dispose();
    inicioController.dispose();
    diasUteisController.dispose();
    diasCorridosController.dispose();
    terminoController.dispose();
    proximaAcaoController.dispose();
    realizadoController.dispose();
    super.dispose();
  }

  String _tituloAtual(CronogramaItem item) {
    if (item.nivel == 0) return item.atividadePrincipal;
    if (item.nivel == 1) return item.atividade;
    return item.subatividade;
  }

  String _formatar(DateTime? data) {
    if (data == null) return '';
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    return '$dia/$mes/$ano';
  }

  DateTime? _parseData(String value) {
    final texto = value.trim();
    if (texto.isEmpty) return null;

    final partes = texto.split('/');
    if (partes.length != 3) return null;

    final dia = int.tryParse(partes[0]);
    final mes = int.tryParse(partes[1]);
    final ano = int.tryParse(partes[2]);

    if (dia == null || mes == null || ano == null) return null;
    return DateTime(ano, mes, dia);
  }

  int _parseInt(String value) {
    return int.tryParse(value.trim()) ?? 0;
  }

  double _parsePercentual(String value) {
    final numero = double.tryParse(value.replaceAll(',', '.').trim()) ?? 0;
    return (numero / 100).clamp(0, 1);
  }

  void _emitirAtualizacao() {
    final titulo = tituloController.text.trim();

    widget.onChanged(
      widget.item.copyWith(
        atividadePrincipal: widget.item.nivel == 0 ? titulo : widget.item.atividadePrincipal,
        atividade: widget.item.nivel == 1 ? titulo : widget.item.atividade,
        subatividade: widget.item.nivel == 2 ? titulo : widget.item.subatividade,
        responsavel: responsavelController.text.trim(),
        inicio: _parseData(inicioController.text),
        diasUteis: _parseInt(diasUteisController.text),
        diasCorridos: _parseInt(diasCorridosController.text),
        termino: _parseData(terminoController.text),
        dataProximaAcao: _parseData(proximaAcaoController.text),
        realizadoPercentual: _parsePercentual(realizadoController.text),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Concluída':
        return const Color(0xFF16A34A);
      case 'Em andamento':
        return const Color(0xFF2563EB);
      case 'Atenção':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF6B7280);
    }
  }

  InputDecoration _cellDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(widget.item.status);
    final paddingLeft = switch (widget.item.nivel) {
      0 => 0.0,
      1 => 16.0,
      _ => 32.0,
    };

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 300,
            child: Padding(
              padding: EdgeInsets.only(left: paddingLeft),
              child: TextFormField(
                controller: tituloController,
                onChanged: (_) => _emitirAtualizacao(),
                decoration: _cellDecoration(
                  hint: widget.item.nivel == 0
                      ? 'Etapa principal'
                      : widget.item.nivel == 1
                      ? 'Atividade'
                      : 'Subatividade',
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 180,
            child: TextFormField(
              controller: responsavelController,
              onChanged: (_) => _emitirAtualizacao(),
              decoration: _cellDecoration(hint: 'Responsável'),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: TextFormField(
              controller: inicioController,
              onChanged: (_) => _emitirAtualizacao(),
              decoration: _cellDecoration(hint: 'dd/mm/aaaa'),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 95,
            child: TextFormField(
              controller: diasUteisController,
              onChanged: (_) => _emitirAtualizacao(),
              textAlign: TextAlign.center,
              decoration: _cellDecoration(),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 105,
            child: TextFormField(
              controller: diasCorridosController,
              onChanged: (_) => _emitirAtualizacao(),
              textAlign: TextAlign.center,
              decoration: _cellDecoration(),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: TextFormField(
              controller: terminoController,
              onChanged: (_) => _emitirAtualizacao(),
              decoration: _cellDecoration(hint: 'dd/mm/aaaa'),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: TextFormField(
              controller: proximaAcaoController,
              onChanged: (_) => _emitirAtualizacao(),
              decoration: _cellDecoration(hint: 'dd/mm/aaaa'),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: TextFormField(
              controller: realizadoController,
              onChanged: (_) => _emitirAtualizacao(),
              textAlign: TextAlign.center,
              decoration: _cellDecoration(hint: '%'),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 150,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor.withOpacity(0.25)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: widget.item.status,
                  isExpanded: true,
                  items: statusDisponiveis.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(
                        status,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(status),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    widget.onChanged(
                      widget.item.copyWith(status: value),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: widget.onRemover,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}