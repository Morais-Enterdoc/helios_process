import 'dart:io';

import 'package:flutter/material.dart';

import '../../clientes/data/cliente_repository.dart';
import '../../clientes/domain/cliente.dart';
import '../data/tarefa_repository.dart';
import '../domain/tarefa.dart';
import '../domain/tarefa_detalhe.dart';
import '../../cronograma/data/cronograma_repository.dart';
import '../../cronograma/domain/cronograma_models.dart';
import '../../chamados/data/chamado_repository.dart';
import '../../chamados/domain/chamado.dart';

class TarefasPage extends StatefulWidget {
  final Future<void> Function()? onTarefasAlteradas;

  const TarefasPage({
    super.key,
    this.onTarefasAlteradas,
  });

  @override
  State<TarefasPage> createState() => _TarefasPageState();
}

class _TarefasPageState extends State<TarefasPage> {
  final TarefaRepository tarefaRepository = TarefaRepository();
  final ClienteRepository clienteRepository = ClienteRepository();
  final CronogramaRepository cronogramaRepository = CronogramaRepository();
  final ChamadoRepository chamadoRepository = ChamadoRepository();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController tituloController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController dataController = TextEditingController();
  final TextEditingController horaInicioController = TextEditingController();
  final TextEditingController horaFimController = TextEditingController();
  final TextEditingController observacoesController = TextEditingController();
  final TextEditingController projetoRefController = TextEditingController();
  final TextEditingController chamadoRefController = TextEditingController();
  final TextEditingController filtroTituloController = TextEditingController();
  final TextEditingController filtroDataController = TextEditingController();

  List tarefas = [];
  List tarefasFiltradas = [];
  List clientes = [];
  List cronogramas = [];
  List<Chamado> chamados = [];

  Cliente? clienteSelecionado;
  TarefaDetalhe? tarefaSelecionada;
  String origemTipoSelecionada = 'geral';
  CronogramaProjeto? cronogramaSelecionado;
  Chamado? chamadoSelecionado;
  List<CronogramaProjeto> get cronogramasAtivos {
    return cronogramas.whereType<CronogramaProjeto>().where((projeto) {
      final status = (projeto.status ?? '').trim().toLowerCase();
      return status.isEmpty ||
          (status != 'fechado' &&
              status != 'fechada' &&
              status != 'concluído' &&
              status != 'concluída' &&
              status != 'concluido' &&
              status != 'concluida' &&
              status != 'cancelado' &&
              status != 'cancelada');
    }).toList();
  }

  List<Chamado> get chamadosAtivos {
    return chamados.whereType<Chamado>().where((chamado) {
      final status = (chamado.meuStatus.isNotEmpty
          ? chamado.meuStatus
          : chamado.status)
          .trim()
          .toLowerCase();

      return status.isEmpty ||
          (status != 'fechado' &&
              status != 'fechada' &&
              status != 'concluído' &&
              status != 'concluída' &&
              status != 'concluido' &&
              status != 'concluida' &&
              status != 'cancelado' &&
              status != 'cancelada');
    }).toList();
  }

  String _normalizarTipoVinculoTarefa(String? valor) {
    final tipo = (valor ?? '').trim().toLowerCase();
    if (tipo == 'geral') return 'geral';
    if (tipo == 'cronograma') return 'cronograma';
    if (tipo == 'projeto') return 'cronograma';
    if (tipo == 'chamado') return 'chamado';
    return 'geral';
  }
  String filtroStatus = 'Todos';



  final List<String> statusDisponiveis = const [
    'Planejada',
    'Em andamento',
    'Pausada',
    'Fechada',
  ];

