class Tarefa {
  final int? id;
  final int? clienteId;
  final String? origemTipo;
  final int? origemId;
  final String? clienteNomeRef;
  final String? projetoRef;
  final String? chamadoRef;
  final String titulo;
  final String descricao;
  final String data;
  final String horaInicio;
  final String horaFim;
  final String status;
  final int tempoAcumuladoSegundos;
  final String? iniciadaEm;
  final String? encerradaEm;
  final String? observacoes;
  final bool sincronizadaAgendaExterna;
  final String origem;
  final String? eventoExternoId;
  final String? cor;
  final String createdAt;
  final String updatedAt;

  const Tarefa({
    this.id,
    this.clienteId,
    this.origemTipo,
    this.origemId,
    this.clienteNomeRef,
    this.projetoRef,
    this.chamadoRef,
    required this.titulo,
    required this.descricao,
    required this.data,
    required this.horaInicio,
    required this.horaFim,
    required this.status,
    required this.tempoAcumuladoSegundos,
    this.iniciadaEm,
    this.encerradaEm,
    this.observacoes,
    required this.sincronizadaAgendaExterna,
    required this.origem,
    this.eventoExternoId,
    this.cor,
    required this.createdAt,
    required this.updatedAt,
  });

  Tarefa copyWith({
    int? id,
    int? clienteId,
    String? origemTipo,
    int? origemId,
    String? clienteNomeRef,
    String? projetoRef,
    String? chamadoRef,
    String? titulo,
    String? descricao,
    String? data,
    String? horaInicio,
    String? horaFim,
    String? status,
    int? tempoAcumuladoSegundos,
    String? iniciadaEm,
    String? encerradaEm,
    String? observacoes,
    bool? sincronizadaAgendaExterna,
    String? origem,
    String? eventoExternoId,
    String? cor,
    String? createdAt,
    String? updatedAt,
  }) {
    return Tarefa(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      origemTipo: origemTipo ?? this.origemTipo,
      origemId: origemId ?? this.origemId,
      clienteNomeRef: clienteNomeRef ?? this.clienteNomeRef,
      projetoRef: projetoRef ?? this.projetoRef,
      chamadoRef: chamadoRef ?? this.chamadoRef,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      data: data ?? this.data,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFim: horaFim ?? this.horaFim,
      status: status ?? this.status,
      tempoAcumuladoSegundos:
      tempoAcumuladoSegundos ?? this.tempoAcumuladoSegundos,
      iniciadaEm: iniciadaEm ?? this.iniciadaEm,
      encerradaEm: encerradaEm ?? this.encerradaEm,
      observacoes: observacoes ?? this.observacoes,
      sincronizadaAgendaExterna:
      sincronizadaAgendaExterna ?? this.sincronizadaAgendaExterna,
      origem: origem ?? this.origem,
      eventoExternoId: eventoExternoId ?? this.eventoExternoId,
      cor: cor ?? this.cor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'origem_tipo': origemTipo,
      'origem_id': origemId,
      'cliente_nome_ref': clienteNomeRef,
      'projeto_ref': projetoRef,
      'chamado_ref': chamadoRef,
      'titulo': titulo,
      'descricao': descricao,
      'data': data,
      'hora_inicio': horaInicio,
      'hora_fim': horaFim,
      'status': status,
      'tempo_acumulado_segundos': tempoAcumuladoSegundos,
      'iniciada_em': iniciadaEm,
      'encerrada_em': encerradaEm,
      'observacoes': observacoes,
      'sincronizada_agenda_externa': sincronizadaAgendaExterna ? 1 : 0,
      'origem': origem,
      'evento_externo_id': eventoExternoId,
      'cor': cor,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'] as int?,
      clienteId: map['cliente_id'] as int?,
      origemTipo: map['origem_tipo']?.toString(),
      origemId: map['origem_id'] as int?,
      clienteNomeRef: map['cliente_nome_ref']?.toString(),
      projetoRef: map['projeto_ref']?.toString(),
      chamadoRef: map['chamado_ref']?.toString(),
      titulo: (map['titulo'] ?? '').toString(),
      descricao: (map['descricao'] ?? '').toString(),
      data: (map['data'] ?? '').toString(),
      horaInicio: (map['hora_inicio'] ?? '').toString(),
      horaFim: (map['hora_fim'] ?? '').toString(),
      status: (map['status'] ?? 'Planejada').toString(),
      tempoAcumuladoSegundos:
      map['tempo_acumulado_segundos'] as int? ?? 0,
      iniciadaEm: map['iniciada_em']?.toString(),
      encerradaEm: map['encerrada_em']?.toString(),
      observacoes: map['observacoes']?.toString(),
      sincronizadaAgendaExterna:
      (map['sincronizada_agenda_externa'] as int? ?? 0) == 1,
      origem: (map['origem'] ?? 'manual').toString(),
      eventoExternoId: map['evento_externo_id']?.toString(),
      cor: map['cor']?.toString(),
      createdAt: (map['created_at'] ?? '').toString(),
      updatedAt: (map['updated_at'] ?? '').toString(),
    );
  }
}