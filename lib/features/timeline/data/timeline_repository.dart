import '../../tarefas/data/tarefa_repository.dart';
import '../../tarefas/domain/tarefa_detalhe.dart';
import '../../cronograma/data/cronograma_repository.dart';
import '../../cronograma/domain/cronograma_models.dart';
import '../../chamados/data/chamado_repository.dart';
import '../../chamados/domain/chamado.dart';
import '../domain/timeline_item.dart';
import '../../tarefas/domain/tarefa.dart';

class TimelineRepository {
  final TarefaRepository tarefaRepository;
  final CronogramaRepository cronogramaRepository;
  final ChamadoRepository chamadoRepository;

  TimelineRepository({
    TarefaRepository? tarefaRepository,
    CronogramaRepository? cronogramaRepository,
    ChamadoRepository? chamadoRepository,
  })  : tarefaRepository = tarefaRepository ?? TarefaRepository(),
        cronogramaRepository = cronogramaRepository ?? CronogramaRepository(),
        chamadoRepository = chamadoRepository ?? ChamadoRepository();

  Future<List<TimelineItem>> listarItens() async {
    final tarefas = await tarefaRepository.listarTarefasComCliente();
    final cronogramas = await cronogramaRepository.listarCronogramas();
    final chamados = await chamadoRepository.listarChamados();

    print('=== TAREFAS PARA TIMELINE ===');
    for (final t in tarefas) {
      print(
        'id=${t.tarefa.id} origemTipo=${t.tarefa.origemTipo} origemId=${t.tarefa.origemId} chamadoRef=${t.tarefa.chamadoRef}',
      );
    }
    print('=============================');

    final itens = <TimelineItem>[
      ...tarefas
          .where(_tarefaDeveEntrarNaTimeline)
          .map(_mapTarefaParaTimeline),
      ...cronogramas.map(_mapCronogramaParaTimeline),
      ...chamados.map(_mapChamadoParaTimeline),
    ];

    print('=== ITENS MONTADOS PARA TIMELINE ===');
    for (final item in itens) {
      print(
        'TimelineItem: id=${item.id} tipoOrigem=${item.tipoOrigem} origemId=${item.origemId} titulo=${item.titulo}',
      );
    }
    print('====================================');

    itens.sort((a, b) => a.inicio.compareTo(b.inicio));
    return itens;
  }

  bool _tarefaDeveEntrarNaTimeline(TarefaDetalhe item) {
    final origemTipo = (item.tarefa.origemTipo ?? '').trim().toLowerCase();

    // Projeto pode chegar como "cronograma" ou "projeto".
    if (origemTipo == 'cronograma' || origemTipo == 'projeto') {
      return item.tarefa.origemId != null;
    }

    // Para chamado, aceitamos:
    // - origemId preenchido, ou
    // - chamadoRef preenchido, que será convertido em origemId no mapeamento.
    if (origemTipo == 'chamado') {
      final chamadoRefTexto = (item.tarefa.chamadoRef ?? '').trim();
      final chamadoRefNumero = int.tryParse(chamadoRefTexto);

      return item.tarefa.origemId != null || chamadoRefNumero != null;
    }

    return false;
  }

  TimelineItem _mapTarefaParaTimeline(TarefaDetalhe item) {
    final tarefa = item.tarefa;

    DateTime inicio;
    DateTime fim;

    try {
      final data = _parseDataBr(tarefa.data);
      final horaIni = _parseHora(tarefa.horaInicio);
      final horaFi = _parseHora(tarefa.horaFim);

      inicio = DateTime(
        data.year,
        data.month,
        data.day,
        horaIni.$1,
        horaIni.$2,
      );

      fim = DateTime(
        data.year,
        data.month,
        data.day,
        horaFi.$1,
        horaFi.$2,
      );
    } catch (_) {
      inicio = DateTime.now();
      fim = DateTime.now().add(const Duration(hours: 1));
    }

    final origemTipoNormalizada =
    (tarefa.origemTipo ?? 'geral').trim().toLowerCase();

    final origemIdResolvido = origemTipoNormalizada == 'chamado'
        ? (tarefa.origemId ??
        int.tryParse((tarefa.chamadoRef ?? '').trim()))
        : tarefa.origemId;

    return TimelineItem(
      id: 'tarefa_${tarefa.id ?? 0}',
      titulo: tarefa.titulo,
      cliente: item.clienteNome ?? tarefa.clienteNomeRef ?? 'Sem cliente',
      projeto: _montarProjetoTarefa(tarefa),
      status: tarefa.status,
      responsavel: '-',
      inicio: inicio,
      fim: fim,
      percentual: _mapPercentual(tarefa.status),
      descricao: tarefa.descricao.isNotEmpty
          ? tarefa.descricao
          : (tarefa.observacoes ?? '-'),
      tipoOrigem: origemTipoNormalizada == 'projeto'
          ? 'cronograma'
          : origemTipoNormalizada,
      origemId: origemIdResolvido,
    );
  }

