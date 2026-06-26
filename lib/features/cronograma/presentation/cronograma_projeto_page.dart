import 'package:flutter/material.dart';
import '../data/cronograma_repository.dart';
import '../domain/cronograma_models.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


class _ClienteOpcao {
  final int id;
  final String nome;

  const _ClienteOpcao({
    required this.id,
    required this.nome,
  });
}

class _SetorOpcao {
  final int id;
  final String nome;

  const _SetorOpcao({
    required this.id,
    required this.nome,
  });
}

class CronogramaProjetoPage extends StatefulWidget {
  const CronogramaProjetoPage({
    super.key,
    this.projetoInicial,
  });

  final CronogramaProjeto? projetoInicial;

  @override
  State<CronogramaProjetoPage> createState() => _CronogramaProjetoPageState();
}

class _CronogramaProjetoPageState extends State<CronogramaProjetoPage> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalControllerTabela = ScrollController();
  final ScrollController _verticalControllerTimeline = ScrollController();

  final CronogramaRepository _cronogramaRepository = CronogramaRepository();

  List<_ClienteOpcao> _clientes = [];
  List<_SetorOpcao> _setores = [];
  bool _carregandoCombos = false;

  final List<String> semanas = const [
    'Sem 1',
    'Sem 2',
    'Sem 3',
    'Sem 4',
    'Sem 5',
    'Sem 6',
    'Sem 7',
    'Sem 8',
  ];

  late CronogramaProjeto projeto;


  @override
  void initState() {
    super.initState();
    projeto = widget.projetoInicial ?? _novoProjetoVazio();
    _carregarCombos();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalControllerTabela.dispose();
    _verticalControllerTimeline.dispose();
    super.dispose();
  }

  CronogramaProjeto _novoProjetoVazio() {
    return CronogramaProjeto(
      id: null,
      clienteId: null,
      setorId: null,
      nomeProjeto: '',
      responsavel: '',
      inicio: null,
      termino: null,
      realizadoPercentual: 0,
      status: 'Em andamento',
      createdAt: '',
      updatedAt: '',
      clienteNome: null,
      setorNome: null,
      itens: const [],
    );
  }

  void _recalcularProjeto() {
    final filhos = projeto.itens.where((e) => !e.destaque).toList();
    if (filhos.isEmpty) return;

    final total = filhos.fold<int>(
      0,
          (soma, item) => soma + item.realizadoPercentual,
    );
    final media = (total / filhos.length).round();

    String status;
    if (media >= 100) {
      status = 'Concluída';
    } else if (media == 0) {
      status = 'Atenção';
    } else {
      status = 'Em andamento';
    }

    final idx = projeto.itens.indexWhere((e) => e.destaque);
    final novaLista = [...projeto.itens];

    if (idx != -1) {
      novaLista[idx] = novaLista[idx].copyWith(
        realizadoPercentual: media,
        status: status,
      );
    }

    setState(() {
      projeto = projeto.copyWith(
        realizadoPercentual: media,
        status: status,
        itens: novaLista,
      );
    });
  }

  void _atualizarItem(int index, CronogramaItem itemAtualizado) {
    final itensAtualizados = [...projeto.itens];
    itensAtualizados[index] = itemAtualizado;

    setState(() {
      projeto = projeto.copyWith(itens: itensAtualizados);
    });

    recalcularProjeto();
  }

  void _excluirItem(int index) {
    final item = projeto.itens[index];

    if (item.destaque) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O item principal do projeto não pode ser excluído.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final itensAtualizados = [...projeto.itens]..removeAt(index);

    setState(() {
      projeto = projeto.copyWith(itens: itensAtualizados);
    });

    recalcularProjeto();
  }

  Future<void> _editarItem(int index) async {
    final item = projeto.itens[index];
    final atividadeController = TextEditingController(text: item.atividade);
    final responsavelController = TextEditingController(text: item.responsavel);

    int nivel = item.nivel;
    DateTime? dataInicio = item.dataInicio;
    int diasUteis = item.diasUteis <= 0 ? 1 : item.diasUteis;
    int realizado = item.realizadoPercentual;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Editar atividade'),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: nivel,
                      decoration: const InputDecoration(
                        labelText: 'Nível da atividade',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Text('1 - Projeto principal'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('2 - Atividade geral'),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text('3 - Atividade direta'),
                        ),
                        DropdownMenuItem(
                          value: 4,
                          child: Text('4 - Subatividade'),
                        ),
                      ],
                      onChanged: item.destaque
                          ? null
                          : (valor) {
                        if (valor != null) {
                          setDialogState(() {
                            nivel = valor;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: atividadeController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição da atividade',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: responsavelController,
                      decoration: const InputDecoration(
                        labelText: 'Responsável',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final selecionada = await showDatePicker(
                                context: ctx,
                                initialDate: dataInicio ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (selecionada != null) {
                                setDialogState(() {
                                  dataInicio = selecionada;
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(
                              dataInicio == null
                                  ? 'Definir início'
                                  : _formatarData(dataInicio!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: diasUteis.toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Dias úteis',
                            ),
                            onChanged: (v) {
                              diasUteis = int.tryParse(v) ?? 1;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: realizado.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Realizado %',
                      ),
                      onChanged: (v) {
                        realizado = (int.tryParse(v) ?? 0).clamp(0, 100);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final descricao = atividadeController.text.trim();
                    if (descricao.isEmpty) return;

                    final inicio = dataInicio ?? DateTime.now();
                    final dias = diasUteis <= 0 ? 1 : diasUteis;
                    final termino = inicio.add(Duration(days: dias - 1));

                    final atualizado = item.copyWith(
                      atividade: descricao,
                      responsavel: responsavelController.text.trim(),
                      dataInicio: inicio,
                      diasUteis: dias,
                      diasCorridos: termino.difference(inicio).inDays + 1,
                      dataTermino: termino,
                      realizadoPercentual: realizado,
                      status: _calcularStatusAutomatico(
                        realizadoPercentual: realizado,
                        dataTermino: termino,
                      ),
                      duracaoSemanas: dias <= 7 ? 1 : (dias / 7).ceil(),
                      nivel: item.destaque ? 1 : nivel,
                      destaque: item.destaque,
                    );

                    _atualizarItem(index, atualizado);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void recalcularProjeto() {
    if (projeto.itens.isEmpty) return;

    final itens = [...projeto.itens];

    List<int> filhosDiretosDe(int indexPai) {
      final nivelPai = itens[indexPai].nivel;
      final nivelFilho = nivelPai + 1;
      final filhos = <int>[];

      for (int i = indexPai + 1; i < itens.length; i++) {
        final nivelAtual = itens[i].nivel;

        if (nivelAtual <= nivelPai) {
          break;
        }

        if (nivelAtual == nivelFilho) {
          filhos.add(i);
        }
      }

      return filhos;
    }

    for (int i = itens.length - 1; i >= 0; i--) {
      final filhos = filhosDiretosDe(i);

      if (filhos.isNotEmpty) {
        final media = (filhos
            .map((idx) => itens[idx].realizadoPercentual)
            .reduce((a, b) => a + b) /
            filhos.length)
            .round();

        DateTime? menorInicio;
        DateTime? maiorTermino;

        for (final idx in filhos) {
          final filho = itens[idx];

          if (filho.dataInicio != null) {
            if (menorInicio == null || filho.dataInicio!.isBefore(menorInicio)) {
              menorInicio = filho.dataInicio;
            }
          }

          if (filho.dataTermino != null) {
            if (maiorTermino == null || filho.dataTermino!.isAfter(maiorTermino)) {
              maiorTermino = filho.dataTermino;
            }
          }
        }

        final statusCalculado = _calcularStatusAutomatico(
          realizadoPercentual: media,
          dataTermino: maiorTermino ?? itens[i].dataTermino,
        );

        itens[i] = itens[i].copyWith(
          realizadoPercentual: media,
          status: statusCalculado,
          dataInicio: menorInicio ?? itens[i].dataInicio,
          dataTermino: maiorTermino ?? itens[i].dataTermino,
          diasCorridos: menorInicio != null && maiorTermino != null
              ? maiorTermino.difference(menorInicio).inDays + 1
              : itens[i].diasCorridos,
        );
      } else {
        final statusCalculado = _calcularStatusAutomatico(
          realizadoPercentual: itens[i].realizadoPercentual,
          dataTermino: itens[i].dataTermino,
        );

        itens[i] = itens[i].copyWith(status: statusCalculado);
      }
    }

    final principal = itens.first;

    setState(() {
      projeto = projeto.copyWith(
        inicio: principal.dataInicio,
        termino: principal.dataTermino,
        realizadoPercentual: principal.realizadoPercentual,
        status: principal.status,
        itens: itens,
      );
    });
  }

  Future<bool> _garantirClienteESetorAntesDeSalvar() async {
    if (projeto.clienteId != null && projeto.setorId != null) {
      return true;
    }

    int? clienteIdSelecionado = projeto.clienteId;
    int? setorIdSelecionado = projeto.setorId;

    final confirmado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Selecionar cliente e setor'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: clienteIdSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Cliente',
                      ),
                      items: _clientes
                          .map(
                            (c) => DropdownMenuItem<int>(
                          value: c.id,
                          child: Text(c.nome),
                        ),
                      )
                          .toList(),
                      onChanged: (valor) {
                        setDialogState(() {
                          clienteIdSelecionado = valor;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: setorIdSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Setor',
                      ),
                      items: _setores
                          .map(
                            (s) => DropdownMenuItem<int>(
                          value: s.id,
                          child: Text(s.nome),
                        ),
                      )
                          .toList(),
                      onChanged: (valor) {
                        setDialogState(() {
                          setorIdSelecionado = valor;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (clienteIdSelecionado == null || setorIdSelecionado == null) {
                      return;
                    }

                    final cliente = _clientes.firstWhere(
                          (c) => c.id == clienteIdSelecionado,
                    );

                    final setor = _setores.firstWhere(
                          (s) => s.id == setorIdSelecionado,
                    );

                    setState(() {
                      projeto = projeto.copyWith(
                        clienteId: cliente.id,
                        setorId: setor.id,
                        clienteNome: cliente.nome,
                        setorNome: setor.nome,
                      );
                    });

                    Navigator.pop(ctx, true);
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    return confirmado == true;
  }

  Future<void> _abrirDialogNovoCronograma() async {
    if (_carregandoCombos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aguarde o carregamento de clientes e setores.'),
        ),
      );
      return;
    }

    if (_clientes.isEmpty || _setores.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastre clientes e setores antes de criar um cronograma.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int? clienteIdSelecionado;
    int? setorIdSelecionado;
    final projetoController = TextEditingController();
    final responsavelController = TextEditingController();
    DateTime? dataInicio;
    DateTime? dataTermino;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Novo cronograma'),
              content: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: clienteIdSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Cliente',
                      ),
                      items: _clientes
                          .map(
                            (c) => DropdownMenuItem<int>(
                          value: c.id,
                          child: Text(c.nome),
                        ),
                      )
                          .toList(),
                      onChanged: (valor) {
                        setDialogState(() {
                          clienteIdSelecionado = valor;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: setorIdSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Setor',
                      ),
                      items: _setores
                          .map(
                            (s) => DropdownMenuItem<int>(
                          value: s.id,
                          child: Text(s.nome),
                        ),
                      )
                          .toList(),
                      onChanged: (valor) {
                        setDialogState(() {
                          setorIdSelecionado = valor;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: projetoController,
                      decoration: const InputDecoration(
                        labelText: 'Projeto',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: responsavelController,
                      decoration: const InputDecoration(
                        labelText: 'Responsável pelo projeto',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final selecionada = await showDatePicker(
                                context: ctx,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (selecionada != null) {
                                setDialogState(() {
                                  dataInicio = selecionada;
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(
                              dataInicio == null
                                  ? 'Início'
                                  : _formatarData(dataInicio!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final base = dataInicio ?? DateTime.now();
                              final selecionada = await showDatePicker(
                                context: ctx,
                                initialDate: base,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (selecionada != null) {
                                setDialogState(() {
                                  dataTermino = selecionada;
                                });
                              }
                            },
                            icon: const Icon(Icons.event_available, size: 16),
                            label: Text(
                              dataTermino == null
                                  ? 'Término'
                                  : _formatarData(dataTermino!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nomeProjeto = projetoController.text.trim();
                    final responsavel = responsavelController.text.trim();

                    if (clienteIdSelecionado == null ||
                        setorIdSelecionado == null ||
                        nomeProjeto.isEmpty ||
                        dataInicio == null ||
                        dataTermino == null) {
                      return;
                    }

                    final cliente = _clientes.firstWhere(
                          (c) => c.id == clienteIdSelecionado,
                    );

                    final setor = _setores.firstWhere(
                          (s) => s.id == setorIdSelecionado,
                    );

                    final principal = CronogramaItem(
                      id: null,
                      cronogramaId: null,
                      atividade: nomeProjeto,
                      responsavel: responsavel,
                      dataInicio: dataInicio,
                      diasUteis: 0,
                      diasCorridos: dataTermino!
                          .difference(dataInicio!)
                          .inDays +
                          1,
                      dataTermino: dataTermino,
                      dataProximaAcao: null,
                      realizadoPercentual: 0,
                      status: 'Em andamento',
                      inicioSemana: 0,
                      duracaoSemanas: 1,
                      destaque: true,
                      nivel: 1,
                    );

                    setState(() {
                      projeto = CronogramaProjeto(
                        id: null,
                        clienteId: cliente.id,
                        setorId: setor.id,
                        nomeProjeto: nomeProjeto,
                        responsavel: responsavel,
                        inicio: dataInicio,
                        termino: dataTermino,
                        realizadoPercentual: 0,
                        status: 'Em andamento',
                        createdAt: '',
                        updatedAt: '',
                        clienteNome: cliente.nome,
                        setorNome: setor.nome,
                        itens: [principal],
                      );
                    });

                    Navigator.pop(ctx);

                    await _salvarCronograma();
                  },
                  child: const Text('Criar cronograma'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _carregarCombos() async {
    try {
      setState(() {
        _carregandoCombos = true;
      });

      final db = await _cronogramaRepository.db;

      final clientesRows = await db.query(
        'clientes',
        columns: ['id', 'nome'],
        orderBy: 'nome ASC',
      );

      final setoresRows = await db.query(
        'setores',
        columns: ['id', 'nome'],
        orderBy: 'nome ASC',
      );

      if (!mounted) return;

      setState(() {
        _clientes = clientesRows
            .map(
              (e) => _ClienteOpcao(
            id: (e['id'] as num).toInt(),
            nome: (e['nome'] ?? '').toString(),
          ),
        )
            .toList();

        _setores = setoresRows
            .map(
              (e) => _SetorOpcao(
            id: (e['id'] as num).toInt(),
            nome: (e['nome'] ?? '').toString(),
          ),
        )
            .toList();

        _carregandoCombos = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregandoCombos = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar clientes e setores: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _salvarCronograma() async {
    try {
      if (_carregandoCombos) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aguarde o carregamento de clientes e setores.'),
          ),
        );
        return;
      }

      if (_clientes.isEmpty || _setores.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não há clientes ou setores cadastrados para selecionar.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final podeSalvar = await _garantirClienteESetorAntesDeSalvar();
      if (!podeSalvar) return;

      _recalcularProjeto();

      final agora = DateTime.now().toIso8601String();

      final projetoParaSalvar = projeto.copyWith(
        createdAt: projeto.createdAt.isEmpty ? agora : projeto.createdAt,
        updatedAt: agora,
      );

      int? idSalvo = projeto.id;

      if (projetoParaSalvar.id == null) {
        idSalvo = await _cronogramaRepository.inserirCronograma(projetoParaSalvar);
      } else {
        await _cronogramaRepository.atualizarCronograma(projetoParaSalvar);
        idSalvo = projetoParaSalvar.id;
      }

      if (!mounted) return;

      final projetoAtualizado = await _cronogramaRepository.buscarPorId(idSalvo!);

      if (!mounted) return;

      if (projetoAtualizado != null) {
        setState(() {
          projeto = projetoAtualizado;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cronograma salvo com sucesso.'),
          backgroundColor: Color(0xFF059669),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar cronograma: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _abrirCronogramaSalvo(CronogramaProjeto selecionado) async {
    if (selecionado.id == null) return;

    final projetoCompleto =
    await _cronogramaRepository.buscarPorId(selecionado.id!);

    if (!mounted || projetoCompleto == null) return;

    setState(() {
      projeto = projetoCompleto;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cronograma carregado com sucesso.'),
        backgroundColor: Color(0xFF2563EB),
      ),
    );
  }

  Future<void> _excluirCronogramaAtual() async {
    if (projeto.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Salve o cronograma antes de excluir.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Excluir cronograma'),
          content: Text(
            'Deseja excluir o cronograma "${projeto.nomeProjeto}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB42318),
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    await _cronogramaRepository.excluirCronograma(projeto.id!);

    if (!mounted) return;

    setState(() {
      projeto = _novoProjetoVazio();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cronograma excluído com sucesso.'),
        backgroundColor: Color(0xFF059669),
      ),
    );
  }

  Future<void> _abrirDialogPesquisarCronogramas() async {
    final todos = await _cronogramaRepository.listarCronogramas();

    if (!mounted) return;

    final buscaController = TextEditingController();
    List<CronogramaProjeto> filtrados = [...todos];

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void filtrar(String texto) {
              final termo = texto.trim().toLowerCase();

              setDialogState(() {
                filtrados = todos.where((c) {
                  final nome = c.nomeProjeto.toLowerCase();
                  final cliente = (c.clienteNome ?? '').toLowerCase();
                  final setor = (c.setorNome ?? '').toLowerCase();
                  final responsavel = c.responsavel.toLowerCase();

                  return nome.contains(termo) ||
                      cliente.contains(termo) ||
                      setor.contains(termo) ||
                      responsavel.contains(termo);
                }).toList();
              });
            }

            return AlertDialog(
              title: const Text('Abrir cronograma salvo'),
              content: SizedBox(
                width: 620,
                height: 420,
                child: Column(
                  children: [
                    TextField(
                      controller: buscaController,
                      onChanged: filtrar,
                      decoration: const InputDecoration(
                        labelText: 'Pesquisar cronograma',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filtrados.isEmpty
                          ? const Center(
                        child: Text('Nenhum cronograma encontrado.'),
                      )
                          : ListView.separated(
                        itemCount: filtrados.length,
                        separatorBuilder: (_, __) =>
                        const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = filtrados[index];

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            title: Text(
                              item.nomeProjeto.isEmpty
                                  ? 'Sem nome'
                                  : item.nomeProjeto,
                            ),
                            subtitle: Text(
                              'Cliente: ${item.clienteNome ?? '-'} • '
                                  'Setor: ${item.setorNome ?? '-'} • '
                                  'Status: ${item.status}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Excluir',
                                  onPressed: () async {
                                    if (item.id == null) return;

                                    final confirmarExcluir =
                                    await showDialog<bool>(
                                      context: context,
                                      builder: (ctx2) {
                                        return AlertDialog(
                                          title: const Text(
                                            'Excluir cronograma',
                                          ),
                                          content: Text(
                                            'Deseja excluir "${item.nomeProjeto}"?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx2, false),
                                              child: const Text('Cancelar'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx2, true),
                                              style:
                                              ElevatedButton.styleFrom(
                                                backgroundColor:
                                                const Color(0xFFB42318),
                                                foregroundColor:
                                                Colors.white,
                                              ),
                                              child: const Text('Excluir'),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmarExcluir != true) return;

                                    await _cronogramaRepository
                                        .excluirCronograma(item.id!);

                                    final atualizados =
                                    await _cronogramaRepository
                                        .listarCronogramas();

                                    setDialogState(() {
                                      filtrados = atualizados;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Color(0xFFB42318),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Abrir',
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                    await _abrirCronogramaSalvo(item);
                                  },
                                  icon: const Icon(Icons.folder_open),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Fechar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _nomeBaseArquivo() {
    return projeto.nomeProjeto.trim().isEmpty
        ? 'cronograma_projeto'
        : projeto.nomeProjeto
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_');
  }

  Future<String?> _selecionarCaminhoSalvar({
    required String suggestedName,
    required String dialogTitle,
  }) async {
    final downloads = await getDownloadsDirectory();

    return FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: suggestedName,
      initialDirectory: downloads?.path,
    );
  }

  Future<void> _exportarCsv() async {
    try {
      if (projeto.itens.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não há itens para exportar.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final caminho = await _selecionarCaminhoSalvar(
        suggestedName: '${_nomeBaseArquivo()}.csv',
        dialogTitle: 'Salvar CSV do cronograma',
      );

      if (caminho == null || caminho.trim().isEmpty) return;

      final buffer = StringBuffer();

      buffer.writeln('Projeto;${projeto.nomeProjeto}');
      buffer.writeln('Cliente;${projeto.clienteNome ?? '-'}');
      buffer.writeln('Setor;${projeto.setorNome ?? '-'}');
      buffer.writeln(
        'Responsável;${projeto.responsavel.isEmpty ? '-' : projeto.responsavel}',
      );
      buffer.writeln(
        'Início;${projeto.inicio != null ? _formatarData(projeto.inicio!) : '-'}',
      );
      buffer.writeln(
        'Término;${projeto.termino != null ? _formatarData(projeto.termino!) : '-'}',
      );
      buffer.writeln('Realizado;${projeto.realizadoPercentual}%');
      buffer.writeln('Status;${projeto.status}');
      buffer.writeln('');

      buffer.writeln(
        'Nivel;Atividade;Responsavel;Inicio;DiasUteis;DiasCorridos;Termino;ProximaAcao;RealizadoPercentual;Status',
      );

      for (final item in projeto.itens) {
        buffer.writeln(
          '${item.nivel};'
              '${item.atividade.replaceAll(';', ',')};'
              '${item.responsavel.replaceAll(';', ',')};'
              '${item.dataInicio != null ? _formatarData(item.dataInicio!) : ''};'
              '${item.diasUteis};'
              '${item.diasCorridos};'
              '${item.dataTermino != null ? _formatarData(item.dataTermino!) : ''};'
              '${item.dataProximaAcao != null ? _formatarData(item.dataProximaAcao!) : ''};'
              '${item.realizadoPercentual};'
              '${item.status.replaceAll(';', ',')}',
        );
      }

      final file = File(caminho);
      await file.writeAsString(buffer.toString(), flush: true);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV salvo em: $caminho'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao exportar CSV: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  Future<void> _gerarPdf() async {
    try {
      if (projeto.itens.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não há itens para gerar PDF.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final caminho = await _selecionarCaminhoSalvar(
        suggestedName: '${_nomeBaseArquivo()}.pdf',
        dialogTitle: 'Salvar PDF do cronograma',
      );

      if (caminho == null || caminho.trim().isEmpty) return;

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(24),
          build: (context) => [
            pw.Text(
              projeto.nomeProjeto.isEmpty
                  ? 'Cronograma de Projeto'
                  : projeto.nomeProjeto,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Cliente: ${projeto.clienteNome ?? '-'}'),
            pw.Text('Setor: ${projeto.setorNome ?? '-'}'),
            pw.Text(
              'Responsável: ${projeto.responsavel.isEmpty ? '-' : projeto.responsavel}',
            ),
            pw.Text(
              'Início: ${projeto.inicio != null ? _formatarData(projeto.inicio!) : '-'}',
            ),
            pw.Text(
              'Término: ${projeto.termino != null ? _formatarData(projeto.termino!) : '-'}',
            ),
            pw.Text('Realizado: ${projeto.realizadoPercentual}%'),
            pw.Text('Status: ${projeto.status}'),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: const [
                'Nivel',
                'Atividade',
                'Responsavel',
                'Inicio',
                'Dias Uteis',
                'Dias Corridos',
                'Termino',
                'Prox. Acao',
                'Realizado %',
                'Status',
              ],
              data: projeto.itens.map((item) {
                return [
                  item.nivel.toString(),
                  item.atividade,
                  item.responsavel,
                  item.dataInicio != null ? _formatarData(item.dataInicio!) : '',
                  item.diasUteis.toString(),
                  item.diasCorridos.toString(),
                  item.dataTermino != null ? _formatarData(item.dataTermino!) : '',
                  item.dataProximaAcao != null
                      ? _formatarData(item.dataProximaAcao!)
                      : '',
                  item.realizadoPercentual.toString(),
                  item.status,
                ];
              }).toList(),
            ),
          ],
        ),
      );

      final file = File(caminho);
      await file.writeAsBytes(await pdf.save(), flush: true);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF salvo em: $caminho'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    const double painelEsquerdo = 224;

    const double colAtividade = 250;
    const double colResponsavel = 140;
    const double colInicio = 96;
    const double colDiasUteis = 76;
    const double colDiasCorridos = 82;
    const double colTermino = 96;
    const double colProx = 88;
    const double colRealizado = 64;
    const double colStatus = 110;
    const double colAcoes = 96;

    const double tabelaEsquerda =
            colAtividade +
            colResponsavel +
            colInicio +
            colDiasUteis +
            colDiasCorridos +
            colTermino +
            colProx +
            colRealizado +
            colStatus +
            colAcoes;

    const double larguraSemana = 72;
    final double larguraTimeline = semanas.length * larguraSemana;

    return Container(
      color: const Color(0xFFF3F6FB),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
        child: Row(
          children: [
            _buildPainelProjeto(painelEsquerdo),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD9E2EC)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildToolbarSuperior(),
                    const Divider(height: 1),
                    Expanded(
                      child: Scrollbar(
                        controller: _horizontalController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _horizontalController,
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: tabelaEsquerda + larguraTimeline,
                            child: Column(
                              children: [
                                _buildCabecalhoTempo(
                                  tabelaEsquerda: tabelaEsquerda,
                                  larguraSemana: larguraSemana,
                                ),
                                const Divider(height: 1),
                                Expanded(
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: tabelaEsquerda,
                                        child: _buildTabelaDetalhada(),
                                      ),
                                      SizedBox(
                                        width: larguraTimeline,
                                        child: _buildTimeline(larguraSemana),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cellDataEditavel({
    required DateTime? valor,
    required double largura,
    required Future<void> Function() onTap,
  }) {
    return Container(
      width: largura,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFE5E7EB)),
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Center(
          child: Text(
            valor != null ? _formatarData(valor) : '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF111827),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cellTextoEditavel({
    required String valor,
    required double largura,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      width: largura,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFE5E7EB)),
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: TextFormField(
        initialValue: valor,
        onChanged: onChanged,
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF111827),
        ),
      ),
    );
  }

  Widget _cellNumeroEditavel({
    required int valor,
    required double largura,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      width: largura,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFE5E7EB)),
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: TextFormField(
        initialValue: valor.toString(),
        keyboardType: TextInputType.number,
        onChanged: (valorDigitado) {
          final numero = int.tryParse(valorDigitado.trim()) ?? 0;
          onChanged(numero);
        },
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF111827),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPainelProjeto(double largura) {
    return Container(
      width: largura,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF4FB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD5E1EE)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.account_tree_outlined,
              color: Color(0xFF163B65),
              size: 26,
            ),
            const SizedBox(height: 10),
            const Text(
              'Projeto',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5B6B7B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              projeto.nomeProjeto.isEmpty ? 'Novo cronograma' : projeto.nomeProjeto,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                height: 1.15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF102A43),
              ),
            ),

            const SizedBox(height: 12),

            _buildInfoCard('Cliente', projeto.clienteNome ?? 'Não selecionado'),
            _buildInfoCard('Setor', projeto.setorNome ?? 'Não selecionado'),
            _buildInfoCard(
              'Responsável',
              projeto.responsavel.isEmpty ? '-' : projeto.responsavel,
            ),
            _buildInfoCard(
              'Início',
              projeto.inicio != null ? _formatarData(projeto.inicio!) : '-',
            ),
            _buildInfoCard(
              'Término',
              projeto.termino != null ? _formatarData(projeto.termino!) : '-',
            ),
            _buildInfoCard('Realizado', '${projeto.realizadoPercentual}%'),
            _buildInfoCard('Status', projeto.status),

            const SizedBox(height: 10),
            const Divider(height: 18),

            const Text(
              'Ações do projeto',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5B6B7B),
              ),
            ),
            const SizedBox(height: 8),

            _buildBotaoPainel(
              icon: Icons.search,
              titulo: 'Abrir cronograma',
              cor: const Color(0xFF475467),
              onPressed: _abrirDialogPesquisarCronogramas,
            ),
            const SizedBox(height: 8),

            _buildBotaoPainel(
              icon: Icons.note_add_outlined,
              titulo: 'Novo cronograma',
              cor: const Color(0xFF2563EB),
              onPressed: _abrirDialogNovoCronograma,
            ),
            const SizedBox(height: 8),

            _buildBotaoPainel(
              icon: Icons.add,
              titulo: 'Nova atividade',
              cor: const Color(0xFF1D4ED8),
              onPressed: _abrirDialogNovaAtividade,
            ),
            const SizedBox(height: 8),

            _buildBotaoPainel(
              icon: Icons.save_outlined,
              titulo: 'Salvar cronograma',
              cor: const Color(0xFF163B65),
              onPressed: _salvarCronograma,
            ),
            const SizedBox(height: 8),

            _buildBotaoPainel(
              icon: Icons.delete_outline,
              titulo: 'Excluir cronograma',
              cor: const Color(0xFFB42318),
              onPressed: _excluirCronogramaAtual,
            ),

            const SizedBox(height: 10),
            const Divider(height: 18),

            const Text(
              'Exportação',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5B6B7B),
              ),
            ),
            const SizedBox(height: 8),

            _buildBotaoPainel(
              icon: Icons.table_view_outlined,
              titulo: 'Exportar CSV',
              cor: const Color(0xFF059669),
              onPressed: _exportarCsv,
            ),
            const SizedBox(height: 8),

            _buildBotaoPainel(
              icon: Icons.picture_as_pdf_outlined,
              titulo: 'Gerar PDF',
              cor: const Color(0xFFB42318),
              onPressed: _gerarPdf,
            ),
          ],
        ),
      ),
    );
  }

  String _calcularStatusAutomatico({
    required int realizadoPercentual,
    required DateTime? dataTermino,
  }) {
    final hoje = DateTime.now();
    final hojeNormalizado = DateTime(hoje.year, hoje.month, hoje.day);

    final terminoNormalizado = dataTermino == null
        ? null
        : DateTime(dataTermino.year, dataTermino.month, dataTermino.day);

    if (realizadoPercentual >= 100) {
      return 'Concluída';
    }

    if (terminoNormalizado != null && hojeNormalizado.isAfter(terminoNormalizado)) {
      return 'Atenção';
    }

    return 'Em andamento';
  }

  String _formatarData(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  Widget _buildInfoCard(String titulo, String valor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E2EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7B8794),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF102A43),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoPainel({
    required IconData icon,
    required String titulo,
    required Color cor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 17, color: cor),
        label: Text(
          titulo,
          style: TextStyle(
            color: cor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(38),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          side: BorderSide(color: cor.withOpacity(0.22)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildToolbarSuperior() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Cronograma de Projeto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          _buildChipTopo('60 dias'),
          const SizedBox(width: 6),
          _buildChipTopo('8 semanas'),
          const SizedBox(width: 6),
          _buildChipTopo('Visual detalhado'),
        ],
      ),
    );
  }

  Widget _buildChipTopo(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildCabecalhoTempo({
    required double tabelaEsquerda,
    required double larguraSemana,
  }) {
    return SizedBox(
      height: 74,
      child: Row(
        children: [
          SizedBox(
            width: tabelaEsquerda,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: const Color(0xFFF8FAFC),
              child: const Text(
                'Planejamento detalhado',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  _buildMesHeader('Mês 1', larguraSemana * 4),
                  _buildMesHeader('Mês 2', larguraSemana * 4),
                ],
              ),
              Row(
                children: semanas
                    .map((semana) => _buildSemanaHeader(semana, larguraSemana))
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMesHeader(String titulo, double largura) {
    return Container(
      width: largura,
      height: 36,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFEAF2FB),
        border: Border(
          left: BorderSide(color: Color(0xFFD9E2EC)),
          bottom: BorderSide(color: Color(0xFFD9E2EC)),
        ),
      ),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1D4E89),
        ),
      ),
    );
  }

  Widget _buildSemanaHeader(String titulo, double largura) {
    return Container(
      width: largura,
      height: 38,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FBFF),
        border: Border(
          left: BorderSide(color: Color(0xFFD9E2EC)),
          bottom: BorderSide(color: Color(0xFFD9E2EC)),
        ),
      ),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF486581),
        ),
      ),
    );
  }

  Widget _buildTabelaDetalhada() {
    return Column(
      children: [
        _buildHeaderTabela(),
        Expanded(
          child: ListView.builder(
            controller: _verticalControllerTabela,
            itemCount: projeto.itens.length,
            itemBuilder: (context, index) {
              final item = projeto.itens[index];
              return _buildLinhaTabela(item, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderTabela() {
    return Container(
      height: 44,
      color: const Color(0xFFF8FAFC),
      child: const Row(
        children: [
          _CellHeader('Atividade / Tarefa', 250),
          _CellHeader('Responsável', 140),
          _CellHeader('Início', 96),
          _CellHeader('Dias úteis', 76),
          _CellHeader('Dias corri.', 82),
          _CellHeader('Término', 96),
          _CellHeader('Próx.', 88),
          _CellHeader('Real. %', 64),
          _CellHeader('Status', 110),
          _CellHeader('Ações', 96),
        ],
      ),
    );
  }

  Widget _buildLinhaTabela(CronogramaItem item, int index) {
    final bg = item.destaque
        ? const Color(0xFFF6FBFF)
        : index.isEven
        ? Colors.white
        : const Color(0xFFFCFDFE);

    bool temFilhosDiretos() {
      final nivelPai = projeto.itens[index].nivel;
      final nivelFilho = nivelPai + 1;

      for (int i = index + 1; i < projeto.itens.length; i++) {
        final nivelAtual = projeto.itens[i].nivel;

        if (nivelAtual <= nivelPai) {
          return false;
        }

        if (nivelAtual == nivelFilho) {
          return true;
        }
      }

      return false;
    }

    final percentualBloqueado = temFilhosDiretos();

    return Container(
      height: 48,
      color: bg,
      child: Row(
        children: [
          _cellAtividade(item, 250),

          _cellTextoEditavel(
            valor: item.responsavel,
            largura: 140,
            onChanged: (valor) {
              _atualizarItem(
                index,
                item.copyWith(responsavel: valor),
              );
            },
          ),

          _cellDataEditavel(
            valor: item.dataInicio,
            largura: 96,
            onTap: () async {
              final atual = item.dataInicio ?? DateTime.now();
              final selecionada = await showDatePicker(
                context: context,
                initialDate: atual,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );

              if (selecionada == null) return;

              final dias = item.diasUteis <= 0 ? 1 : item.diasUteis;
              final termino = selecionada.add(Duration(days: dias - 1));
              final statusAtualizado = _calcularStatusAutomatico(
                realizadoPercentual: item.realizadoPercentual,
                dataTermino: termino,
              );

              _atualizarItem(
                index,
                item.copyWith(
                  dataInicio: selecionada,
                  dataTermino: termino,
                  diasCorridos: termino.difference(selecionada).inDays + 1,
                  duracaoSemanas: dias <= 7 ? 1 : (dias / 7).ceil(),
                  status: statusAtualizado,
                ),
              );
            },
          ),

          _cellNumeroEditavel(
            valor: item.diasUteis,
            largura: 76,
            onChanged: (valor) {
              final dias = valor <= 0 ? 1 : valor;
              final inicio = item.dataInicio ?? DateTime.now();
              final termino = inicio.add(Duration(days: dias - 1));
              final statusAtualizado = _calcularStatusAutomatico(
                realizadoPercentual: item.realizadoPercentual,
                dataTermino: termino,
              );

              _atualizarItem(
                index,
                item.copyWith(
                  diasUteis: dias,
                  diasCorridos: dias,
                  dataTermino: termino,
                  duracaoSemanas: dias <= 7 ? 1 : (dias / 7).ceil(),
                  status: statusAtualizado,
                ),
              );
            },
          ),

          _cellTexto(
            '${item.diasCorridos}',
            82,
            align: TextAlign.center,
          ),

          _cellTexto(
            item.dataTermino != null ? _formatarData(item.dataTermino!) : '',
            96,
            align: TextAlign.center,
          ),

          _cellTexto(
            item.dataProximaAcao != null
                ? _formatarData(item.dataProximaAcao!)
                : '',
            88,
            align: TextAlign.center,
          ),

          percentualBloqueado
              ? _cellTexto(
            '${item.realizadoPercentual}',
            64,
            align: TextAlign.center,
          )
              : _cellNumeroEditavel(
            valor: item.realizadoPercentual,
            largura: 64,
            onChanged: (valor) {
              final percentual = valor.clamp(0, 100);
              final statusAtualizado = _calcularStatusAutomatico(
                realizadoPercentual: percentual,
                dataTermino: item.dataTermino,
              );

              _atualizarItem(
                index,
                item.copyWith(
                  realizadoPercentual: percentual,
                  status: statusAtualizado,
                ),
              );
            },
          ),

          _cellStatus(item.status, 110),
          _cellAcoes(index, item),
        ],
      ),
    );
  }

  Widget _cellTexto(
      String texto,
      double largura, {
        bool bold = false,
        TextAlign align = TextAlign.left,
      }) {
    return Container(
      width: largura,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment:
      align == TextAlign.left ? Alignment.centerLeft : Alignment.center,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFE2E8F0)),
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Text(
        texto,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: align,
        style: TextStyle(
          fontSize: 12,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _cellAtividade(CronogramaItem item, double largura) {
    final nivel = item.nivel.clamp(1, 4);
    final double recuo = (nivel - 1) * 16.0;

    FontWeight peso;
    Color cor;

    switch (nivel) {
      case 1:
        peso = FontWeight.w700;
        cor = const Color(0xFF111827);
        break;
      case 2:
        peso = FontWeight.w600;
        cor = const Color(0xFF1F2937);
        break;
      case 3:
        peso = FontWeight.w600;
        cor = const Color(0xFF374151);
        break;
      default:
        peso = FontWeight.w400;
        cor = const Color(0xFF4B5563);
        break;
    }

    return Container(
      width: largura,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFE5E7EB)),
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: recuo),
          child: Text(
            item.atividade,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: peso,
              color: cor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _cellAcoes(int index, CronogramaItem item) {
    return Container(
      width: 96,
      height: 48,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFE2E8F0)),
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: 'Editar',
            onPressed: () => _editarItem(index),
            icon: const Icon(Icons.edit_outlined, size: 18),
          ),
          IconButton(
            tooltip: 'Excluir',
            onPressed: item.destaque ? null : () => _excluirItem(index),
            icon: const Icon(Icons.delete_outline, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _cellStatus(String status, double largura) {
    final Color cor = switch (status) {
      'Concluída' => const Color(0xFF027A48),
      'Atenção' => const Color(0xFFB54708),
      _ => const Color(0xFF175CD3),
    };

    final Color fundo = switch (status) {
      'Concluída' => const Color(0xFFECFDF3),
      'Atenção' => const Color(0xFFFFFAEB),
      _ => const Color(0xFFEFF8FF),
    };

    return Container(
      width: largura,
      height: 48,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFE2E8F0)),
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: fundo,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cor.withOpacity(0.22)),
          ),
          child: Text(
            status,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(double larguraSemana) {
    return Column(
      children: [
        Container(
          height: 48,
          color: const Color(0xFFF8FAFC),
          child: Row(
            children: List.generate(
              semanas.length,
                  (index) => Container(
                width: larguraSemana,
                height: 48,
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Color(0xFFD9E2EC)),
                    bottom: BorderSide(color: Color(0xFFD9E2EC)),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _verticalControllerTimeline,
            itemCount: projeto.itens.length,
            itemBuilder: (context, index) {
              final item = projeto.itens[index];
              return _buildLinhaTimeline(item, larguraSemana, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLinhaTimeline(
      CronogramaItem item,
      double larguraSemana,
      int index,
      ) {
    final bg = item.destaque
        ? const Color(0xFFF6FBFF)
        : index.isEven
        ? Colors.white
        : const Color(0xFFFCFDFE);

    final Color barra = switch (item.status) {
      'Concluída' => const Color(0xFF12B76A),
      'Atenção' => const Color(0xFFF79009),
      _ => const Color(0xFF2E90FA),
    };

    final inicioProjeto = projeto.inicio;
    final inicioItem = item.dataInicio;
    final terminoItem = item.dataTermino;

    int semanaInicial = 0;
    int totalSemanasItem = 1;

    if (inicioProjeto != null && inicioItem != null && terminoItem != null) {
      final diasDesdeInicioProjeto =
          inicioItem.difference(inicioProjeto).inDays;

      semanaInicial = (diasDesdeInicioProjeto / 7).floor();

      final duracaoDias =
          terminoItem.difference(inicioItem).inDays + 1;

      totalSemanasItem = (duracaoDias / 7).ceil();

      if (semanaInicial < 0) semanaInicial = 0;
      if (totalSemanasItem < 1) totalSemanasItem = 1;

      if (semanas.isNotEmpty && semanaInicial >= semanas.length) {
        semanaInicial = semanas.length - 1;
      }

      final maxSemanasDisponiveis =
      semanas.isEmpty ? 1 : (semanas.length - semanaInicial);

      if (totalSemanasItem > maxSemanasDisponiveis) {
        totalSemanasItem = maxSemanasDisponiveis;
      }
    }

    final double larguraBarraReal =
    ((totalSemanasItem * larguraSemana) - 12).clamp(12, 99999).toDouble();

    return Container(
      height: 48,
      color: bg,
      child: Stack(
        children: [
          Row(
            children: List.generate(
              semanas.length,
                  (i) => Container(
                width: larguraSemana,
                height: 48,
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Color(0xFFE2E8F0)),
                    bottom: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: semanaInicial * larguraSemana + 6,
            top: 10,
            child: Container(
              width: larguraBarraReal,
              height: 24,
              decoration: BoxDecoration(
                color: barra,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: barra.withOpacity(0.20),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: (larguraBarraReal * (item.realizadoPercentual / 100))
                      .clamp(0, larguraBarraReal),
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirDialogNovaAtividade() async {
    if (projeto.nomeProjeto.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Crie primeiro o cronograma antes de inserir atividades.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final atividadeController = TextEditingController();
    final responsavelController = TextEditingController();

    DateTime? dataInicio;
    int diasUteis = 1;
    int realizado = 0;
    int nivel = 2;
    String status = 'Em andamento';

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nova atividade'),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: nivel,
                      decoration: const InputDecoration(
                        labelText: 'Nível da atividade',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Text('1 - Projeto principal'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('2 - Atividade geral'),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text('3 - Atividade direta'),
                        ),
                        DropdownMenuItem(
                          value: 4,
                          child: Text('4 - Subatividade'),
                        ),
                      ],
                      onChanged: (valor) {
                        if (valor != null) {
                          setDialogState(() {
                            nivel = valor;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: atividadeController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição da atividade',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: responsavelController,
                      decoration: const InputDecoration(
                        labelText: 'Responsável da atividade',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final hoje = DateTime.now();
                              final selecionada = await showDatePicker(
                                context: ctx,
                                initialDate: hoje,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (selecionada != null) {
                                setDialogState(() {
                                  dataInicio = selecionada;
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(
                              dataInicio == null
                                  ? 'Definir início'
                                  : _formatarData(dataInicio!),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: diasUteis,
                            decoration: const InputDecoration(
                              labelText: 'Dias úteis',
                            ),
                            items: List.generate(
                              180,
                                  (index) => DropdownMenuItem<int>(
                                value: index + 1,
                                child: Text('${index + 1}'),
                              ),
                            ),
                            onChanged: (valor) {
                              if (valor != null) {
                                setDialogState(() {
                                  diasUteis = valor;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final descricao = atividadeController.text.trim();
                    if (descricao.isEmpty) return;

                    final inicio = dataInicio ?? DateTime.now();
                    final termino = inicio.add(Duration(days: diasUteis - 1));
                    final diasCorridos = termino.difference(inicio).inDays + 1;

                    final novo = CronogramaItem(
                      id: null,
                      cronogramaId: projeto.id,
                      atividade: descricao,
                      responsavel: responsavelController.text.trim(),
                      dataInicio: inicio,
                      diasUteis: diasUteis,
                      diasCorridos: diasCorridos,
                      dataTermino: termino,
                      dataProximaAcao: null,
                      realizadoPercentual: realizado,
                      status: status,
                      inicioSemana: 0,
                      duracaoSemanas: diasUteis <= 7
                          ? 1
                          : (diasUteis / 7).ceil(),
                      destaque: nivel == 1,
                      nivel: nivel,
                    );

                    final novaLista = [...projeto.itens, novo];

                    setState(() {
                      projeto = projeto.copyWith(itens: novaLista);
                    });

                    Navigator.pop(ctx);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _CellHeader extends StatelessWidget {
  final String titulo;
  final double largura;

  const _CellHeader(this.titulo, this.largura);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: largura,
      height: 48,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFD9E2EC)),
          bottom: BorderSide(color: Color(0xFFD9E2EC)),
        ),
      ),
      child: Text(
        titulo,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF334155),
        ),
      ),
    );
  }
}