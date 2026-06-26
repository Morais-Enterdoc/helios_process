class TimelineEventoItem {
  final String id;
  final String titulo;
  final DateTime inicio;
  final DateTime fim;
  final String tipoOrigem;
  final String descricao;
  final String status;

  const TimelineEventoItem({
    required this.id,
    required this.titulo,
    required this.inicio,
    required this.fim,
    required this.tipoOrigem,
    required this.descricao,
    required this.status,
  });
}

class TimelineItem {
  final String id;
  final String titulo;
  final String cliente;
  final String projeto;
  final String status;
  final String responsavel;
  final DateTime inicio;
  final DateTime fim;
  final int percentual;
  final String descricao;
  final String tipoOrigem;
  final int? origemId;
  final List<TimelineEventoItem> eventos;

  const TimelineItem({
    required this.id,
    required this.titulo,
    required this.cliente,
    required this.projeto,
    required this.status,
    required this.responsavel,
    required this.inicio,
    required this.fim,
    required this.percentual,
    required this.descricao,
    required this.tipoOrigem,
    required this.origemId,
    this.eventos = const [],
  });
}