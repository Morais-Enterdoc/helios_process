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
  TimelineDetalhe? itemSelecionado;
  List<TimelineItem> itens = [];
  bool carregando = true;
  TimelineVisao visaoAtual = TimelineVisao.semana;

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

      print('=== ITENS RECEBIDOS NA TIMELINE PAGE ===');
      for (final item in lista) {
        print('id=${item.id} tipoOrigem=${item.tipoOrigem} origemId=${item.origemId} inicio=${item.inicio} fim=${item.fim}');
      }
      print('========================================');

      final dataInicial = _formatarDataBanco(_inicioPeriodoVisivel);
      final dataFinal = _formatarDataBanco(_fimPeriodoVisivel);

      final agendas = await agendaManualRepository.listarPorPeriodo(
        dataInicial: dataInicial,
        dataFinal: dataFinal,
      );

      if (!mounted) return;

      final itensFiltrados = lista.where((item) {
        final statusNormalizado = item.status.trim().toLowerCase();
        final chamadoFechado = item.tipoOrigem == 'chamado' &&
            (statusNormalizado == 'fechada' || statusNormalizado == 'fechado');

        if (chamadoFechado) return false;

        return _itemEstaNoPeriodoVisivel(item.inicio, item.fim);
      }).toList();

      final eventos = agendas
          .map(_mapAgendaParaEvento)
          .whereType<_TimelineEventoVinculado>()
          .toList();

      print('=== EVENTOS DE AGENDA CARREGADOS ===');
      for (final e in eventos) {
        print('evento="${e.evento.titulo}" tipoVinculo=${e.tipoVinculo} vinculoId=${e.vinculoId}');
      }
      print('====================================');

      print('Itens filtrados pelo período: ${itensFiltrados.length}');
      for (final item in itensFiltrados) {
        print('Filtrado: id=${item.id} tipoOrigem=${item.tipoOrigem} origemId=${item.origemId}');
      }

      setState(() {
        itens = itensFiltrados;
        eventosAgenda = eventos;
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
    final hoje = _normalizarData(DateTime.now());

    switch (visaoAtual) {
      case TimelineVisao.hoje:
        return hoje;
      case TimelineVisao.semana:
        return hoje.subtract(Duration(days: hoje.weekday - 1));
      case TimelineVisao.mes:
        return DateTime(hoje.year, hoje.month, 1);
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

  List<TimelineEvento> _eventosDaLinha(TimelineItem item) {
    final tipoItem = item.tipoOrigem.trim().toLowerCase();
    final origemId = item.origemId;

    return eventosAgenda.where((vinculado) {
      final tipoVinculo = vinculado.tipoVinculo.trim().toLowerCase();

      if (tipoVinculo == 'geral') return false;
      if (vinculado.vinculoId == null || origemId == null) return false;

      switch (tipoVinculo) {
        case 'projeto':
          return tipoItem == 'cronograma' && vinculado.vinculoId == origemId;

        case 'chamado':
          return tipoItem == 'chamado' && vinculado.vinculoId == origemId;

        default:
          return false;
      }
    }).map((e) => e.evento).toList();
  }

  List<TimelineEvento> eventosDaLinha(TimelineItem item) {
    final tipoItem = item.tipoOrigem.trim().toLowerCase();
    final origemId = item.origemId;

    print('--- Checando eventos da linha: id=${item.id} tipoOrigem=$tipoItem origemId=$origemId');

    return eventosAgenda.where((vinculado) {
      final tipoVinculo = vinculado.tipoVinculo.trim().toLowerCase();

      print('  vinculo tipo=$tipoVinculo vinculoId=${vinculado.vinculoId}');

      if (tipoVinculo == 'geral') return false;
      if (vinculado.vinculoId == null || origemId == null) return false;

      switch (tipoVinculo) {
        case 'projeto':
          final okProj = tipoItem == 'cronograma' && vinculado.vinculoId == origemId;
          print('    -> projeto? $okProj');
          return okProj;

        case 'chamado':
          final okCham = tipoItem == 'chamado' && vinculado.vinculoId == origemId;
          print('    -> chamado? $okCham');
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
          children: [
            TimelineFiltroChip(
              label: 'Hoje',
              ativo: visaoAtual == TimelineVisao.hoje,
              onTap: () {
                setState(() => visaoAtual = TimelineVisao.hoje);
                carregarTimeline();
              },
            ),
            TimelineFiltroChip(
              label: 'Semana',
              ativo: visaoAtual == TimelineVisao.semana,
              onTap: () {
                setState(() => visaoAtual = TimelineVisao.semana);
                carregarTimeline();
              },
            ),
            TimelineFiltroChip(
              label: 'Mês',
              ativo: visaoAtual == TimelineVisao.mes,
              onTap: () {
                setState(() => visaoAtual = TimelineVisao.mes);
                carregarTimeline();
              },
            ),
          ],
        ),
      ],
    );
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
    height: 156,
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
                final leftBarra = (inicio - 1) * larguraDia;
                final widthBarra = duracao * larguraDia;

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
                      left: leftBarra + 6,
                      top: 24,
                      child: Container(
                      width: (widthBarra - 12).clamp(56.0, double.infinity),
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: corBarra,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: corBarra.withOpacity(0.22),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.timeline,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$percentual% concluído',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
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

                      final topEvento = 66 + (eventosMesmoDiaAntes * 28);

                      return Positioned(
                        left: leftEvento + 10,
                        top: topEvento.toDouble(),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: larguraDia > 120 ? larguraDia - 16 : larguraDia * 1.8,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: evento.cor.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: evento.cor.withOpacity(0.90),
                            ),
                          ),
                          child: Text(
                            evento.titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
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