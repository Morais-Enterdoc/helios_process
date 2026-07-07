import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:convert';
import 'dart:io';

import '../data/chamado_repository.dart';
import '../domain/chamado.dart';
import '../domain/chamado_import_service.dart';

class ChamadosPage extends StatefulWidget {
  final Future<void> Function()? onChamadosAlterados;

  const ChamadosPage({
    super.key,
    this.onChamadosAlterados,
  });

  @override
  State<ChamadosPage> createState() => _ChamadosPageState();
}

class _ChamadosPageState extends State<ChamadosPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController numeroChamadoController =
  TextEditingController();
  final TextEditingController clienteController = TextEditingController();
  final TextEditingController assuntoController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController prazoController = TextEditingController();
  final TextEditingController roController = TextEditingController();
  final TextEditingController dataAtualizacaoController = TextEditingController();
  final ChamadoImportService _importService = ChamadoImportService();
  final ChamadoRepository chamadoRepository = ChamadoRepository();
  final TextEditingController anotacoesController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController filtroChamadoController = TextEditingController();
  final TextEditingController filtroClienteController = TextEditingController();
  final TextEditingController filtroAssuntoController = TextEditingController();
  final TextEditingController filtroRoController = TextEditingController();

  Chamado? chamadoSelecionado;

  String meuStatusSelecionado = 'Em análise';

  final List<String> meusStatus = const [
    'Em análise',
    'Desenvolvimento',
    'Teste base M&O',
    'Atualização sistema',
    'Atualização Sprint',
    'Atualização Base Cliente',
    'Testes Cliente',
    'Fechado',
  ];

  final Map<String, double> largurasChamados = {
    'chamado': 140,
    'cliente': 220,
    'assunto': 360,
    'meuStatus': 180,
    'statusAtual': 140,
    'abertura': 120,
  };

  final TextInputFormatter dataInputFormatter = TextInputFormatter.withFunction((
      oldValue,
      newValue,
      ) {
    final numeros = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (numeros.length > 8) {
      return oldValue;
    }

    final buffer = StringBuffer();

    for (int i = 0; i < numeros.length; i++) {
      if (i == 2 || i == 4) {
        buffer.write('/');
      }
      buffer.write(numeros[i]);
    }

    final textoFormatado = buffer.toString();

    return TextEditingValue(
      text: textoFormatado,
      selection: TextSelection.collapsed(offset: textoFormatado.length),
    );
  });

  String _normalizarMeuStatus(String valor) {
    switch (valor.trim()) {
      case '1.Análise':
        return 'Em análise';
      case '2.RO':
        return 'Em análise';
      case '3.Desenvolvimento':
        return 'Desenvolvimento';
      case '4.Teste':
        return 'Teste base M&O';
      case '5.Validação':
        return 'Testes Cliente';
      case '6.Entrega':
        return 'Atualização Base Cliente';
      default:
        return meusStatus.contains(valor) ? valor : 'Em análise';
    }
  }

  String tipoSolicitacao = 'Melhoria';
  String statusChamado = 'Aberto';
  String tipoLiberacao = 'Sprint';
  String filtroTipoSolicitacao = 'Todos';
  String filtroStatus = 'Todos';

  DateTimeRange? filtroPeriodoAbertura;

  List<Chamado> chamadosFiltrados = [];

  List<Chamado> chamados = const [
    Chamado(
      ticket: 'CH-2026-001',
      cliente: 'Cliente Exemplo',
      solicitante: 'Usuário Interno',
      assunto: 'Chamado inicial de exemplo',
      descricao: '',
      numeroRo: '',
      categoria: 'Melhoria',
      status: 'Em teste',
      servico: 'MO',
      dataAbertura: '10/04/2026',
      prazoEntrega: '',
      ultimaAtualizacao: '10/04/2026 10:30',
      agenteAtual: 'Analista',
      equipeAtual: 'Suporte',
      anotacoes: '',
      meuStatus: 'Em análise',
      anexos: [],
    ),
  ];

  List<String> get statusAtuaisDisponiveis {
    final lista = chamados
        .map((chamado) => chamado.status.trim())
        .where((status) => status.isNotEmpty)
        .toSet()
        .toList();

    lista.sort();
    return lista;
  }

  @override
  void dispose() {
    numeroChamadoController.dispose();
    clienteController.dispose();
    assuntoController.dispose();
    descricaoController.dispose();
    prazoController.dispose();
    roController.dispose();
    anotacoesController.dispose();
    dataAtualizacaoController.dispose();
    filtroChamadoController.dispose();
    filtroClienteController.dispose();
    filtroAssuntoController.dispose();
    filtroRoController.dispose();
    super.dispose();
  }

  Future<void> _abrirDetalhesChamado(Chamado chamado) async {
    carregarChamadoParaEdicao(chamado);

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                width: 960,
                constraints: const BoxConstraints(
                  maxWidth: 960,
                  maxHeight: 780,
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.confirmation_number_outlined,
                            color: Color(0xFF0369A1),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chamado ${chamado.ticket}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Visualize e edite os detalhes do chamado.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _StatusBadge(label: statusController.text.isEmpty ? chamado.status : statusController.text),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: numeroChamadoController,
                                    label: 'Número do chamado',
                                    hint: 'Ex: CH-2026-003',
                                    readOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: clienteController,
                                    label: 'Cliente',
                                    hint: 'Nome do cliente',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: assuntoController,
                                    label: 'Assunto',
                                    hint: 'Descreva o assunto',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDropdownField(
                                    label: 'Tipo da solicitação',
                                    value: tipoSolicitacao,
                                    items: const [
                                      'Correção',
                                      'Melhoria',
                                      'Novo Programa',
                                      'Ajuste Operacional',
                                    ],
                                    onChanged: (value) {
                                      dialogSetState(() {
                                        tipoSolicitacao = value!;
                                      });
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            _buildTextField(
                              controller: descricaoController,
                              label: 'Descrição',
                              hint: 'Detalhes do chamado',
                              maxLines: 4,
                              required: false,
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: prazoController,
                                    label: 'Prazo de entrega',
                                    hint: 'Ex: 15/04/2026',
                                    required: false,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: roController,
                                    label: 'Número da RO',
                                    hint: 'Ex: RO-4587',
                                    required: false,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: statusController,
                                    label: 'Status atual',
                                    hint: '',
                                    required: false,
                                    readOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDropdownField(
                                    label: 'Meu status',
                                    value: meusStatus.contains(_normalizarMeuStatus(meuStatusSelecionado))
                                        ? _normalizarMeuStatus(meuStatusSelecionado)
                                        : 'Em análise',
                                    items: meusStatus,
                                    onChanged: (value) {
                                      dialogSetState(() {
                                        meuStatusSelecionado = value ?? 'Em análise';
                                      });
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
                                  child: _buildDropdownField(
                                    label: 'Status do chamado',
                                    value: statusChamado,
                                    items: const [
                                      'Aberto',
                                      'Fechado',
                                    ],
                                    onChanged: (value) {
                                      dialogSetState(() {
                                        statusChamado = value ?? 'Aberto';
                                        statusController.text = statusChamado;
                                      });
                                      setState(() {});
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDropdownField(
                                    label: 'Tipo de liberação',
                                    value: tipoLiberacao,
                                    items: const [
                                      'Sprint',
                                      'Plantão',
                                    ],
                                    onChanged: (value) {
                                      dialogSetState(() {
                                        tipoLiberacao = value ?? 'Sprint';
                                      });
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Histórico do chamado',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF374151),
                                          ),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: chamadoSelecionado?.anotacoes.trim().isNotEmpty == true
                                            ? () {
                                          setState(() {
                                            chamadoSelecionado = chamadoSelecionado!.copyWith(
                                              anotacoes: '',
                                            );
                                          });
                                          dialogSetState(() {});
                                        }
                                            : null,
                                        icon: const Icon(
                                          Icons.delete_sweep_outlined,
                                          size: 18,
                                        ),
                                        label: const Text('Limpar histórico'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color(0xFFDC2626),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  Builder(
                                    builder: (context) {
                                      final historicoTexto = chamadoSelecionado?.anotacoes.trim() ?? '';
                                      final linhasHistorico = historicoTexto.isEmpty
                                          ? <String>[]
                                          : historicoTexto.split('\n');

                                      if (linhasHistorico.isEmpty) {
                                        return const Text(
                                          'Nenhuma atualização salva até o momento.',
                                          style: TextStyle(
                                            fontSize: 13,
                                            height: 1.5,
                                            color: Color(0xFF6B7280),
                                          ),
                                        );
                                      }

                                      return Column(
                                        children: linhasHistorico.asMap().entries.map((entry) {
                                          final indice = entry.key;
                                          final linha = entry.value;

                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 8),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    linha,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      height: 1.5,
                                                      color: Color(0xFF6B7280),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  tooltip: 'Remover esta linha',
                                                  visualDensity: VisualDensity.compact,
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    size: 18,
                                                    color: Color(0xFFDC2626),
                                                  ),
                                                  onPressed: () {
                                                    final novasLinhas = List<String>.from(linhasHistorico)
                                                      ..removeAt(indice);

                                                    dialogSetState(() {
                                                      chamadoSelecionado = chamadoSelecionado!.copyWith(
                                                        anotacoes: novasLinhas.join('\n'),
                                                      );
                                                    });

                                                    setState(() {});
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 180,
                                  child: _buildTextField(
                                    controller: dataAtualizacaoController,
                                    label: 'Data',
                                    hint: 'dd/mm/aaaa',
                                    required: false,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [dataInputFormatter],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: anotacoesController,
                                    label: 'Descrição da atualização',
                                    hint: 'Digite a atualização do chamado',
                                    maxLines: 1,
                                    required: false,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.attach_file, color: Color(0xFF6B7280)),
                                      SizedBox(width: 8),
                                      Text(
                                        'Anexos',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF374151),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (chamadoSelecionado == null ||
                                      chamadoSelecionado!.anexos.isEmpty)
                                    const Text(
                                      'Nenhum anexo adicionado.',
                                      style: TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontSize: 13,
                                      ),
                                    )
                                  else
                                    ...chamadoSelecionado!.anexos.map(
                                          (anexo) => Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: const Color(0xFFE5E7EB),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.insert_drive_file_outlined,
                                                size: 18,
                                                color: Color(0xFF6B7280),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  anexo,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF374151),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
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
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(Icons.close),
                          label: const Text('Fechar'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await selecionarAnexos();
                            dialogSetState(() {});
                            setState(() {});
                          },
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Adicionar anexo'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final confirmar = await showDialog<bool>(
                              context: dialogContext,
                              builder: (confirmContext) {
                                return AlertDialog(
                                  title: const Text('Excluir chamado'),
                                  content: Text(
                                    'Deseja realmente excluir o chamado ${chamado.ticket}? Esta ação não poderá ser desfeita.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(confirmContext).pop(false),
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(confirmContext).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFDC2626),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Excluir'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmar == true) {
                              await excluirChamadoSelecionado();

                              if (mounted) {
                                Navigator.of(dialogContext).pop();
                              }
                            }
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Excluir'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(color: Color(0xFFDC2626)),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await salvarAlteracoesChamadoSelecionado();
                            if (mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Salvar alterações'),
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
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> importarChamadosCsv() async {
    try {
      final resultado = await _importService.importarCsv(
        chamadosAtuais: chamados,
      );

      if (resultado == null) return;

      for (final chamado in resultado.chamados) {
        await chamadoRepository.inserirChamado(chamado);
      }

      await carregarChamados();

      if (widget.onChamadosAlterados != null) {
        await widget.onChamadosAlterados!();
      }

      if (widget.onChamadosAlterados != null) {
        await widget.onChamadosAlterados!();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Importação concluída: ${resultado.novos} novos e ${resultado.atualizados} atualizados.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Erro ao importar CSV: $e'),
        ),
      );
    }
  }



  Future<void> sincronizarMeuStatusPorStatusAtual({
    required String statusAtual,
    required String novoMeuStatus,
  }) async {
    try {
      final linhas = await chamadoRepository.atualizarMeuStatusPorStatusAtual(
        statusAtual: statusAtual,
        novoMeuStatus: novoMeuStatus,
      );

      await carregarChamados();

      if (widget.onChamadosAlterados != null) {
        await widget.onChamadosAlterados!();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Meu Status atualizado para "$novoMeuStatus" em $linhas chamados com Status Atual "$statusAtual".',
          ),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao sincronizar Meu Status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> abrirDialogSincronizacao() async {
    final statusDisponiveis = statusAtuaisDisponiveis;

    if (statusDisponiveis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum Status Atual disponível para sincronização.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String statusAtualSelecionado = statusDisponiveis.first;
    String meuStatusDestinoSelecionado = 'Em análise';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: const Text('Sincronizar Status Atual'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDropdownField(
                      label: 'De (Status Atual importado)',
                      value: statusAtualSelecionado,
                      items: statusDisponiveis,
                      onChanged: (value) {
                        dialogSetState(() {
                          statusAtualSelecionado = value ?? statusDisponiveis.first;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Para (Meu Status)',
                      value: meuStatusDestinoSelecionado,
                      items: meusStatus,
                      onChanged: (value) {
                        dialogSetState(() {
                          meuStatusDestinoSelecionado = value ?? 'Em análise';
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();

                    await sincronizarMeuStatusPorStatusAtual(
                      statusAtual: statusAtualSelecionado,
                      novoMeuStatus: meuStatusDestinoSelecionado,
                    );
                  },
                  icon: const Icon(Icons.sync),
                  label: const Text('Sincronizar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void carregarChamadoParaEdicao(Chamado chamado) {
    numeroChamadoController.text = chamado.ticket;
    clienteController.text = chamado.cliente;
    assuntoController.text = chamado.assunto;
    descricaoController.text = chamado.descricao;
    prazoController.text = chamado.prazoEntrega;
    roController.text = chamado.numeroRo;
    statusController.text = chamado.status;

    dataAtualizacaoController.clear();
    anotacoesController.clear();

    final tiposSolicitacaoValidos = [
      'Correção',
      'Melhoria',
      'Novo Programa',
      'Ajuste Operacional',
    ];

    final tiposLiberacaoValidos = [
      'Sprint',
      'Plantão',
    ];

    final tipoSolicitacaoNormalizado =
    tiposSolicitacaoValidos.contains(chamado.categoria)
        ? chamado.categoria
        : 'Melhoria';

    final meuStatusNormalizado = _normalizarMeuStatus(chamado.meuStatus);

    final statusChamadoNormalizado = [
      'Aberto',
      'Fechado',
    ].contains(chamado.status)
        ? chamado.status
        : 'Aberto';

    final tipoLiberacaoNormalizado = tiposLiberacaoValidos.contains(tipoLiberacao)
        ? tipoLiberacao
        : 'Sprint';

    setState(() {
      tipoSolicitacao = tipoSolicitacaoNormalizado;
      statusChamado = statusChamadoNormalizado;
      tipoLiberacao = tipoLiberacaoNormalizado;
      meuStatusSelecionado = meuStatusNormalizado;
      chamadoSelecionado = chamado;
    });
  }

  Future salvarAlteracoesChamadoSelecionado() async {
    if (chamadoSelecionado == null) return;

    final textoNovaAtualizacao = anotacoesController.text.trim();
    final historicoAtual = chamadoSelecionado!.anotacoes.trim();
    final dataInformada = dataAtualizacaoController.text.trim();

    final agora = DateTime.now();
    final horaAtual =
        '${agora.hour.toString().padLeft(2, '0')}:'
        '${agora.minute.toString().padLeft(2, '0')}';

    final dataAtualizacao = dataInformada.isNotEmpty
        ? dataInformada
        : '${agora.day.toString().padLeft(2, '0')}/'
        '${agora.month.toString().padLeft(2, '0')}/'
        '${agora.year}';

    final dataHoraAtualizacao = '$dataAtualizacao $horaAtual';

    final novoHistorico = textoNovaAtualizacao.isEmpty
        ? historicoAtual
        : historicoAtual.isEmpty
        ? '[$dataHoraAtualizacao] [$meuStatusSelecionado] $textoNovaAtualizacao'
        : '$historicoAtual\n[$dataHoraAtualizacao] [$meuStatusSelecionado] $textoNovaAtualizacao';

    final chamadoAtualizado = chamadoSelecionado!.copyWith(
      ticket: numeroChamadoController.text.trim(),
      cliente: clienteController.text.trim(),
      assunto: assuntoController.text.trim(),
      descricao: descricaoController.text.trim(),
      numeroRo: roController.text.trim(),
      categoria: tipoSolicitacao,
      status: statusChamado,
      prazoEntrega: prazoController.text.trim(),
      anotacoes: novoHistorico,
      meuStatus: meuStatusSelecionado,
      ultimaAtualizacao: dataHoraAtualizacao,
    );

    try {
      await chamadoRepository.atualizarChamado(chamadoAtualizado);
      await carregarChamados();

      if (widget.onChamadosAlterados != null) {
        await widget.onChamadosAlterados!();
      }

      anotacoesController.clear();
      dataAtualizacaoController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chamado atualizado com sucesso!'),
          backgroundColor: Color(0xFF059669),
        ),
      );

      setState(() {
        chamadoSelecionado = chamadoAtualizado;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar chamado: $e')),
      );
    }
  }

  Future<void> excluirChamadoSelecionado() async {
    if (chamadoSelecionado == null) return;

    final ticket = chamadoSelecionado!.ticket;

    try {
      await chamadoRepository.excluirChamado(ticket);

      await carregarChamados();

      if (widget.onChamadosAlterados != null) {
        await widget.onChamadosAlterados!();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chamado $ticket excluído com sucesso!'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );

      _resetFormularioNovoChamado();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir chamado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> salvarChamado() async {
    if (!_formKey.currentState!.validate()) return;

    final agora = DateTime.now();
    final dataHoje =
        '${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year}';
    final dataHoraAgora =
        '${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year} '
        '${agora.hour.toString().padLeft(2, '0')}:${agora.minute.toString().padLeft(2, '0')}';

    final novoChamado = Chamado(
      ticket: numeroChamadoController.text.trim(),
      cliente: clienteController.text.trim(),
      solicitante: '',
      assunto: assuntoController.text.trim(),
      descricao: descricaoController.text.trim(),
      numeroRo: roController.text.trim(),
      categoria: tipoSolicitacao,
      status: statusChamado,
      servico: '',
      dataAbertura: dataHoje,
      prazoEntrega: prazoController.text.trim(),
      ultimaAtualizacao: dataHoraAgora,
      agenteAtual: '',
      equipeAtual: '',
      anotacoes: anotacoesController.text.trim(),
      meuStatus: meuStatusSelecionado,
      anexos: const [],
    );

    try {
      await chamadoRepository.inserirChamado(novoChamado);
      await carregarChamados();
      if (widget.onChamadosAlterados != null) {
        await widget.onChamadosAlterados!();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chamado salvo com sucesso!'),
          backgroundColor: Color(0xFF059669),
        ),
      );

      numeroChamadoController.clear();
      clienteController.clear();
      assuntoController.clear();
      descricaoController.clear();
      prazoController.clear();
      anotacoesController.clear();
      statusController.clear();

      setState(() {
        tipoSolicitacao = 'Melhoria';
        statusChamado = 'Aberto';
        tipoLiberacao = 'Sprint';
        meuStatusSelecionado = 'Em análise';
        chamadoSelecionado = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar chamado: $e')),
      );
    }
  }

  Future<void> selecionarAnexos() async {
    final resultado = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (resultado == null || resultado.files.isEmpty) return;
    if (chamadoSelecionado == null) return;

    final nomesArquivos = resultado.files
        .map((arquivo) => arquivo.name)
        .where((nome) => nome.trim().isNotEmpty)
        .toList();

    final anexosAtualizados = [
      ...chamadoSelecionado!.anexos,
      ...nomesArquivos,
    ];

    final chamadoAtualizado = chamadoSelecionado!.copyWith(
      anexos: anexosAtualizados,
    );

    try {
      await chamadoRepository.atualizarChamado(chamadoAtualizado);

      await carregarChamados();

      if (widget.onChamadosAlterados != null) {
        await widget.onChamadosAlterados!();
      }

      setState(() {
        chamadoSelecionado = chamadoAtualizado;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${nomesArquivos.length} anexos adicionados.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Erro ao adicionar anexos: $e'),
        ),
      );
    }
  }


  Future<void> carregarChamados() async {
    try {
      final chamadosCarregados = await chamadoRepository.listarChamados();

      setState(() {
        chamados = chamadosCarregados;
        chamadoSelecionado =
        chamados.isNotEmpty ? chamados.first : null;
      });

      aplicarFiltros();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar chamados: $e')),
      );
    }
  }


  @override
  void initState() {
    super.initState();

    chamadosFiltrados = List.from(chamados);

    Future.microtask(() => carregarChamados());
  }

  void aplicarFiltros() {
    final filtroChamado = filtroChamadoController.text.trim().toLowerCase();
    final filtroCliente = filtroClienteController.text.trim().toLowerCase();
    final filtroAssunto = filtroAssuntoController.text.trim().toLowerCase();
    final filtroRo = filtroRoController.text.trim().toLowerCase();

    final lista = chamados.where((chamado) {
      final matchChamado =
          filtroChamado.isEmpty || chamado.ticket.toLowerCase().contains(filtroChamado);

      final matchCliente =
          filtroCliente.isEmpty || chamado.cliente.toLowerCase().contains(filtroCliente);

      final matchAssunto =
          filtroAssunto.isEmpty || chamado.assunto.toLowerCase().contains(filtroAssunto);

      final matchRo = filtroRo.isEmpty ||
          chamado.numeroRo.toLowerCase().contains(filtroRo);

      final matchTipo =
          filtroTipoSolicitacao == 'Todos' || chamado.categoria == filtroTipoSolicitacao;

      final meuStatusAtual =
      _normalizarMeuStatus(chamado.meuStatus).trim().toLowerCase();

      final filtroStatusAtual = filtroStatus.trim().toLowerCase();

      final matchStatus = filtroStatus == 'Todos'
          ? meuStatusAtual != 'fechado'
          : meuStatusAtual == filtroStatusAtual;

      final dataAbertura = parseDataAbertura(chamado.dataAbertura);

      final matchPeriodo = filtroPeriodoAbertura == null ||
          (dataAbertura != null &&
              !dataAbertura.isBefore(DateTime(
                filtroPeriodoAbertura!.start.year,
                filtroPeriodoAbertura!.start.month,
                filtroPeriodoAbertura!.start.day,
              )) &&
              !dataAbertura.isAfter(DateTime(
                filtroPeriodoAbertura!.end.year,
                filtroPeriodoAbertura!.end.month,
                filtroPeriodoAbertura!.end.day,
              )));

      return matchChamado &&
          matchCliente &&
          matchAssunto &&
          matchRo &&
          matchTipo &&
          matchStatus &&
          matchPeriodo;
    }).toList();

    setState(() {
      chamadosFiltrados = lista;
    });
  }

  DateTime? parseDataAbertura(String valor) {
    try {
      final texto = valor.trim();

      if (texto.isEmpty) return null;

      final partes = texto.split('/');
      if (partes.length != 3) return null;

      final dia = int.parse(partes[0]);
      final mes = int.parse(partes[1]);
      final ano = int.parse(partes[2]);

      return DateTime(ano, mes, dia);
    } catch (_) {
      return null;
    }
  }

  List<Map<String, String>> _montarDadosRelatorioChamados() {
    String limparTextoPdf(
        String valor, {
          int maximo = 0,
        }) {
      var texto = valor.trim();

      texto = texto
          .replaceAll('–', '-')
          .replaceAll('—', '-')
          .replaceAll('•', '-')
          .replaceAll('\r\n', ' ')
          .replaceAll('\n', ' ')
          .replaceAll('\r', ' ')
          .replaceAll('\t', ' ');

      texto = texto.replaceAll(RegExp(r'\s+'), ' ');

      if (maximo > 0 && texto.length > maximo) {
        texto = '${texto.substring(0, maximo)}...';
      }

      return texto;
    }

    return chamadosFiltrados.map((chamado) {
      return {
        'cliente': limparTextoPdf(chamado.cliente),
        'numeroChamado': limparTextoPdf(chamado.ticket),
        'numeroRo': limparTextoPdf(chamado.numeroRo),
        'assunto': limparTextoPdf(chamado.assunto, maximo: 80),
        'meuStatus': limparTextoPdf(_normalizarMeuStatus(chamado.meuStatus)),
        'statusAtual': limparTextoPdf(chamado.status),
        'abertura': limparTextoPdf(chamado.dataAbertura),
        'prazoEntrega': limparTextoPdf(chamado.prazoEntrega),
        'descricao': limparTextoPdf(chamado.descricao, maximo: 140),
        'anotacoes': limparTextoPdf(chamado.anotacoes, maximo: 140),
      };
    }).toList();
  }



  Future<String?> _selecionarCaminhoSalvarArquivo({
    required String nomeArquivo,
    required String extensao,
  }) async {
    final local = await getSaveLocation(
      suggestedName: nomeArquivo,
      acceptedTypeGroups: [
        XTypeGroup(
          label: extensao.toUpperCase(),
          extensions: [extensao],
        ),
      ],
    );

    return local?.path;
  }

  Future<File?> _exportarChamadosExcel() async {
    final dados = _montarDadosRelatorioChamados();

    final workbook = excel.Excel.createExcel();
    final sheet = workbook['Status Chamados'];

    sheet.appendRow([
      excel.TextCellValue('Cliente'),
      excel.TextCellValue('Número do chamado'),
      excel.TextCellValue('Número da RO'),
      excel.TextCellValue('Assunto'),
      excel.TextCellValue('Meu Status'),
      excel.TextCellValue('Status Atual'),
      excel.TextCellValue('Abertura'),
      excel.TextCellValue('Prazo de Entrega'),
      excel.TextCellValue('Descrição'),
      excel.TextCellValue('Minhas Anotações'),
    ]);

    for (final linha in dados) {
      sheet.appendRow([
        excel.TextCellValue(linha['cliente'] ?? ''),
        excel.TextCellValue(linha['numeroChamado'] ?? ''),
        excel.TextCellValue(linha['numeroRo'] ?? ''),
        excel.TextCellValue(linha['assunto'] ?? ''),
        excel.TextCellValue(linha['meuStatus'] ?? ''),
        excel.TextCellValue(linha['statusAtual'] ?? ''),
        excel.TextCellValue(linha['abertura'] ?? ''),
        excel.TextCellValue(linha['prazoEntrega'] ?? ''),
        excel.TextCellValue(linha['descricao'] ?? ''),
        excel.TextCellValue(linha['anotacoes'] ?? ''),
      ]);
    }

    final caminho = await _selecionarCaminhoSalvarArquivo(
      nomeArquivo:
      'status_chamados_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      extensao: 'xlsx',
    );

    if (caminho == null || caminho.trim().isEmpty) {
      return null;
    }

    final bytes = workbook.encode();
    if (bytes == null) {
      throw Exception('Não foi possível gerar o arquivo Excel.');
    }

    final arquivo = File(caminho)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes);

    return arquivo;
  }

  Future<File?> _gerarChamadosPdf() async {
    final dados = _montarDadosRelatorioChamados();
    final logoBytes = await rootBundle.load('assets/imagens/EnterDoc.png');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(vertical: 10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Image(logo, height: 42),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Status Chamados',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey900,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Relatório gerado em ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 18),
            pw.TableHelper.fromTextArray(
              headers: const [
                'Cliente',
                'Número do chamado',
                'Número da RO',
                'Assunto',
                'Meu Status',
                'Status Atual',
                'Abertura',
                'Prazo de Entrega',
                'Descrição',
                'Minhas Anotações',
              ],
              data: dados
                  .map(
                    (linha) => [
                  linha['cliente'] ?? '',
                  linha['numeroChamado'] ?? '',
                  linha['numeroRo'] ?? '',
                  linha['assunto'] ?? '',
                  linha['meuStatus'] ?? '',
                  linha['statusAtual'] ?? '',
                  linha['abertura'] ?? '',
                  linha['prazoEntrega'] ?? '',
                  linha['descricao'] ?? '',
                  linha['anotacoes'] ?? '',
                ],
              )
                  .toList(),
              border: pw.TableBorder.all(
                color: PdfColors.grey300,
                width: 0.6,
              ),
              headerStyle: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF0F766E),
              ),
              cellStyle: const pw.TextStyle(
                fontSize: 8,
                color: PdfColors.black,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: const pw.FlexColumnWidth(1.4),
                1: const pw.FlexColumnWidth(1.1),
                2: const pw.FlexColumnWidth(1.0),
                3: const pw.FlexColumnWidth(1.4),
                4: const pw.FlexColumnWidth(1.0),
                5: const pw.FlexColumnWidth(1.0),
                6: const pw.FlexColumnWidth(0.9),
                7: const pw.FlexColumnWidth(1.0),
                8: const pw.FlexColumnWidth(1.6),
                9: const pw.FlexColumnWidth(1.6),
              },
            ),
          ];
        },
      ),
    );

    final caminho = await _selecionarCaminhoSalvarArquivo(
      nomeArquivo:
      'status_chamados_${DateTime.now().millisecondsSinceEpoch}.pdf',
      extensao: 'pdf',
    );

    if (caminho == null || caminho.trim().isEmpty) {
      return null;
    }

    final arquivo = File(caminho);
    await arquivo.writeAsBytes(await pdf.save());

    return arquivo;
  }

  Future<void> selecionarPeriodoAbertura() async {
    final intervalo = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      initialDateRange: filtroPeriodoAbertura,
      helpText: 'Selecionar período de abertura',
      fieldStartLabelText: 'De',
      fieldEndLabelText: 'Até',
      locale: const Locale('pt', 'BR'),
      initialEntryMode: DatePickerEntryMode.input,
      switchToCalendarEntryModeIcon: const Icon(Icons.calendar_month),
      switchToInputEntryModeIcon: const Icon(Icons.edit_outlined),
    );

    if (intervalo == null) return;

    setState(() {
      filtroPeriodoAbertura = intervalo;
    });

    aplicarFiltros();
  }

  Future<void> _abrirNovoChamadoDialog() async {
    _resetFormularioNovoChamado();

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                width: 960,
                constraints: const BoxConstraints(
                  maxWidth: 960,
                  maxHeight: 780,
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.add_task,
                              color: Color(0xFF166534),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Novo chamado',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Preencha os dados para cadastrar um novo chamado.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _StatusBadge(label: statusChamado),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: numeroChamadoController,
                                      label: 'Número do chamado',
                                      hint: 'Ex: CH-2026-003',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: clienteController,
                                      label: 'Cliente',
                                      hint: 'Nome do cliente',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: assuntoController,
                                      label: 'Assunto',
                                      hint: 'Descreva o assunto',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDropdownField(
                                      label: 'Tipo da solicitação',
                                      value: tipoSolicitacao,
                                      items: const [
                                        'Correção',
                                        'Melhoria',
                                        'Novo Programa',
                                        'Ajuste Operacional',
                                      ],
                                      onChanged: (value) {
                                        dialogSetState(() {
                                          tipoSolicitacao = value!;
                                        });
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              _buildTextField(
                                controller: descricaoController,
                                label: 'Descrição',
                                hint: 'Descreva a necessidade, regra, problema ou melhoria',
                                maxLines: 4,
                                required: false,
                              ),
                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: prazoController,
                                      label: 'Prazo de entrega',
                                      hint: 'Ex: 15/04/2026',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: roController,
                                      label: 'Número da RO',
                                      hint: 'Ex: RO-4587',
                                      required: false,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDropdownField(
                                      label: 'Status do chamado',
                                      value: statusChamado,
                                      items: const [
                                        'Aberto',
                                        'Fechado',
                                      ],
                                      onChanged: (value) {
                                        dialogSetState(() {
                                          statusChamado = value ?? 'Aberto';
                                          statusController.text = statusChamado;
                                        });
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDropdownField(
                                      label: 'Tipo de liberação',
                                      value: tipoLiberacao,
                                      items: const [
                                        'Sprint',
                                        'Direta',
                                        'Aguardando definição',
                                      ],
                                      onChanged: (value) {
                                        dialogSetState(() {
                                          tipoLiberacao = value ?? 'Sprint';
                                        });
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              _buildDropdownField(
                                label: 'Meu status',
                                value: meusStatus.contains(meuStatusSelecionado)
                                    ? meuStatusSelecionado
                                    : 'Em análise',
                                items: meusStatus,
                                onChanged: (value) {
                                  dialogSetState(() {
                                    meuStatusSelecionado = value ?? 'Em análise';
                                  });
                                  setState(() {});
                                },
                              ),
                              const SizedBox(height: 16),

                              _buildTextField(
                                controller: anotacoesController,
                                label: 'Primeira atualização do chamado',
                                hint: 'Digite uma atualização curta para iniciar o histórico do chamado',
                                maxLines: 3,
                                required: false,
                              ),
                              const SizedBox(height: 20),

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.attach_file, color: Color(0xFF6B7280)),
                                        SizedBox(width: 8),
                                        Text(
                                          'Anexos',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF374151),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Os anexos poderão ser adicionados após salvar o chamado.',
                                      style: TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
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
                            onPressed: () {
                              _resetFormularioNovoChamado();
                              Navigator.of(dialogContext).pop();
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              _resetFormularioNovoChamado();
                              dialogSetState(() {});
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Limpar'),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await salvarChamado();
                              if (!mounted) return;

                              final semErros =
                                  numeroChamadoController.text.isEmpty &&
                                      clienteController.text.isEmpty &&
                                      assuntoController.text.isEmpty;

                              if (semErros) {
                                Navigator.of(dialogContext).pop();
                              }
                            },
                            icon: const Icon(Icons.save),
                            label: const Text('Salvar chamado'),
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
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _resetFormularioNovoChamado() {
    numeroChamadoController.clear();
    clienteController.clear();
    assuntoController.clear();
    descricaoController.clear();
    prazoController.clear();
    roController.clear();
    anotacoesController.clear();
    dataAtualizacaoController.clear();
    statusController.clear();

    setState(() {
      chamadoSelecionado = null;
      tipoSolicitacao = 'Melhoria';
      statusChamado = 'Aberto';
      tipoLiberacao = 'Sprint';
      meuStatusSelecionado = 'Em análise';
      statusController.text = statusChamado;
    });
  }

  void limparFiltros() {
    filtroChamadoController.clear();
    filtroRoController.clear();
    filtroClienteController.clear();
    filtroAssuntoController.clear();

    setState(() {
      filtroTipoSolicitacao = 'Todos';
      filtroStatus = 'Todos';
      filtroPeriodoAbertura = null;
    });

    aplicarFiltros();
  }

  Future<void> _acaoExportarExcel() async {
    try {
      final arquivo = await _exportarChamadosExcel();

      if (arquivo == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exportação do Excel cancelada.'),
          ),
        );
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel salvo com sucesso em:\n${arquivo.path}'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao exportar Excel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _acaoExportarPdf() async {
    try {
      final arquivo = await _gerarChamadosPdf();

      if (arquivo == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exportação do PDF cancelada.'),
          ),
        );
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF salvo com sucesso em:\n${arquivo.path}'),
          backgroundColor: const Color(0xFF0F766E),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao exportar PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String textoPeriodoAbertura() {
    if (filtroPeriodoAbertura == null) {
      return 'Período de abertura';
    }

    final inicio = filtroPeriodoAbertura!.start;
    final fim = filtroPeriodoAbertura!.end;

    final inicioTexto =
        '${inicio.day.toString().padLeft(2, '0')}/${inicio.month.toString().padLeft(2, '0')}/${inicio.year}';

    final fimTexto =
        '${fim.day.toString().padLeft(2, '0')}/${fim.month.toString().padLeft(2, '0')}/${fim.year}';

    return '$inicioTexto até $fimTexto';
  }

  double larguraColunaAjustada(String chave, double larguraDisponivel) {
    final larguraBase =
    largurasChamados.values.fold<double>(0, (total, item) => total + item);

    if (larguraBase >= larguraDisponivel) {
      return largurasChamados[chave]!;
    }

    final proporcao = largurasChamados[chave]! / larguraBase;
    return larguraDisponivel * proporcao;
  }

  Widget buildCabecalhoColunaChamado(
      String chave,
      String titulo,
      double larguraDisponivel,
      ) {
    return SizedBox(
      width: larguraColunaAjustada(chave, larguraDisponivel),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Expanded(
              child: Text(
                titulo,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                  fontSize: 12,
                ),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    final atual = largurasChamados[chave]!;
                    final nova = (atual + details.delta.dx).clamp(80.0, 420.0);
                    largurasChamados[chave] = nova;
                  });
                },
                child: Container(
                  width: 10,
                  height: 28,
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 2,
                    height: 18,
                    color: const Color(0xFFD1D5DB),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChamadoLinha(Chamado chamado, double larguraDisponivel) {
    final selecionado = chamadoSelecionado?.ticket == chamado.ticket;

    return InkWell(
      onTap: () {
        carregarChamadoParaEdicao(chamado);
        _abrirDetalhesChamado(chamado);
      },
      child: Container(
        color: selecionado ? const Color(0xFFE0F2FE) : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: larguraColunaAjustada('chamado', larguraDisponivel),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  chamado.ticket,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: larguraColunaAjustada('cliente', larguraDisponivel),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  chamado.cliente,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: larguraColunaAjustada('assunto', larguraDisponivel),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  chamado.assunto,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: larguraColunaAjustada('meuStatus', larguraDisponivel),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  chamado.meuStatus,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0369A1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: larguraColunaAjustada('statusAtual', larguraDisponivel),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusBadge(label: chamado.status),
                ),
              ),
            ),
            SizedBox(
              width: larguraColunaAjustada('abertura', larguraDisponivel),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  chamado.dataAbertura,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chamados M&O',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cadastro, acompanhamento, testes, RO e entrega de chamados.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _abrirNovoChamadoDialog,
              icon: const Icon(Icons.add),
              label: const Text('Novo chamado'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF12324A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: abrirDialogSincronizacao,
              icon: const Icon(Icons.sync),
              label: const Text('Sincronizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B5563),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: importarChamadosCsv,
              icon: const Icon(Icons.upload_file),
              label: const Text('Importar CSV'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildFiltrosTopo(),
        const SizedBox(height: 20),

        Expanded(
          child: buildGridChamados(),
        ),
      ],
    );
  }

  Widget _buildFiltrosTopo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: filtroChamadoController,
                  onChanged: (_) => aplicarFiltros(),
                  decoration: buildFiltroDecoration(
                    label: 'Chamado',
                    hint: 'Número do chamado',
                    icon: Icons.search,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: filtroClienteController,
                  onChanged: (_) => aplicarFiltros(),
                  decoration: buildFiltroDecoration(
                    label: 'Cliente',
                    hint: 'Nome do cliente',
                    icon: Icons.search,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: filtroAssuntoController,
                  onChanged: (_) => aplicarFiltros(),
                  decoration: buildFiltroDecoration(
                    label: 'Assunto',
                    hint: 'Palavras do assunto',
                    icon: Icons.search,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: filtroRoController,
                  onChanged: (_) => aplicarFiltros(),
                  decoration: buildFiltroDecoration(
                    label: 'RO',
                    hint: 'Número da RO',
                    icon: Icons.search,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: limparFiltros,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Limpar filtros'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _acaoExportarExcel,
                icon: const Icon(Icons.table_view_outlined, size: 18),
                label: const Text('Excel'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  foregroundColor: const Color(0xFF166534),
                  side: const BorderSide(color: Color(0xFF86EFAC)),
                  backgroundColor: const Color(0xFFF0FDF4),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _acaoExportarPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: const Text('PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildGridChamados() {
    if (chamadosFiltrados.isEmpty) {
      return Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Nenhum chamado cadastrado.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
          ),
        ),
      );
    }

    final larguraTotal =
    largurasChamados.values.fold<double>(0, (total, item) => total + item);

    return LayoutBuilder(
      builder: (context, constraints) {
        final larguraColunas =
        largurasChamados.values.fold<double>(0, (total, item) => total + item);

        final larguraTabela = larguraColunas < constraints.maxWidth
            ? constraints.maxWidth
            : larguraColunas;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: larguraTabela,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        buildCabecalhoColunaChamado('chamado', 'Chamado', larguraTabela),
                        buildCabecalhoColunaChamado('cliente', 'Cliente', larguraTabela),
                        buildCabecalhoColunaChamado('assunto', 'Assunto', larguraTabela),
                        buildCabecalhoColunaChamado('meuStatus', 'Meu Status', larguraTabela),
                        buildCabecalhoColunaChamado('statusAtual', 'Status Atual', larguraTabela),
                        buildCabecalhoColunaChamado('abertura', 'Abertura', larguraTabela),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: larguraTabela,
                    child: ListView.separated(
                      itemCount: chamadosFiltrados.length,
                      separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        final chamado = chamadosFiltrados[index];
                        return buildChamadoLinha(chamado, larguraTabela);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    bool required = true,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      validator: required
          ? (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Campo obrigatório';
        }
        return null;
      }
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B7280),
        ),
        alignLabelWithHint: maxLines > 1,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        isDense: true,
        contentPadding: EdgeInsets.fromLTRB(
          14,
          maxLines > 1 ? 18 : 20,
          14,
          14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF0F766E),
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        ),
      )
          .toList(),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.4),
        ),
      ),
    );
  }
}

InputDecoration buildFiltroDecoration({
  required String label,
  IconData? icon,
  String? hint,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF9FAFB),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 14,
    ),
    prefixIcon: icon != null ? Icon(icon, size: 18) : null,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: Color(0xFF0F766E),
        width: 1.4,
      ),
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final String label;

  const _StatusBadge({required this.label});

  Color get backgroundColor {
    switch (label) {
      case 'Aberto':
        return const Color(0xFFDBEAFE);
      case 'Em desenvolvimento':
        return const Color(0xFFEDE9FE);
      case 'Em teste':
        return const Color(0xFFFEF3C7);
      case 'Liberado':
      case 'Entregue':
        return const Color(0xFFD1FAE5);
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  Color get textColor {
    switch (label) {
      case 'Aberto':
        return const Color(0xFF1D4ED8);
      case 'Em desenvolvimento':
        return const Color(0xFF6D28D9);
      case 'Em teste':
        return const Color(0xFFB45309);
      case 'Liberado':
      case 'Entregue':
        return const Color(0xFF047857);
      default:
        return const Color(0xFF4B5563);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}