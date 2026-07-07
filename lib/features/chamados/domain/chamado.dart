class Chamado {
  final int? id;
  final String ticket;
  final String cliente;
  final String solicitante;
  final String assunto;
  final String descricao;
  final String numeroRo;
  final String categoria;
  final String status;
  final String servico;
  final String dataAbertura;
  final String prazoEntrega;
  final String ultimaAtualizacao;
  final String agenteAtual;
  final String equipeAtual;
  final String anotacoes;
  final String meuStatus;
  final List<String> anexos;

  const Chamado({
    this.id,
    required this.ticket,
    required this.cliente,
    required this.solicitante,
    required this.assunto,
    required this.descricao,
    required this.numeroRo,
    required this.categoria,
    required this.status,
    required this.servico,
    required this.dataAbertura,
    required this.prazoEntrega,
    required this.ultimaAtualizacao,
    required this.agenteAtual,
    required this.equipeAtual,
    required this.anotacoes,
    required this.meuStatus,
    required this.anexos,

  });

  Chamado copyWith({
    int? id,
    String? ticket,
    String? cliente,
    String? solicitante,
    String? assunto,
    String? descricao,
    String? numeroRo,
    String? categoria,
    String? status,
    String? servico,
    String? dataAbertura,
    String? prazoEntrega,
    String? ultimaAtualizacao,
    String? agenteAtual,
    String? equipeAtual,
    String? anotacoes,
    String? meuStatus,
    List<String>? anexos,

  }) {
    return Chamado(
      id: id ?? this.id,
      ticket: ticket ?? this.ticket,
      cliente: cliente ?? this.cliente,
      solicitante: solicitante ?? this.solicitante,
      assunto: assunto ?? this.assunto,
      descricao: descricao ?? this.descricao,
      numeroRo: numeroRo ?? this.numeroRo,
      categoria: categoria ?? this.categoria,
      status: status ?? this.status,
      servico: servico ?? this.servico,
      dataAbertura: dataAbertura ?? this.dataAbertura,
      prazoEntrega: prazoEntrega ?? this.prazoEntrega,
      ultimaAtualizacao: ultimaAtualizacao ?? this.ultimaAtualizacao,
      agenteAtual: agenteAtual ?? this.agenteAtual,
      equipeAtual: equipeAtual ?? this.equipeAtual,
      anotacoes: anotacoes != null ? anotacoes : this.anotacoes,
      meuStatus: meuStatus ?? this.meuStatus,
      anexos: anexos ?? this.anexos,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticket': ticket,
      'cliente': cliente,
      'solicitante': solicitante,
      'assunto': assunto,
      'descricao': descricao,
      'numeroRo': numeroRo,
      'categoria': categoria,
      'status': status,
      'servico': servico,
      'dataAbertura': dataAbertura,
      'prazoEntrega': prazoEntrega,
      'ultimaAtualizacao': ultimaAtualizacao,
      'agenteAtual': agenteAtual,
      'equipeAtual': equipeAtual,
      'anotacoes': anotacoes,
      'meuStatus': meuStatus,
      'anexos': anexos,
    };
  }

  factory Chamado.fromMap(Map<String, dynamic> map) {
    return Chamado(
      id: map['id'] as int?,
      ticket: map['ticket']?.toString() ?? '',
      cliente: map['cliente']?.toString() ?? '',
      solicitante: map['solicitante']?.toString() ?? '',
      assunto: map['assunto']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      numeroRo: map['numeroRo']?.toString() ?? '',
      categoria: map['categoria']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      servico: map['servico']?.toString() ?? '',
      dataAbertura: map['dataAbertura']?.toString() ?? '',
      prazoEntrega: map['prazoEntrega']?.toString() ?? '',
      ultimaAtualizacao: map['ultimaAtualizacao']?.toString() ?? '',
      agenteAtual: map['agenteAtual']?.toString() ?? '',
      equipeAtual: map['equipeAtual']?.toString() ?? '',
      anotacoes: map['anotacoes']?.toString() ?? '',
      meuStatus: map['meuStatus']?.toString() ?? '',
      anexos: List<String>.from(map['anexos'] ?? []),
    );
  }
}