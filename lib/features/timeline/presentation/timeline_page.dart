import 'package:flutter/material.dart';
import '../data/timeline_repository.dart';
import '../domain/timeline_item.dart';
import '../../agenda/data/agenda_manual_repository.dart';
import '../../agenda/domain/agenda_manual.dart';


class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

enum TimelineVisao { hoje, semana, mes }

class _TimelineEventoVinculado {
  final TimelineEvento evento;
  final String tipoVinculo;
  final int? vinculoId;

  const _TimelineEventoVinculado({
    required this.evento,
    required this.tipoVinculo,
    required this.vinculoId,
  });
}

class _TimelinePageState extends State<TimelinePage> {
  final TimelineRepository timelineRepository = TimelineRepository();
  final AgendaManualRepository agendaManualRepository = AgendaManualRepository();

  List<_TimelineEventoVinculado> eventosAgenda = [];
  List<_TimelineEventoVinculado> eventosTarefas = [];
  TimelineDetalhe? itemSelecionado;
  List itens = [];
  bool carregando = true;
  TimelineVisao visaoAtual = TimelineVisao.semana;
  DateTime dataReferencia = DateTime.now();

  @override
  void initState() {
    super.initState();
    carregarTimeline();
  }

  Future<void> carregarTimeline() async {
    setState(() {
      carregando = true;
    });

    try {
      final lista = await timelineRepository.listarItens();

      final dataInicial = _formatarDataBanco(_inicioPeriodoVisivel);
      final dataFinal = _formatarDataBanco(_fimPeriodoVisivel);

      final agendas = await agendaManualRepository.listarPorPeriodo(
        dataInicial: dataInicial,
        dataFinal: dataFinal,
      );

      if (!mounted) return;

      final itensFiltrados = lista.where((item) {
        final statusNormalizado = item.status.trim().toLowerCase();
        final tipoOrigemNormalizado = item.tipoOrigem.trim().toLowerCase();
        final idTexto = item.id.toString().toLowerCase();

        final chamadoFechado = tipoOrigemNormalizado == 'chamado' &&
            (statusNormalizado == 'fechada' || statusNormalizado == 'fechado');

        if (chamadoFechado) return false;

        final ehLinhaDeTarefa = idTexto.startsWith('tarefa_');
        if (ehLinhaDeTarefa) {
          return false;
        }

        final ehLinhaDeProjeto = tipoOrigemNormalizado == 'cronograma' &&
            item.id.toString().toLowerCase().startsWith('cronograma_');

        final estaNoPeriodo = _itemEstaNoPeriodoVisivel(item.inicio, item.fim);

        if (ehLinhaDeProjeto) {
          final temTarefaVinculada = lista.any((outro) {
            final outroId = outro.id.toString().toLowerCase();
            return outroId.startsWith('tarefa_') &&
                outro.tipoOrigem.trim().toLowerCase() == 'cronograma' &&
                outro.origemId == item.origemId;
          });

          print(
            'LINHA_PROJETO -> '
                'id=${item.id} | origemId=${item.origemId} | titulo=${item.titulo} | '
                'ehLinhaDeProjeto=$ehLinhaDeProjeto | temTarefaVinculada=$temTarefaVinculada | '
                'estaNoPeriodo=$estaNoPeriodo',
          );

          return estaNoPeriodo;
        }

        return estaNoPeriodo;
      }).toList();

      final eventos = agendas
          .map(_mapAgendaParaEvento)
          .whereType<_TimelineEventoVinculado>()
          .toList();

      final eventosDasTarefas = lista
          .where((item) => item.id.toString().startsWith('tarefa_'))
          .map(_mapTarefaParaEvento)
          .whereType<_TimelineEventoVinculado>()
          .toList();

      print('=== EVENTOS DE TAREFAS CARREGADOS ===');
      for (final e in eventosDasTarefas) {
        print(
          'evento="${e.evento.titulo}" tipoVinculo=${e.tipoVinculo} vinculoId=${e.vinculoId} dia=${e.evento.dia}',
        );
      }
      print('=====================================');

      print('Itens filtrados pelo período: ${itensFiltrados.length}');
      for (final item in itensFiltrados) {
        print('Filtrado: id=${item.id} tipoOrigem=${item.tipoOrigem} origemId=${item.origemId}');
      }

      setState(() {
        itens = itensFiltrados;
        eventosAgenda = eventos;
        eventosTarefas = eventosDasTarefas;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar timeline: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  bool _itemEstaNaSemanaAtual(DateTime inicio, DateTime fim) {
    final inicioSemana = _inicioSemanaAtual;
    final fimSemana = inicioSemana.add(const Duration(days: 6));

    final inicioNormalizado = DateTime(inicio.year, inicio.month, inicio.day);
    final fimNormalizado = DateTime(fim.year, fim.month, fim.day);

    return !fimNormalizado.isBefore(inicioSemana) &&
        !inicioNormalizado.isAfter(fimSemana);
  }

  DateTime _normalizarData(DateTime data) {
    return DateTime(data.year, data.month, data.day);
  }

  DateTime get _inicioPeriodoVisivel {
    final base = _normalizarData(dataReferencia);

    switch (visaoAtual) {
      case TimelineVisao.hoje:
        return base;
      case TimelineVisao.semana:
        return base.subtract(Duration(days: base.weekday - 1));
      case TimelineVisao.mes:
        return DateTime(base.year, base.month, 1);
    }
  }

  DateTime get _fimPeriodoVisivel {
    switch (visaoAtual) {
      case TimelineVisao.hoje:
        return _inicioPeriodoVisivel;
      case TimelineVisao.semana:
        return _inicioPeriodoVisivel.add(const Duration(days: 6));
      case TimelineVisao.mes:
        final inicio = _inicioPeriodoVisivel;
        return DateTime(inicio.year, inicio.month + 1, 0);
    }
  }

  void _moverPeriodo(int direcao) {
    setState(() {
      switch (visaoAtual) {
        case TimelineVisao.hoje:
          dataReferencia = dataReferencia.add(Duration(days: direcao));
          break;
        case TimelineVisao.semana:
          dataReferencia = dataReferencia.add(Duration(days: 7 * direcao));
          break;
        case TimelineVisao.mes:
          dataReferencia = DateTime(
            dataReferencia.year,
            dataReferencia.month + direcao,
            dataReferencia.day,
          );
          break;
      }
    });

    carregarTimeline();
  }

  void _irParaHoje() {
    setState(() {
      dataReferencia = DateTime.now();
    });

    carregarTimeline();
  }

  List<TimelineEvento> _eventosDaLinha(TimelineItem item) {
    final tipoItem = item.tipoOrigem.trim().toLowerCase();
    final origemId = item.origemId;

    print('item.id=${item.id}');
    print('item.tipoOrigem=$tipoItem');
    print('item.origemId=$origemId');

    final todosEventos = [...eventosAgenda, ...eventosTarefas];

    return todosEventos.where((vinculado) {
      final tipoVinculo = vinculado.tipoVinculo.trim().toLowerCase();


      if (tipoVinculo == 'geral') return false;
      if (vinculado.vinculoId == null || origemId == null) return false;

      switch (tipoVinculo) {
        case 'projeto':
        case 'cronograma':
          final okProj =
              tipoItem == 'cronograma' && vinculado.vinculoId == origemId;
          print(
            '    -> projeto/cronograma? $okProj '
                '(tipoItem=$tipoItem, vinculoId=${vinculado.vinculoId}, origemId=$origemId, tituloLinha=${item.titulo})',
          );
          return okProj;

        case 'chamado':
          final okCham =
              tipoItem == 'chamado' && vinculado.vinculoId == origemId;

          print(
            ' -> chamado? $okCham '
                '(tipoItem=$tipoItem, vinculoId=${vinculado.vinculoId}, origemId=$origemId, tituloLinha=${item.titulo})',
          );

          return okCham;

        default:
          return false;
      }
    }).map((e) => e.evento).toList();
  }


  List<DateTime> get _diasPeriodoVisivel {
    final inicio = _inicioPeriodoVisivel;
    final fim = _fimPeriodoVisivel;
    final totalDias = fim.difference(inicio).inDays + 1;

    return List.generate(totalDias, (index) {
      return inicio.add(Duration(days: index));
    });
  }

  String _formatarDataBanco(DateTime data) {
    final ano = data.year.toString().padLeft(4, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final dia = data.day.toString().padLeft(2, '0');
    return '$ano-$mes-$dia';
  }

  _TimelineEventoVinculado? _mapAgendaParaEvento(AgendaManual agenda) {
    try {
      final data = _parseDataAgenda(agenda.data);
      if (!_itemEstaNoPeriodoVisivel(data, data)) return null;

      return _TimelineEventoVinculado(
        tipoVinculo: agenda.tipoVinculo,
        vinculoId: agenda.vinculoId,
        evento: TimelineEvento(
          agenda.titulo,
          _calcularInicioNoPeriodo(data),
          _parseCorHex(agenda.cor),
        ),
      );
    } catch (_) {
      return null;
    }
  }_TimelineEventoVinculado? _mapTarefaParaEvento(TimelineItem item) {
    try {
      final tipoOrigem = item.tipoOrigem.trim().toLowerCase();
      final origemId = item.origemId;

      if (origemId == null) return null;
      if (tipoOrigem != 'cronograma' && tipoOrigem != 'chamado') return null;
      if (!_itemEstaNoPeriodoVisivel(item.inicio, item.fim)) return null;

      final tipoVinculo = tipoOrigem == 'cronograma' ? 'projeto' : 'chamado';

      return _TimelineEventoVinculado(
          tipoVinculo: tipoVinculo,
          vinculoId: origemId,
          evento: TimelineEvento(
          item.titulo,
          _calcularInicioNoPeriodo(item.inicio),
          const Color(0xFFFDE68A),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  DateTime _parseDataAgenda(String valor) {
    final texto = valor.trim();

    if (texto.contains('/')) {
      final partes = texto.split('/');
      return DateTime(
        int.parse(partes[2]),
        int.parse(partes[1]),
        int.parse(partes[0]),
      );
    }

    return DateTime.parse(texto);
  }

  Color _parseCorHex(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return const Color(0xFFDBEAFE);
    }

    var hex = valor.trim().replaceAll('#', '');

    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    return Color(int.parse(hex, radix: 16));
  }

  String _nomeDiaSemanaCurto(DateTime data) {
    const nomes = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return nomes[data.weekday - 1];
  }

  String _formatarDiaMes(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes';
  }

  bool _itemEstaNoPeriodoVisivel(DateTime inicio, DateTime fim) {
    final inicioPeriodo = _inicioPeriodoVisivel;
    final fimPeriodo = _fimPeriodoVisivel;

    final inicioNormalizado = _normalizarData(inicio);
    final fimNormalizado = _normalizarData(fim);

    return !fimNormalizado.isBefore(inicioPeriodo) &&
        !inicioNormalizado.isAfter(fimPeriodo);
  }

  int _calcularInicioNoPeriodo(DateTime data) {
    final inicioPeriodo = _inicioPeriodoVisivel;
    final fimPeriodo = _fimPeriodoVisivel;
    final dataNormalizada = _normalizarData(data);

    if (dataNormalizada.isBefore(inicioPeriodo)) return 1;
    if (dataNormalizada.isAfter(fimPeriodo)) return _diasPeriodoVisivel.length;

    return dataNormalizada.difference(inicioPeriodo).inDays + 1;
  }

  int _calcularDuracaoNoPeriodo(DateTime inicio, DateTime fim) {
    final inicioPeriodo = _inicioPeriodoVisivel;
    final fimPeriodo = _fimPeriodoVisivel;

    final inicioNormalizado = _normalizarData(inicio);
    final fimNormalizado = _normalizarData(fim);

    final inicioAjustado =
    inicioNormalizado.isBefore(inicioPeriodo) ? inicioPeriodo : inicioNormalizado;
    final fimAjustado =
    fimNormalizado.isAfter(fimPeriodo) ? fimPeriodo : fimNormalizado;

    final diferenca = fimAjustado.difference(inicioAjustado).inDays + 1;

    if (diferenca <= 0) return 1;
    return diferenca;
  }

  double get _larguraColunaBase {
    switch (visaoAtual) {
      case TimelineVisao.hoje:
        return 180;
      case TimelineVisao.semana:
        return 96;
      case TimelineVisao.mes:
        return 44;
    }
  }

  double get _larguraColunaEsquerda => 320;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 18),
            _buildLegenda(),
            const SizedBox(height: 18),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final larguraMinima =
                              _larguraColunaEsquerda + (_diasPeriodoVisivel.length * _larguraColunaBase);

                          final larguraTotal = visaoAtual == TimelineVisao.mes
                              ? larguraMinima
                              : (constraints.maxWidth > larguraMinima
                              ? constraints.maxWidth
                              : larguraMinima);

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: larguraTotal,
                              child: Column(
                                children: [
                                  _buildTopoCalendario(),
                                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                                  Expanded(
                                    child: carregando
                                        ? const Center(child: CircularProgressIndicator())
                                        : itens.isEmpty
                                        ? const Center(
                                      child: Text(
                                        'Nenhum item encontrado para a timeline.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    )
                                        : ListView.separated(
                                      padding: const EdgeInsets.all(14),
                                      itemCount: itens.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final item = itens[index];

                                        return TimelineLinhaCard(
                                          titulo: item.titulo,
                                          subtitulo: '${item.cliente} • ${item.projeto} • ${_statusVisual(item)}',
                                          responsavel: item.responsavel,
                                          inicio: _calcularInicioNoPeriodo(item.inicio),
                                          duracao: _calcularDuracaoNoPeriodo(item.inicio, item.fim),
                                          totalColunas: _diasPeriodoVisivel.length,
                                          corBarra: _corPorRegra(item),
                                          percentual: item.percentual,
                                          eventos: _eventosDaLinha(item),
                                          larguraColunaEsquerda: _larguraColunaEsquerda,
                                          onTap: () {
                                            setState(() {
                                              itemSelecionado = TimelineDetalhe(
                                                titulo: item.titulo,
                                                cliente: item.cliente,
                                                projeto: item.projeto,
                                                status: item.status,
                                                responsavel: item.responsavel,
                                                inicio: _formatarDataHora(item.inicio),
                                                fim: _formatarDataHora(item.fim),
                                                descricao: item.descricao,
                                              );
                                            });
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (itemSelecionado != null) ...[
                    const SizedBox(width: 18),
                    Container(
                      width: 320,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Detalhes',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      itemSelecionado = null;
                                    });
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildCampoDetalhe('Título', itemSelecionado!.titulo),
                            const SizedBox(height: 12),
                            _buildCampoDetalhe('Cliente', itemSelecionado!.cliente),
                            const SizedBox(height: 12),
                            _buildCampoDetalhe('Projeto', itemSelecionado!.projeto),
                            const SizedBox(height: 12),
                            _buildCampoDetalhe('Status', itemSelecionado!.status),
                            const SizedBox(height: 12),
                            _buildCampoDetalhe('Responsável', itemSelecionado!.responsavel),
                            const SizedBox(height: 12),
                            _buildCampoDetalhe('Início', itemSelecionado!.inicio),
                            const SizedBox(height: 12),
                            _buildCampoDetalhe('Fim', itemSelecionado!.fim),
                            const SizedBox(height: 12),
                            _buildCampoDetalhe('Descrição', itemSelecionado!.descricao),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calcularInicioNaSemana(DateTime data) {
    final inicioSemana = _inicioSemanaAtual;
    final fimSemana = inicioSemana.add(const Duration(days: 6));

    final dataNormalizada = DateTime(data.year, data.month, data.day);

    if (dataNormalizada.isBefore(inicioSemana)) return 1;
    if (dataNormalizada.isAfter(fimSemana)) return 7;

    return dataNormalizada.weekday;
  }

  int _calcularDuracaoNaSemana(DateTime inicio, DateTime fim) {
    final inicioSemana = _inicioSemanaAtual;
    final fimSemana = inicioSemana.add(const Duration(days: 6));

    final inicioNormalizado = DateTime(inicio.year, inicio.month, inicio.day);
    final fimNormalizado = DateTime(fim.year, fim.month, fim.day);

    final inicioAjustado =
    inicioNormalizado.isBefore(inicioSemana) ? inicioSemana : inicioNormalizado;
    final fimAjustado =
    fimNormalizado.isAfter(fimSemana) ? fimSemana : fimNormalizado;

    final diferenca = fimAjustado.difference(inicioAjustado).inDays + 1;

    if (diferenca <= 0) return 1;
    if (diferenca > 7) return 7;
    return diferenca;
  }

  String _statusVisual(TimelineItem item) {
    final hoje = _normalizarData(DateTime.now());
    final fim = _normalizarData(item.fim);
    final percentual = item.percentual.toDouble();

    if (percentual >= 100) {
      return 'Concluída';
    }

    if (percentual < 1) {
      return fim.isBefore(hoje) ? 'Atrasado' : 'Futura';
    }

    return 'Em andamento';
  }

  Color _corPorRegra(TimelineItem item) {
    switch (_statusVisual(item)) {
      case 'Concluída':
        return const Color(0xFF059669);
      case 'Atrasado':
        return const Color(0xFFDC2626);
      case 'Futura':
        return const Color(0xFFE5E7EB);
      case 'Em andamento':
      default:
        return const Color(0xFF2563EB);
    }
  }

  String _formatarDataHora(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$ano $hora:$minuto';
  }

  DateTime get _inicioSemanaAtual {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    return hoje.subtract(Duration(days: hoje.weekday - 1));
  }

  List<DateTime> get _diasSemanaAtual {
    final inicio = _inicioSemanaAtual;
    return List.generate(7, (index) => inicio.add(Duration(days: index)));
  }


  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Timeline Operacional',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Visualize demandas, projetos, reuniões e atividades em uma única linha do tempo.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildSetaNavegacao(
              icone: Icons.chevron_left,
              onTap: () => _moverPeriodo(-1),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD1D5DB)),
              ),
              child: Text(
                _tituloPeriodoAtual(),
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            TimelineFiltroChip(
              label: 'Hoje',
              ativo: visaoAtual == TimelineVisao.hoje,
              onTap: () {
                setState(() {
                  visaoAtual = TimelineVisao.hoje;
                  dataReferencia = DateTime.now();
                });
                carregarTimeline();
              },
            ),
            TimelineFiltroChip(
              label: 'Semana',
              ativo: visaoAtual == TimelineVisao.semana,
              onTap: () {
                setState(() {
                  visaoAtual = TimelineVisao.semana;
                });
                carregarTimeline();
              },
            ),
            TimelineFiltroChip(
              label: 'Mês',
              ativo: visaoAtual == TimelineVisao.mes,
              onTap: () {
                setState(() {
                  visaoAtual = TimelineVisao.mes;
                });
                carregarTimeline();
              },
            ),
            _buildSetaNavegacao(
              icone: Icons.chevron_right,
              onTap: () => _moverPeriodo(1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSetaNavegacao({
    required IconData icone,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD1D5DB)),
          ),
          child: Icon(
            icone,
            size: 20,
            color: const Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  String _tituloPeriodoAtual() {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    switch (visaoAtual) {
      case TimelineVisao.hoje:
        final data = _inicioPeriodoVisivel;
        return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';

      case TimelineVisao.semana:
        final inicio = _inicioPeriodoVisivel;
        final fim = _fimPeriodoVisivel;
        return '${inicio.day.toString().padLeft(2, '0')}/${inicio.month.toString().padLeft(2, '0')} até ${fim.day.toString().padLeft(2, '0')}/${fim.month.toString().padLeft(2, '0')}/${fim.year}';

      case TimelineVisao.mes:
        final inicio = _inicioPeriodoVisivel;
        return '${meses[inicio.month - 1]} de ${inicio.year}';
    }
  }

  Widget _buildLegenda() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: const [
        TimelineStatusLegenda(
          label: 'Futura',
          color: Color(0xFFE5E7EB),
          textColor: Color(0xFF4B5563),
        ),
        TimelineStatusLegenda(
          label: 'Em andamento',
          color: Color(0xFFDBEAFE),
          textColor: Color(0xFF1D4ED8),
        ),
        TimelineStatusLegenda(
          label: 'Concluída',
          color: Color(0xFFDCFCE7),
          textColor: Color(0xFF047857),
        ),
        TimelineStatusLegenda(
          label: 'Atrasado',
          color: Color(0xFFFEE2E2),
          textColor: Color(0xFFB91C1C),
        ),
      ],
    );
  }

  Widget _buildTopoCalendario() {
    final diasSemana = _diasPeriodoVisivel;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Row(
        children: [
          Container(
            width: _larguraColunaEsquerda,
            alignment: Alignment.centerLeft,
            child: const Text(
              'Cliente / Projeto',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151),
              ),
            ),
          ),
          ...diasSemana.map((data) {
            return Expanded(
              child: Center(
                child: visaoAtual == TimelineVisao.mes
                    ? Text(
                  data.day.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                    fontSize: 13,
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      visaoAtual == TimelineVisao.hoje
                          ? 'Hoje'
                          : _nomeDiaSemanaCurto(data),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatarDiaMes(data),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCampoDetalhe(String label, String valor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}


class TimelineLinhaCard extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final String responsavel;
  final int inicio;
  final int duracao;
  final int totalColunas;
  final Color corBarra;
  final int percentual;
  final List<TimelineEvento> eventos;
  final double larguraColunaEsquerda;
  final VoidCallback? onTap;

  const TimelineLinhaCard({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.responsavel,
    required this.inicio,
    required this.duracao,
    required this.totalColunas,
    required this.corBarra,
    required this.percentual,
    required this.eventos,
    required this.larguraColunaEsquerda,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
        borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            height: 118,
            decoration: BoxDecoration(
              color: const Color(0xFFFCFDFE),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
            width: larguraColunaEsquerda,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.2,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Responsável: $responsavel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4B5563),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final larguraDia = constraints.maxWidth / totalColunas;

                final inicioAjustado = inicio < 1 ? 1 : inicio;

                // Garante que a barra nunca ultrapasse o total de colunas visíveis.
                final espacoDisponivel = totalColunas - inicioAjustado + 1;
                final duracaoAjustada = duracao < 1
                    ? 1
                    : (duracao > espacoDisponivel ? espacoDisponivel : duracao);

                final leftBarra = (inicioAjustado - 1) * larguraDia;
                final widthBarra = duracaoAjustada * larguraDia;

                return Stack(
                  children: [
                    Row(
                      children: List.generate(
                        totalColunas,
                            (index) => Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: index == 1 || index == 4
                                  ? const Color(0xFFF8FBFF)
                                  : Colors.transparent,
                              border: Border(
                                left: BorderSide(
                                  color: index == 0
                                      ? Colors.transparent
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: leftBarra + 4,
                      top: 14,
                      child: Container(
                        width: (widthBarra - 8).clamp(56.0, double.infinity),
                        height: 74,
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                        decoration: BoxDecoration(
                          color: corBarra.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: corBarra.withOpacity(0.35),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.topLeft,
                        child: Text(
                          '$percentual% concluído',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: corBarra,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    ...eventos.asMap().entries.map((entry) {
                      final index = entry.key;
                      final evento = entry.value;

                      final leftEvento = (evento.dia - 1) * larguraDia;
                      final eventosMesmoDiaAntes = eventos
                          .take(index)
                          .where((item) => item.dia == evento.dia)
                          .length;

                      // Agora os eventos ficam DENTRO da área da barra principal.
                      final topEvento = 58 + (eventosMesmoDiaAntes * 22);

                      return Positioned(
                        left: leftEvento + 8,
                        top: topEvento.toDouble(),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: larguraDia > 120 ? larguraDia - 16 : larguraDia * 1.35,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: evento.cor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF9CA3AF),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            evento.titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
        ),
    );
  }
}

class TimelineEvento {
  final String titulo;
  final int dia;
  final Color cor;

  const TimelineEvento(this.titulo, this.dia, this.cor);
}

class TimelineDetalhe {
  final String titulo;
  final String cliente;
  final String projeto;
  final String status;
  final String responsavel;
  final String inicio;
  final String fim;
  final String descricao;

  const TimelineDetalhe({
    required this.titulo,
    required this.cliente,
    required this.projeto,
    required this.status,
    required this.responsavel,
    required this.inicio,
    required this.fim,
    required this.descricao,
  });
}

class TimelineFiltroChip extends StatelessWidget {
  final String label;
  final bool ativo;
  final VoidCallback? onTap;

  const TimelineFiltroChip({
    super.key,
    required this.label,
    this.ativo = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: ativo ? const Color(0xFF1D4ED8) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ativo
                  ? const Color(0xFF1D4ED8)
                  : const Color(0xFFD1D5DB),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: ativo ? Colors.white : const Color(0xFF374151),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class TimelineStatusLegenda extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const TimelineStatusLegenda({
    super.key,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}