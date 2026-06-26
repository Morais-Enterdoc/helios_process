class Sipoc {
  final int? id;
  final int clienteId;
  final int setorId;
  final String titulo;
  final String parte;
  final String codigo;
  final String revisao;
  final String dataEmissao;
  final String responsaveis;
  final String objetivo;
  final String fornecedores;
  final String entradas;
  final String processo;
  final String saidas;
  final String clientes;
  final String indicadores;
  final String fluxoTexto;

  const Sipoc({
    this.id,
    required this.clienteId,
    required this.setorId,
    required this.titulo,
    required this.parte,
    required this.codigo,
    required this.revisao,
    required this.dataEmissao,
    required this.responsaveis,
    required this.objetivo,
    required this.fornecedores,
    required this.entradas,
    required this.processo,
    required this.saidas,
    required this.clientes,
    required this.indicadores,
    required this.fluxoTexto,
  });

  Map<String, dynamic> toMap({bool includeId = true}) {
    return {
      if (includeId) 'id': id,
      'cliente_id': clienteId,
      'setor_id': setorId,
      'titulo': titulo,
      'parte': parte,
      'codigo': codigo,
      'revisao': revisao,
      'data_emissao': dataEmissao,
      'responsaveis': responsaveis,
      'objetivo': objetivo,
      'fornecedores': fornecedores,
      'entradas': entradas,
      'processo': processo,
      'saidas': saidas,
      'clientes': clientes,
      'indicadores': indicadores,
      'fluxo_texto': fluxoTexto,
    };
  }

  factory Sipoc.fromMap(Map<String, dynamic> map) {
    return Sipoc(
      id: map['id'] as int?,
      clienteId: map['cliente_id'] as int,
      setorId: map['setor_id'] as int,
      titulo: (map['titulo'] ?? '').toString(),
      parte: (map['parte'] ?? '').toString(),
      codigo: (map['codigo'] ?? '').toString(),
      revisao: (map['revisao'] ?? '').toString(),
      dataEmissao: (map['data_emissao'] ?? '').toString(),
      responsaveis: (map['responsaveis'] ?? '').toString(),
      objetivo: (map['objetivo'] ?? '').toString(),
      fornecedores: (map['fornecedores'] ?? '').toString(),
      entradas: (map['entradas'] ?? '').toString(),
      processo: (map['processo'] ?? '').toString(),
      saidas: (map['saidas'] ?? '').toString(),
      clientes: (map['clientes'] ?? '').toString(),
      indicadores: (map['indicadores'] ?? '').toString(),
      fluxoTexto: (map['fluxo_texto'] ?? '').toString(),
    );
  }

  Sipoc copyWith({
    int? id,
    int? clienteId,
    int? setorId,
    String? titulo,
    String? parte,
    String? codigo,
    String? revisao,
    String? dataEmissao,
    String? responsaveis,
    String? objetivo,
    String? fornecedores,
    String? entradas,
    String? processo,
    String? saidas,
    String? clientes,
    String? indicadores,
    String? fluxoTexto,
  }) {
    return Sipoc(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      setorId: setorId ?? this.setorId,
      titulo: titulo ?? this.titulo,
      parte: parte ?? this.parte,
      codigo: codigo ?? this.codigo,
      revisao: revisao ?? this.revisao,
      dataEmissao: dataEmissao ?? this.dataEmissao,
      responsaveis: responsaveis ?? this.responsaveis,
      objetivo: objetivo ?? this.objetivo,
      fornecedores: fornecedores ?? this.fornecedores,
      entradas: entradas ?? this.entradas,
      processo: processo ?? this.processo,
      saidas: saidas ?? this.saidas,
      clientes: clientes ?? this.clientes,
      indicadores: indicadores ?? this.indicadores,
      fluxoTexto: fluxoTexto ?? this.fluxoTexto,
    );
  }
}