  final Map<String, double> largurasTarefas = {
    'cliente': 220,
    'titulo': 380,
    'data': 110,
    'inicio': 80,
    'fim': 80,
    'status': 150,
    'tempo': 100,
    'origem': 100,
    'acoes': 110,
  };


  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  @override
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    dataController.dispose();
    horaInicioController.dispose();
    horaFimController.dispose();
    observacoesController.dispose();
    projetoRefController.dispose();
    chamadoRefController.dispose();
    filtroTituloController.dispose();
    filtroDataController.dispose();
    super.dispose();
  }

  Future carregarDados() async {
    await carregarClientes();
    await carregarCronogramas();
    await carregarChamados();
    await carregarTarefas();
  }

  Future<void> carregarClientes() async {
    try {
      final lista = await clienteRepository.listarClientes();
      if (!mounted) return;
      setState(() {
        clientes = lista;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar clientes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future carregarCronogramas() async {
    try {
      final lista = await cronogramaRepository.listarCronogramas();
      if (!mounted) return;
      setState(() {
        cronogramas = lista;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar cronogramas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future carregarChamados() async {
    try {
      final lista = await chamadoRepository.listarChamados();
      if (!mounted) return;
      setState(() {
        chamados = lista;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar chamados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> carregarTarefas() async {
    try {
      final lista = await tarefaRepository.listarTarefasComCliente();
      if (!mounted) return;
      setState(() {
        tarefas = lista;
        tarefasFiltradas = List.from(lista);
      });
      aplicarFiltros();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar tarefas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void aplicarFiltros() {
    final titulo = filtroTituloController.text.trim().toLowerCase();
    final data = filtroDataController.text.trim().toLowerCase();

    final lista = tarefas.where((item) {
      final tarefa = item.tarefa;

      final matchTitulo =
          titulo.isEmpty || tarefa.titulo.toLowerCase().contains(titulo);

      final matchData =
          data.isEmpty || tarefa.data.toLowerCase().contains(data);

      final matchStatus = filtroStatus == 'Todos'
          ? tarefa.status != 'Fechada'
          : tarefa.status == filtroStatus;

      return matchTitulo && matchData && matchStatus;
    }).toList();

    setState(() {
      tarefasFiltradas = lista;
    });
  }

  void limparFiltros() {
    filtroTituloController.clear();
    filtroDataController.clear();
    setState(() {
      filtroStatus = 'Todos';
    });
    aplicarFiltros();
  }

  void limparFormulario() {
    tituloController.clear();
    descricaoController.clear();
    dataController.clear();
    horaInicioController.clear();
    horaFimController.clear();
    observacoesController.clear();
    projetoRefController.clear();
    chamadoRefController.clear();
    origemTipoSelecionada = 'geral';
    clienteSelecionado = null;
    tarefaSelecionada = null;
    cronogramaSelecionado = null;
    chamadoSelecionado = null;
  }

  Future<void> abrirDialogNovaTarefa() async {
    limparFormulario();

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        String statusSelecionado = 'Planejada';
        String origemTipoDialog = 'geral';
        origemTipoSelecionada = origemTipoDialog;

        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return Dialog(
              insetPadding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
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
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.task_alt,
                              color: Color(0xFF166534),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nova tarefa',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Cadastre uma tarefa para planejamento e execução.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusTarefaBadge(label: statusSelecionado),
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
                                    child: DropdownButtonFormField<Cliente>(
                                      value: clienteSelecionado,
                                      decoration: buildInputDecoration(
                                        label: 'Cliente',
                                        hint: 'Selecione o cliente',
                                      ),
                                      items: clientes.map((cliente) {
                                        return DropdownMenuItem<Cliente>(
                                          value: cliente,
                                          child: Text(cliente.nome),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        dialogSetState(() {
                                          clienteSelecionado = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Selecione o cliente';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: buildTextField(
                                      controller: tituloController,
                                      label: 'Título',
                                      hint: 'Ex: Validar processo de faturamento',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              buildTextField(
                                controller: descricaoController,
                                label: 'Descrição',
                                hint: 'Descreva a atividade',
                                maxLines: 4,
                                required: false,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: buildTextField(
                                      controller: dataController,
                                      label: 'Data',
                                      hint: 'Ex: 25/04/2026',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: buildTextField(
                                      controller: horaInicioController,
                                      label: 'Hora início',
                                      hint: 'Ex: 08:00',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: buildTextField(
                                      controller: horaFimController,
                                      label: 'Hora fim',
                                      hint: 'Ex: 09:30',
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: origemTipoDialog,
                                      decoration: buildInputDecoration(
                                        label: 'Tipo de vínculo',
                                        hint: 'Selecione o vínculo',
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'geral',
                                          child: Text('Geral'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'cronograma',
                                          child: Text('Projeto'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'chamado',
                                          child: Text('Chamado'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        dialogSetState(() {
                                          origemTipoDialog = value ?? 'geral';
                                          origemTipoSelecionada = origemTipoDialog;
                                          cronogramaSelecionado = null;
                                          chamadoSelecionado = null;
                                          projetoRefController.clear();
                                          chamadoRefController.clear();
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 2,
                                    child: origemTipoDialog == 'geral'
                                        ? TextFormField(
                                      initialValue: 'Esta tarefa ficará apenas na tela de tarefas',
                                      readOnly: true,
                                      decoration: buildInputDecoration(
                                        label: 'Sem vínculo',
                                        hint: 'Esta tarefa ficará apenas na tela de tarefas',
                                      ),
                                    )
                                        : origemTipoDialog == 'cronograma'
                                        ? DropdownButtonFormField<CronogramaProjeto>(
                                      value: cronogramaSelecionado,
                                      decoration: buildInputDecoration(
                                        label: 'Projeto vinculado',
                                        hint: 'Selecione o projeto ativo',
                                      ),
                                      items: cronogramasAtivos.map((projeto) {
                                        return DropdownMenuItem<CronogramaProjeto>(
                                          value: projeto,
                                          child: Text(
                                            '${projeto.clienteNome} - ${projeto.nomeProjeto}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        dialogSetState(() {
                                          cronogramaSelecionado = value;
                                          chamadoSelecionado = null;
                                          projetoRefController.text = value?.nomeProjeto ?? '';
                                          chamadoRefController.clear();

                                          if (value != null) {
                                            Cliente? clienteEncontrado;

                                            for (final cliente in clientes.whereType<Cliente>()) {
                                              if (cliente.id == value.clienteId) {
                                                clienteEncontrado = cliente;
                                                break;
                                              }
                                            }

                                            if (clienteEncontrado != null) {
                                              clienteSelecionado = clienteEncontrado;
                                            }
                                          }
                                        });
                                      },
                                      validator: (value) {
                                        if (origemTipoDialog == 'cronograma' && value == null) {
                                          return 'Selecione o projeto';
                                        }
                                        return null;
                                      },
                                    )
                                        : DropdownButtonFormField<Chamado>(
                                      value: chamadoSelecionado,
                                      isExpanded: true,
                                      decoration: buildInputDecoration(
                                        label: 'Chamado vinculado',
                                        hint: 'Selecione o chamado ativo',
                                      ),
                                      items: chamadosAtivos.map((chamado) {
                                        final assuntoTexto = (chamado.assunto ?? '').trim();

                                        return DropdownMenuItem<Chamado>(
                                          value: chamado,
                                          child: Text(
                                            '${chamado.ticket} - ${chamado.cliente} - $assuntoTexto',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        dialogSetState(() {
                                          chamadoSelecionado = value;
                                          cronogramaSelecionado = null;
                                          chamadoRefController.text = value?.ticket ?? '';
                                          projetoRefController.clear();

                                          if (value != null) {
                                            Cliente? clienteEncontrado;

                                            for (final cliente in clientes.whereType<Cliente>()) {
                                              if (cliente.nome.trim().toLowerCase() ==
                                                  value.cliente.trim().toLowerCase()) {
                                                clienteEncontrado = cliente;
                                                break;
                                              }
                                            }

                                            if (clienteEncontrado != null) {
                                              clienteSelecionado = clienteEncontrado;
                                            }
                                          }
                                        });
                                      },
                                      validator: (value) {
                                        if (origemTipoDialog == 'chamado' && value == null) {
                                          return 'Selecione o chamado';
                                        }
                                        return null;
                                      },
                                    )
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: statusSelecionado,
                                      decoration: buildInputDecoration(
                                        label: 'Status',
                                        hint: 'Selecione o status',
                                      ),
                                      items: statusDisponiveis.map((status) {
                                        return DropdownMenuItem<String>(
                                          value: status,
                                          child: Text(status),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        dialogSetState(() {
                                          statusSelecionado =
                                              value ?? 'Planejada';
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: buildTextField(
                                      controller: observacoesController,
                                      label: 'Observações',
                                      hint: 'Anotações rápidas',
                                      required: false,
                                    ),
                                  ),
                                ],
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
                              limparFormulario();
                              Navigator.of(dialogContext).pop();
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              dialogSetState(() {
                                limparFormulario();
                                statusSelecionado = 'Planejada';
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Limpar'),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (!(formKey.currentState?.validate() ?? false)) return;

                              try {
                                final agora = DateTime.now().toIso8601String();

                                final tarefa = Tarefa(
                                  clienteId: clienteSelecionado!.id,
                                  origemTipo: origemTipoDialog == 'geral'
                                      ? null
                                      : origemTipoDialog,
                                  origemId: origemTipoDialog == 'cronograma'
                                      ? cronogramaSelecionado?.id
                                      : origemTipoDialog == 'chamado'
                                      ? chamadoSelecionado?.id
                                      : null,
                                  clienteNomeRef: origemTipoDialog == 'cronograma'
                                      ? (cronogramaSelecionado?.clienteNome ?? clienteSelecionado!.nome)
                                      : origemTipoDialog == 'chamado'
                                      ? (chamadoSelecionado?.cliente.isNotEmpty == true
                                      ? chamadoSelecionado!.cliente
                                      : clienteSelecionado!.nome)
                                      : clienteSelecionado!.nome,
                                  projetoRef: origemTipoDialog == 'cronograma'
                                      ? cronogramaSelecionado?.nomeProjeto
                                      : null,
                                  chamadoRef: origemTipoDialog == 'chamado'
                                      ? chamadoSelecionado?.ticket
                                      : null,
                                  titulo: tituloController.text.trim(),
                                  descricao: descricaoController.text.trim(),
                                  data: dataController.text.trim(),
                                  horaInicio: horaInicioController.text.trim(),
                                  horaFim: horaFimController.text.trim(),
                                  status: statusSelecionado,
                                  tempoAcumuladoSegundos: 0,
                                  iniciadaEm: null,
                                  encerradaEm: null,
                                  observacoes: observacoesController.text.trim(),
                                  sincronizadaAgendaExterna: false,
                                  origem: 'manual',
                                  eventoExternoId: null,
                                  cor: null,
                                  createdAt: agora,
                                  updatedAt: agora,
                                );

                                print('===== TAREFA ANTES DE SALVAR =====');
                                print(tarefa.toMap());
                                print('clienteSelecionado: ${clienteSelecionado?.id} - ${clienteSelecionado?.nome}');
                                print('origemTipoDialog: $origemTipoDialog');
                                print('cronogramaSelecionado: ${cronogramaSelecionado?.id} - ${cronogramaSelecionado?.nomeProjeto}');
                                print('chamadoSelecionado: ${chamadoSelecionado?.id} - ${chamadoSelecionado?.ticket}');
                                print('==================================');

                                await tarefaRepository.inserirTarefa(tarefa);
                                await carregarTarefas();

                                if (widget.onTarefasAlteradas != null) {
                                  await widget.onTarefasAlteradas!();
                                }

                                if (!mounted) return;

                                Navigator.of(dialogContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tarefa salva com sucesso!'),
                                    backgroundColor: Color(0xFF059669),
                                  ),
                                );
                              } catch (e, stackTrace) {
                                print('========== ERRO AO SALVAR TAREFA ==========');
                                print('Erro: $e');
                                print('StackTrace: $stackTrace');
                                print('clienteSelecionado: ${clienteSelecionado?.id} - ${clienteSelecionado?.nome}');
                                print('origemTipoDialog: $origemTipoDialog');
                                print('cronogramaSelecionado: ${cronogramaSelecionado?.id} - ${cronogramaSelecionado?.nomeProjeto}');
                                print('chamadoSelecionado: ${chamadoSelecionado?.id} - ${chamadoSelecionado?.ticket}');
                                print('titulo: ${tituloController.text}');
                                print('descricao: ${descricaoController.text}');
                                print('data: ${dataController.text}');
                                print('horaInicio: ${horaInicioController.text}');
                                print('horaFim: ${horaFimController.text}');
                                print('observacoes: ${observacoesController.text}');
                                print('===========================================');

                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erro ao salvar tarefa: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.save),
                            label: const Text('Salvar tarefa'),
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

  Future<void> abrirDialogEditarTarefa(TarefaDetalhe item) async {
    limparFormulario();

    tituloController.text = item.tarefa.titulo;
    descricaoController.text = item.tarefa.descricao;
    dataController.text = item.tarefa.data;
    horaInicioController.text = item.tarefa.horaInicio;
    horaFimController.text = item.tarefa.horaFim;
    observacoesController.text = item.tarefa.observacoes ?? '';
    projetoRefController.text = item.tarefa.projetoRef ?? '';
    chamadoRefController.text = item.tarefa.chamadoRef ?? '';
    origemTipoSelecionada = _normalizarTipoVinculoTarefa(item.tarefa.origemTipo);
    tarefaSelecionada = item;

    cronogramaSelecionado = null;

    if (item.tarefa.origemTipo == 'cronograma' && item.tarefa.origemId != null) {
      for (final projeto in cronogramas) {
        if (projeto.id == item.tarefa.origemId) {
          cronogramaSelecionado = projeto;
          break;
        }
      }
    }

    chamadoSelecionado = null;

    if (item.tarefa.origemTipo == 'chamado' &&
        item.tarefa.chamadoRef != null &&
        item.tarefa.chamadoRef!.trim().isNotEmpty) {
      for (final chamado in chamados) {
        if (chamado.ticket.trim() == item.tarefa.chamadoRef!.trim()) {
          chamadoSelecionado = chamado;
          break;
        }
      }
    }

    Cliente? clienteEncontrado;

    for (final cliente in clientes) {
      if (cliente.id == item.tarefa.clienteId) {
        clienteEncontrado = cliente;
        break;
      }
    }

    clienteSelecionado = clienteEncontrado;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        String statusSelecionado = item.tarefa.status;
        String origemTipoDialog = origemTipoSelecionada;

        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return Dialog(
              insetPadding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
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
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.edit_calendar_outlined,
                              color: Color(0xFF0369A1),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.tarefa.titulo,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Visualize e edite os detalhes da tarefa.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusTarefaBadge(label: statusSelecionado),
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
                                    child: DropdownButtonFormField<Cliente>(
                                      value: clienteSelecionado,
                                      decoration: buildInputDecoration(
                                        label: 'Cliente',
                                        hint: 'Selecione o cliente',
                                      ),
                                      items: clientes.map((cliente) {
                                        return DropdownMenuItem<Cliente>(
                                          value: cliente,
                                          child: Text(cliente.nome),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        dialogSetState(() {
                                          clienteSelecionado = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Selecione o cliente';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: buildTextField(
                                      controller: tituloController,
                                      label: 'Título',
                                      hint: 'Título da tarefa',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              buildTextField(
                                controller: descricaoController,
                                label: 'Descrição',
                                hint: 'Descreva a atividade',
                                maxLines: 4,
                                required: false,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: buildTextField(
                                      controller: dataController,
                                      label: 'Data',
                                      hint: 'Ex: 25/04/2026',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: buildTextField(
                                      controller: horaInicioController,
                                      label: 'Hora início',
                                      hint: 'Ex: 08:00',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: buildTextField(
                                      controller: horaFimController,
                                      label: 'Hora fim',
                                      hint: 'Ex: 09:30',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: origemTipoDialog,
                                      decoration: buildInputDecoration(
                                        label: 'Tipo de vínculo',
                                        hint: 'Selecione o vínculo',
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'geral',
                                          child: Text('Geral'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'cronograma',
                                          child: Text('Projeto'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'chamado',
                                          child: Text('Chamado'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        dialogSetState(() {
                                          origemTipoDialog = value ?? 'geral';
                                          origemTipoSelecionada = origemTipoDialog;
                                          cronogramaSelecionado = null;
                                          chamadoSelecionado = null;
                                          projetoRefController.clear();
                                          chamadoRefController.clear();
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 2,
                                    child: origemTipoDialog == 'geral'
                                        ? buildTextField(
                                      controller: projetoRefController,
                                      label: 'Sem vínculo',
                                      hint: 'Esta tarefa ficará apenas na tela de tarefas',
                                      required: false,
                                    )
                                        : origemTipoDialog == 'cronograma'
                                        ? DropdownButtonFormField<CronogramaProjeto>(
                                      value: cronogramaSelecionado,
                                      decoration: buildInputDecoration(
                                        label: 'Projeto vinculado',
                                        hint: 'Selecione o projeto ativo',
                                      ),
                                      items: cronogramasAtivos.map((projeto) {
                                        return DropdownMenuItem<CronogramaProjeto>(
                                          value: projeto,
                                          child: Text(
                                            '${projeto.clienteNome} - ${projeto.nomeProjeto}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        dialogSetState(() {
                                          cronogramaSelecionado = value;
                                          chamadoSelecionado = null;
                                          projetoRefController.text = value?.nomeProjeto ?? '';
                                          chamadoRefController.clear();

                                          if (value != null) {
                                            Cliente? clienteEncontrado;

                                            for (final cliente in clientes.whereType<Cliente>()) {
                                              if (cliente.id == value.clienteId) {
                                                clienteEncontrado = cliente;
                                                break;
                                              }
                                            }

                                            if (clienteEncontrado != null) {
                                              clienteSelecionado = clienteEncontrado;
                                            }
                                          }
                                        });
                                      },
                                      validator: (value) {
                                        if (origemTipoDialog == 'cronograma' && value == null) {
                                          return 'Selecione o projeto';
                                        }
                                        return null;
                                      },
                                    )
                                        : DropdownButtonFormField<Chamado>(
                                      value: chamadoSelecionado,
                                      decoration: buildInputDecoration(
                                        label: 'Chamado vinculado',
                                        hint: 'Selecione o chamado ativo',
                                      ),
                                      items: chamadosAtivos.map((chamado) {
                                        final assuntoTexto = (chamado.assunto ?? '').trim();

                                        return DropdownMenuItem<Chamado>(
                                          value: chamado,
                                          child: Text(
                                            '${chamado.ticket} - ${chamado.cliente} - $assuntoTexto',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        dialogSetState(() {
                                          chamadoSelecionado = value;
                                          cronogramaSelecionado = null;
                                          chamadoRefController.text = value?.ticket ?? '';
                                          projetoRefController.clear();

                                          if (value != null) {
                                            Cliente? clienteEncontrado;

                                            for (final cliente in clientes.whereType<Cliente>()) {
                                              if (cliente.nome.trim().toLowerCase() ==
                                                  value.cliente.trim().toLowerCase()) {
                                                clienteEncontrado = cliente;
                                                break;
                                              }
                                            }

                                            if (clienteEncontrado != null) {
                                              clienteSelecionado = clienteEncontrado;
                                            }
                                          }
                                        });
                                      },
                                      validator: (value) {
                                        if (origemTipoDialog == 'chamado' && value == null) {
                                          return 'Selecione o chamado';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: statusSelecionado,
                                      decoration: buildInputDecoration(
                                        label: 'Status',
                                        hint: 'Selecione o status',
                                      ),
                                      items: statusDisponiveis.map((status) {
                                        return DropdownMenuItem<String>(
                                          value: status,
                                          child: Text(status),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        dialogSetState(() {
                                          statusSelecionado =
                                              value ?? 'Planejada';
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: buildTextField(
                                      controller: observacoesController,
                                      label: 'Observações',
                                      hint: 'Anotações rápidas',
                                      required: false,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
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
                                    const Text(
                                      'Controle de execução',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Tempo acumulado: ${formatarDuracao(
                                          item.tarefa.tempoAcumuladoSegundos)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Iniciada em: ${item.tarefa.iniciadaEm ??
                                          '-'}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Encerrada em: ${item.tarefa
                                          .encerradaEm ?? '-'}',
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
                              final confirmar = await showDialog<bool>(
                                context: dialogContext,
                                builder: (confirmContext) {
                                  return AlertDialog(
                                    title: const Text('Excluir tarefa'),
                                    content: Text(
                                      'Deseja realmente excluir a tarefa "${item
                                          .tarefa.titulo}"?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(confirmContext)
                                                .pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(confirmContext)
                                                .pop(true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                          const Color(0xFFDC2626),
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Excluir'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmar != true) return;

                              try {
                                await tarefaRepository
                                    .excluirTarefa(item.tarefa.id!);
                                await carregarTarefas();

                                if (widget.onTarefasAlteradas != null) {
                                  await widget.onTarefasAlteradas!();
                                }

                                if (!mounted) return;

                                Navigator.of(dialogContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                    Text('Tarefa excluída com sucesso!'),
                                    backgroundColor: Color(0xFFDC2626),
                                  ),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erro ao excluir tarefa: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
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
                              if (!(formKey.currentState?.validate() ?? false)) return;

                              try {
                                final atualizada = item.tarefa.copyWith(
                                  clienteId: clienteSelecionado!.id,
                                  origemTipo: origemTipoDialog == 'geral'
                                      ? null
                                      : origemTipoDialog,
                                  origemId: origemTipoDialog == 'cronograma'
                                      ? cronogramaSelecionado?.id
                                      : origemTipoDialog == 'chamado'
                                      ? chamadoSelecionado?.id
                                      : null,
                                  clienteNomeRef: origemTipoDialog == 'cronograma'
                                      ? (cronogramaSelecionado?.clienteNome ?? clienteSelecionado!.nome)
                                      : origemTipoDialog == 'chamado'
                                      ? (chamadoSelecionado?.cliente.isNotEmpty == true
                                      ? chamadoSelecionado!.cliente
                                      : clienteSelecionado!.nome)
                                      : clienteSelecionado!.nome,
                                  projetoRef: origemTipoDialog == 'cronograma'
                                      ? cronogramaSelecionado?.nomeProjeto
                                      : null,
                                  chamadoRef: origemTipoDialog == 'chamado'
                                      ? chamadoSelecionado?.ticket
                                      : null,
                                  titulo: tituloController.text.trim(),
                                  descricao: descricaoController.text.trim(),
                                  data: dataController.text.trim(),
                                  horaInicio: horaInicioController.text.trim(),
                                  horaFim: horaFimController.text.trim(),
                                  status: statusSelecionado,
                                  observacoes: observacoesController.text.trim(),
                                  updatedAt: DateTime.now().toIso8601String(),
                                );

                                print('===== TAREFA ANTES DE ATUALIZAR =====');
                                print(atualizada.toMap());
                                print('clienteSelecionado: ${clienteSelecionado?.id} - ${clienteSelecionado?.nome}');
                                print('origemTipoDialog: $origemTipoDialog');
                                print('cronogramaSelecionado: ${cronogramaSelecionado?.id} - ${cronogramaSelecionado?.nomeProjeto}');
                                print('chamadoSelecionado: ${chamadoSelecionado?.id} - ${chamadoSelecionado?.ticket}');
                                print('=====================================');

                                await tarefaRepository.atualizarTarefa(atualizada);
                                await carregarTarefas();
                                await widget.onTarefasAlteradas?.call();

                                if (!mounted) return;
                                Navigator.of(dialogContext).pop();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tarefa atualizada com sucesso!'),
                                    backgroundColor: Color(0xFF059669),
                                  ),
                                );
                              } catch (e, stackTrace) {
                                print('======== ERRO AO ATUALIZAR TAREFA ========');
                                print('Erro: $e');
                                print('StackTrace: $stackTrace');
                                print('clienteSelecionado: ${clienteSelecionado?.id} - ${clienteSelecionado?.nome}');
                                print('origemTipoDialog: $origemTipoDialog');
                                print('cronogramaSelecionado: ${cronogramaSelecionado?.id} - ${cronogramaSelecionado?.nomeProjeto}');
                                print('chamadoSelecionado: ${chamadoSelecionado?.id} - ${chamadoSelecionado?.ticket}');
                                print('titulo: ${tituloController.text}');
                                print('descricao: ${descricaoController.text}');
                                print('data: ${dataController.text}');
                                print('horaInicio: ${horaInicioController.text}');
                                print('horaFim: ${horaFimController.text}');
                                print('observacoes: ${observacoesController.text}');
                                print('=========================================');

                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erro ao atualizar tarefa: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
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

  Future<void> iniciarTarefa(TarefaDetalhe item) async {
    await tarefaRepository.iniciarTarefa(item.tarefa.id!);
    await carregarTarefas();
    await widget.onTarefasAlteradas?.call();
  }

  Future<void> pausarTarefa(TarefaDetalhe item) async {
    await tarefaRepository.pausarTarefa(item.tarefa);
    await carregarTarefas();
    await widget.onTarefasAlteradas?.call();
  }

  Future<void> fecharTarefa(TarefaDetalhe item) async {
    await tarefaRepository.fecharTarefa(item.tarefa);
    await carregarTarefas();
    await widget.onTarefasAlteradas?.call();
  }

  String formatarDuracao(int segundos) {
    final horas = segundos ~/ 3600;
    final minutos = (segundos % 3600) ~/ 60;
    final restoSegundos = segundos % 60;

    final hh = horas.toString().padLeft(2, '0');
    final mm = minutos.toString().padLeft(2, '0');
    final ss = restoSegundos.toString().padLeft(2, '0');

    return '$hh:$mm:$ss';
  }

  InputDecoration buildInputDecoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
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
    );
  }


  Widget buildCabecalhoColunaTarefa(String chave, String titulo) {
    return SizedBox(
      width: largurasTarefas[chave]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Align(
          alignment: Alignment.centerLeft,
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
      ),
    );
  }

  double larguraBaseTarefas() {
    return largurasTarefas.values.fold<double>(
      0,
          (total, item) => total + item,
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: required
          ? (value) {
        if (value == null || value
            .trim()
            .isEmpty) {
          return 'Campo obrigatório';
        }
        return null;
      }
          : null,
      decoration: buildInputDecoration(label: label, hint: hint),
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
                    'Tarefas',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Planejamento, execução e acompanhamento das tarefas da semana.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: abrirDialogNovaTarefa,
              icon: const Icon(Icons.add),
              label: const Text('Nova tarefa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF12324A),
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
        const SizedBox(height: 20),
        Container(
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
                      controller: filtroTituloController,
                      onChanged: (_) => aplicarFiltros(),
                      decoration: buildInputDecoration(
                        label: 'Título',
                        hint: 'Buscar por título',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: filtroDataController,
                      onChanged: (_) => aplicarFiltros(),
                      decoration: buildInputDecoration(
                        label: 'Data',
                        hint: 'Ex: 25/04/2026',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: filtroStatus,
                      decoration: buildInputDecoration(
                        label: 'Status',
                        hint: 'Filtrar por status',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Todos',
                          child: Text('Todos'),
                        ),
                        DropdownMenuItem(
                          value: 'Planejada',
                          child: Text('Planejada'),
                        ),
                        DropdownMenuItem(
                          value: 'Em andamento',
                          child: Text('Em andamento'),
                        ),
                        DropdownMenuItem(
                          value: 'Pausada',
                          child: Text('Pausada'),
                        ),
                        DropdownMenuItem(
                          value: 'Fechada',
                          child: Text('Fechada'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          filtroStatus = value ?? 'Todos';
                        });
                        aplicarFiltros();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: limparFiltros,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Limpar filtros'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final larguraMinimaTabela = larguraBaseTarefas();
              final larguraTabela = constraints.maxWidth > larguraMinimaTabela
                  ? constraints.maxWidth
                  : larguraMinimaTabela;

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
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: larguraTabela),
                          child: SizedBox(
                            width: larguraTabela,
                            child: Row(
                              children: [
                                buildCabecalhoColunaTarefa('cliente', 'Cliente'),
                                buildCabecalhoColunaTarefa('titulo', 'Título'),
                                buildCabecalhoColunaTarefa('data', 'Data'),
                                buildCabecalhoColunaTarefa('inicio', 'Início'),
                                buildCabecalhoColunaTarefa('fim', 'Fim'),
                                buildCabecalhoColunaTarefa('status', 'Status'),
                                buildCabecalhoColunaTarefa('tempo', 'Tempo'),
                                buildCabecalhoColunaTarefa('origem', 'Origem'),
                                buildCabecalhoColunaTarefa('acoes', 'Ações'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    Expanded(
                      child: tarefasFiltradas.isEmpty
                          ? const Center(
                        child: Text(
                          'Nenhuma tarefa encontrada.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ):
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: larguraTabela),
                          child: SizedBox(
                            width: larguraTabela,
                            child: ListView.separated(
                              itemCount: tarefasFiltradas.length,
                              separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                color: Color(0xFFE5E7EB),
                              ),
                              itemBuilder: (context, index) {
                                final item = tarefasFiltradas[index];
                                return buildTarefaLinha(item, larguraTabela);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildTarefaLinha(TarefaDetalhe item, double larguraDisponivel) {
    final tarefa = item.tarefa;

    Color statusColor;
    switch (tarefa.status) {
      case 'Em andamento':
        statusColor = const Color(0xFF2563EB);
        break;
      case 'Pausada':
        statusColor = const Color(0xFFF97316);
        break;
      case 'Fechada':
        statusColor = const Color(0xFF16A34A);
        break;
      default:
        statusColor = const Color(0xFF6B7280);
    }

    final total = tarefa.tempoAcumuladoSegundos;
    final String tempoFormatado;

    if (total == 0) {
      tempoFormatado = '-';
    } else {
      final horas = total ~/ 3600;
      final minutos = (total % 3600) ~/ 60;
      tempoFormatado = horas > 0 ? '${horas}h ${minutos}m' : '${minutos}m';
    }

    return InkWell(
      onTap: () => abrirDialogEditarTarefa(item),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: largurasTarefas['cliente']!,
              child: Text(
                item.clienteNome ?? 'Sem cliente',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            SizedBox(
              width: largurasTarefas['titulo']!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tarefa.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  if (tarefa.descricao.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      tarefa.descricao,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(
              width: largurasTarefas['data']!,
              child: Text(tarefa.data),
            ),
            SizedBox(
              width: largurasTarefas['inicio']!,
              child: Text(tarefa.horaInicio),
            ),
            SizedBox(
              width: largurasTarefas['fim']!,
              child: Text(tarefa.horaFim),
            ),
            SizedBox(
              width: largurasTarefas['status']!,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusColor.withOpacity(0.4)),
                ),
                child: Text(
                  tarefa.status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: largurasTarefas['tempo']!,
              child: Text(tempoFormatado),
            ),
            SizedBox(
              width: largurasTarefas['origem']!,
              child: Text(
                tarefa.origemTipo ?? '-',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: largurasTarefas['acoes']!,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => abrirDialogEditarTarefa(item),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        if (tarefa.status == 'Em andamento') {
                          await pausarTarefa(item);
                        } else if (tarefa.status == 'Fechada') {
                          return;
                        } else {
                          await iniciarTarefa(item);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          tarefa.status == 'Em andamento'
                              ? Icons.pause_outlined
                              : Icons.play_arrow_outlined,
                          size: 18,
                          color: tarefa.status == 'Fechada'
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusTarefaBadge extends StatelessWidget {
  final String label;

  const StatusTarefaBadge({
    super.key,
    required this.label,
  });

  Color get backgroundColor {
    switch (label) {
      case 'Planejada':
        return const Color(0xFFDBEAFE);
      case 'Em andamento':
        return const Color(0xFFFEF3C7);
      case 'Pausada':
        return const Color(0xFFE5E7EB);
      case 'Fechada':
        return const Color(0xFFD1FAE5);
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  Color get textColor {
    switch (label) {
      case 'Planejada':
        return const Color(0xFF1D4ED8);
      case 'Em andamento':
        return const Color(0xFFB45309);
      case 'Pausada':
        return const Color(0xFF4B5563);
      case 'Fechada':
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