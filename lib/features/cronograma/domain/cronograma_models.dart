class CronogramaProjeto {
  final int? id;
  final int? clienteId;
  final int? setorId;
  final String nomeProjeto;
  final String responsavel;
  final DateTime? inicio;
  final DateTime? termino;
  final int realizadoPercentual;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? clienteNome;
  final String? clienteLogoPath;
  final String? clienteCor;
  final String? clienteDiasAtendimento;
  final String? clienteLabelAgenda;
  final String? setorNome;
  final List<CronogramaItem> itens;

  const CronogramaProjeto({
    this.id,
    this.clienteId,
    this.setorId,
    required this.nomeProjeto,
    required this.responsavel,
    this.inicio,
    this.termino,
    required this.realizadoPercentual,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.clienteNome,
    this.clienteLogoPath,
    this.clienteCor,
    this.clienteDiasAtendimento,
    this.clienteLabelAgenda,
    this.setorNome,
    required this.itens,
  });

  CronogramaProjeto copyWith({
    int? id,
    int? clienteId,
    int? setorId,
    String? nomeProjeto,
    String? responsavel,
    DateTime? inicio,
    DateTime? termino,
    int? realizadoPercentual,
    String? status,
    String? createdAt,
    String? updatedAt,
    String? clienteNome,
    String? clienteLogoPath,
    String? clienteCor,
    String? clienteDiasAtendimento,
    String? clienteLabelAgenda,
    String? setorNome,
    List<CronogramaItem>? itens,
  }) {
    return CronogramaProjeto(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      setorId: setorId ?? this.setorId,
      nomeProjeto: nomeProjeto ?? this.nomeProjeto,
      responsavel: responsavel ?? this.responsavel,
      inicio: inicio ?? this.inicio,
      termino: termino ?? this.termino,
      realizadoPercentual:
      realizadoPercentual ?? this.realizadoPercentual,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      clienteNome: clienteNome ?? this.clienteNome,
      clienteLogoPath: clienteLogoPath ?? this.clienteLogoPath,
      clienteCor: clienteCor ?? this.clienteCor,
      clienteDiasAtendimento:
      clienteDiasAtendimento ?? this.clienteDiasAtendimento,
      clienteLabelAgenda:
      clienteLabelAgenda ?? this.clienteLabelAgenda,
      setorNome: setorNome ?? this.setorNome,
      itens: itens ?? this.itens,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'setor_id': setorId,
      'nome_projeto': nomeProjeto,
      'responsavel': responsavel,
      'data_inicio': inicio?.toIso8601String(),
      'data_termino': termino?.toIso8601String(),
      'realizado_percentual': realizadoPercentual,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory CronogramaProjeto.fromMap(Map<String, dynamic> map) {
    return CronogramaProjeto(
      id: map['id'] as int?,
      clienteId: map['cliente_id'] as int?,
      setorId: map['setor_id'] as int?,
      nomeProjeto: (map['nome_projeto'] ?? '').toString(),
      responsavel: (map['responsavel'] ?? '').toString(),
      inicio: map['data_inicio'] != null &&
          map['data_inicio'].toString().isNotEmpty
          ? DateTime.tryParse(map['data_inicio'].toString())
          : null,
      termino: map['data_termino'] != null &&
          map['data_termino'].toString().isNotEmpty
          ? DateTime.tryParse(map['data_termino'].toString())
          : null,
      realizadoPercentual:
      (map['realizado_percentual'] as int?) ?? 0,
      status: (map['status'] ?? 'Em andamento').toString(),
      createdAt: (map['created_at'] ?? '').toString(),
      updatedAt: (map['updated_at'] ?? '').toString(),
      clienteNome: map['cliente_nome']?.toString(),
      clienteLogoPath: map['cliente_logo_path']?.toString(),
      clienteCor: map['cliente_cor']?.toString(),
      clienteDiasAtendimento:
      map['cliente_dias_atendimento']?.toString(),
      clienteLabelAgenda:
      map['cliente_label_agenda']?.toString(),
      setorNome: map['setor_nome']?.toString(),
      itens: const [],
    );
  }
}

class CronogramaItem {
  final int? id;
  final int? cronogramaId;
  final String atividade;
  final String responsavel;
  final DateTime? dataInicio;
  final int diasUteis;
  final int diasCorridos;
  final DateTime? dataTermino;
  final DateTime? dataProximaAcao;
  final int realizadoPercentual;
  final String status;
  final int inicioSemana;
  final int duracaoSemanas;
  final bool destaque;
  final int nivel;

  const CronogramaItem({
    required this.id,
    required this.cronogramaId,
    required this.atividade,
    required this.responsavel,
    required this.dataInicio,
    required this.diasUteis,
    required this.diasCorridos,
    required this.dataTermino,
    required this.dataProximaAcao,
    required this.realizadoPercentual,
    required this.status,
    required this.inicioSemana,
    required this.duracaoSemanas,
    required this.destaque,
    required this.nivel,
  });

  CronogramaItem copyWith({
    int? id,
    int? cronogramaId,
    String? atividade,
    String? responsavel,
    DateTime? dataInicio,
    int? diasUteis,
    int? diasCorridos,
    DateTime? dataTermino,
    DateTime? dataProximaAcao,
    int? realizadoPercentual,
    String? status,
    int? inicioSemana,
    int? duracaoSemanas,
    bool? destaque,
    int? nivel,
  }) {
    return CronogramaItem(
      id: id ?? this.id,
      cronogramaId: cronogramaId ?? this.cronogramaId,
      atividade: atividade ?? this.atividade,
      responsavel: responsavel ?? this.responsavel,
      dataInicio: dataInicio ?? this.dataInicio,
      diasUteis: diasUteis ?? this.diasUteis,
      diasCorridos: diasCorridos ?? this.diasCorridos,
      dataTermino: dataTermino ?? this.dataTermino,
      dataProximaAcao: dataProximaAcao ?? this.dataProximaAcao,
      realizadoPercentual:
      realizadoPercentual ?? this.realizadoPercentual,
      status: status ?? this.status,
      inicioSemana: inicioSemana ?? this.inicioSemana,
      duracaoSemanas: duracaoSemanas ?? this.duracaoSemanas,
      destaque: destaque ?? this.destaque,
      nivel: nivel ?? this.nivel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cronograma_id': cronogramaId,
      'atividade': atividade,
      'responsavel': responsavel,
      'data_inicio': dataInicio?.toIso8601String(),
      'dias_uteis': diasUteis,
      'dias_corridos': diasCorridos,
      'data_termino': dataTermino?.toIso8601String(),
      'data_proxima_acao': dataProximaAcao?.toIso8601String(),
      'realizado_percentual': realizadoPercentual,
      'status': status,
      'inicio_semana': inicioSemana,
      'duracao_semanas': duracaoSemanas,
      'destaque': destaque ? 1 : 0,
      'nivel': nivel,
    };
  }

  factory CronogramaItem.fromMap(Map<String, dynamic> map) {
    return CronogramaItem(
      id: map['id'] as int?,
      cronogramaId: map['cronograma_id'] as int?,
      atividade: (map['atividade'] ?? '').toString(),
      responsavel: (map['responsavel'] ?? '').toString(),
      dataInicio: map['data_inicio'] != null &&
          map['data_inicio'].toString().isNotEmpty
          ? DateTime.tryParse(map['data_inicio'].toString())
          : null,
      diasUteis: (map['dias_uteis'] as int?) ?? 1,
      diasCorridos: (map['dias_corridos'] as int?) ?? 1,
      dataTermino: map['data_termino'] != null &&
          map['data_termino'].toString().isNotEmpty
          ? DateTime.tryParse(map['data_termino'].toString())
          : null,
      dataProximaAcao: map['data_proxima_acao'] != null &&
          map['data_proxima_acao'].toString().isNotEmpty
          ? DateTime.tryParse(map['data_proxima_acao'].toString())
          : null,
      realizadoPercentual:
      (map['realizado_percentual'] as int?) ?? 0,
      status: (map['status'] ?? 'Em andamento').toString(),
      inicioSemana: (map['inicio_semana'] as int?) ?? 0,
      duracaoSemanas: (map['duracao_semanas'] as int?) ?? 1,
      destaque: ((map['destaque'] as int?) ?? 0) == 1,
      nivel: (map['nivel'] as int?) ?? 1,
    );
  }
}