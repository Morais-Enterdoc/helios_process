class AgendaManual {
  final int? id;
  final String titulo;
  final String descricao;
  final String observacoes;
  final String data;
  final String? horaInicio;
  final String? horaFim;
  final String status;
  final String cor;
  final String tipoVinculo;
  final int? vinculoId;
  final String createdAt;
  final String updatedAt;

  const AgendaManual({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.observacoes,
    required this.data,
    required this.horaInicio,
    required this.horaFim,
    required this.status,
    required this.cor,
    required this.tipoVinculo,
    required this.vinculoId,
    required this.createdAt,
    required this.updatedAt,
  });

  AgendaManual copyWith({
    int? id,
    String? titulo,
    String? descricao,
    String? observacoes,
    String? data,
    String? horaInicio,
    String? horaFim,
    String? status,
    String? cor,
    String? tipoVinculo,
    int? vinculoId,
    String? createdAt,
    String? updatedAt,
  }) {
    return AgendaManual(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      observacoes: observacoes ?? this.observacoes,
      data: data ?? this.data,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFim: horaFim ?? this.horaFim,
      status: status ?? this.status,
      cor: cor ?? this.cor,
      tipoVinculo: tipoVinculo ?? this.tipoVinculo,
      vinculoId: vinculoId ?? this.vinculoId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'observacoes': observacoes,
      'data': data,
      'hora_inicio': horaInicio,
      'hora_fim': horaFim,
      'status': status,
      'cor': cor,
      'tipo_vinculo': tipoVinculo,
      'vinculo_id': vinculoId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory AgendaManual.fromMap(Map map) {
    return AgendaManual(
      id: map['id'] as int?,
      titulo: map['titulo']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      observacoes: map['observacoes']?.toString() ?? '',
      data: map['data']?.toString() ?? '',
      horaInicio: map['hora_inicio']?.toString(),
      horaFim: map['hora_fim']?.toString(),
      status: map['status']?.toString() ?? 'Planejada',
      cor: map['cor']?.toString() ?? '#DBEAFE',
      tipoVinculo: map['tipo_vinculo']?.toString() ?? 'geral',
      vinculoId: map['vinculo_id'] as int?,
      createdAt: map['created_at']?.toString() ?? '',
      updatedAt: map['updated_at']?.toString() ?? '',
    );
  }
}