  String _montarProjetoTarefa(Tarefa tarefa) {
    final origemTipo = (tarefa.origemTipo ?? '').trim().toLowerCase();

    if (origemTipo == 'cronograma') {
      final projeto = (tarefa.projetoRef ?? '').trim();
      return projeto.isNotEmpty ? projeto : 'Projeto do cronograma';
    }

    if (origemTipo == 'chamado') {
      final chamado = (tarefa.chamadoRef ?? '').trim();
      return chamado.isNotEmpty ? 'Chamado $chamado' : 'Chamado M&O';
    }

    return 'Tarefa';
  }

  TimelineItem _mapCronogramaParaTimeline(CronogramaProjeto projeto) {
    final inicio = projeto.inicio ?? DateTime.now();

    DateTime fim;
    if (projeto.termino == null) {
      fim = inicio;
    } else {
      final terminoNormalizado = DateTime(
        projeto.termino!.year,
        projeto.termino!.month,
        projeto.termino!.day,
        projeto.termino!.hour,
        projeto.termino!.minute,
      );

      fim = terminoNormalizado.isBefore(inicio) ? inicio : terminoNormalizado;
    }

    return TimelineItem(
      id: 'cronograma_${projeto.id ?? 0}',
      titulo: projeto.nomeProjeto,
      cliente: (projeto.clienteNome ?? '').isNotEmpty
          ? projeto.clienteNome!
          : 'Sem cliente',
      projeto: (projeto.setorNome ?? '').isNotEmpty
          ? projeto.setorNome!
          : 'Cronograma',
      status: projeto.status,
      responsavel: projeto.responsavel.isNotEmpty ? projeto.responsavel : '-',
      inicio: inicio,
      fim: fim,
      percentual: projeto.realizadoPercentual,
      descricao: 'Cronograma do projeto ${projeto.nomeProjeto}',
      tipoOrigem: 'cronograma',
      origemId: projeto.id,
    );
  }

  TimelineItem _mapChamadoParaTimeline(Chamado chamado) {
    final inicio = _parseDataGenerica(chamado.dataAbertura);
    final fim = _parseDataGenerica(chamado.prazoEntrega);

    final statusTimeline =
    chamado.meuStatus.isNotEmpty ? chamado.meuStatus : chamado.status;

    final projetoTexto = [
      if (chamado.ticket.isNotEmpty) 'Chamado ${chamado.ticket}',
      if (chamado.numeroRo.isNotEmpty) 'RO ${chamado.numeroRo}',
    ].join(' • ');

    return TimelineItem(
      id: 'chamado_${chamado.id ?? 0}',
      titulo: chamado.assunto.isNotEmpty
          ? chamado.assunto
          : 'Chamado ${chamado.ticket}',
      cliente: chamado.cliente.isNotEmpty ? chamado.cliente : 'Sem cliente',
      projeto: projetoTexto.isNotEmpty
          ? projetoTexto
          : (chamado.servico.isNotEmpty ? chamado.servico : 'Chamado'),
      status: statusTimeline,
      responsavel: chamado.agenteAtual.isNotEmpty ? chamado.agenteAtual : '-',
      inicio: inicio,
      fim: fim.isBefore(inicio)
          ? inicio.add(const Duration(days: 60))
          : fim,
      percentual: _mapPercentual(statusTimeline),
      descricao: chamado.descricao.isNotEmpty
          ? chamado.descricao
          : (chamado.anotacoes.isNotEmpty ? chamado.anotacoes : '-'),
      tipoOrigem: 'chamado',
      origemId: chamado.id,
    );
  }

  DateTime _parseDataGenerica(String valor) {
    final texto = valor.trim();

    if (texto.isEmpty) return DateTime.now();

    try {
      return DateTime.parse(texto);
    } catch (_) {}

    try {
      return _parseDataBr(texto);
    } catch (_) {}

    return DateTime.now();
  }

  DateTime _parseDataBr(String value) {
    final partes = value.split('/');
    if (partes.length != 3) {
      throw FormatException('Data inválida: $value');
    }

    return DateTime(
      int.parse(partes[2]),
      int.parse(partes[1]),
      int.parse(partes[0]),
    );
  }

  (int, int) _parseHora(String value) {
    final partes = value.split(':');
    if (partes.length < 2) {
      throw FormatException('Hora inválida: $value');
    }

    return (int.parse(partes[0]), int.parse(partes[1]));
  }

  int _mapPercentual(String status) {
    switch (status.trim().toLowerCase()) {
      case 'fechado':
      case 'fechada':
      case 'concluído':
      case 'concluido':
        return 100;
      case 'homologação':
        return 85;
      case 'em andamento':
      case 'em análise':
      case 'em analise':
        return 65;
      case 'pausada':
        return 45;
      case 'planejada':
      default:
        return 15;
    }
  }
}