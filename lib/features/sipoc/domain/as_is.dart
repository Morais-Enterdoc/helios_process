class AsIs {
  final int? id;
  final int sipocId;
  final String titulo;
  final String descricao;
  final String processo;
  final String fluxo;
  final int ordemFluxo;
  final String responsavel;
  final String dataRegistro;
  final String observacoes;

  AsIs({
    this.id,
    required this.sipocId,
    required this.titulo,
    required this.descricao,
    required this.processo,
    required this.fluxo,
    required this.ordemFluxo,
    required this.responsavel,
    required this.dataRegistro,
    required this.observacoes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sipoc_id': sipocId,
      'titulo': titulo,
      'descricao': descricao,
      'processo': processo,
      'fluxo': fluxo,
      'ordem_fluxo': ordemFluxo,
      'responsavel': responsavel,
      'data_registro': dataRegistro,
      'observacoes': observacoes,
    };
  }

  factory AsIs.fromMap(Map<String, dynamic> map) {
    return AsIs(
      id: map['id'] as int?,
      sipocId: _parseInt(map['sipoc_id']),
      titulo: (map['titulo'] ?? '').toString(),
      descricao: (map['descricao'] ?? '').toString(),
      processo: (map['processo'] ?? '').toString(),
      fluxo: (map['fluxo'] ?? '').toString(),
      ordemFluxo: _parseInt(map['ordem_fluxo']),
      responsavel: (map['responsavel'] ?? '').toString(),
      dataRegistro: (map['data_registro'] ?? '').toString(),
      observacoes: (map['observacoes'] ?? '').toString(),
    );
  }

  AsIs copyWith({
    int? id,
    int? sipocId,
    String? titulo,
    String? descricao,
    String? processo,
    String? fluxo,
    int? ordemFluxo,
    String? responsavel,
    String? dataRegistro,
    String? observacoes,
  }) {
    return AsIs(
      id: id ?? this.id,
      sipocId: sipocId ?? this.sipocId,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      processo: processo ?? this.processo,
      fluxo: fluxo ?? this.fluxo,
      ordemFluxo: ordemFluxo ?? this.ordemFluxo,
      responsavel: responsavel ?? this.responsavel,
      dataRegistro: dataRegistro ?? this.dataRegistro,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}