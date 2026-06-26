class TimelineEvento {
  final int? id;
  final int sipocId;
  final String tipo;
  final String descricao;
  final String data;
  final String? origem;

  TimelineEvento({
    this.id,
    required this.sipocId,
    required this.tipo,
    required this.descricao,
    required this.data,
    this.origem,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sipoc_id': sipocId,
      'tipo': tipo,
      'descricao': descricao,
      'data': data,
      'origem': origem,
    };
  }

  factory TimelineEvento.fromMap(Map<String, dynamic> map) {
    return TimelineEvento(
      id: map['id'],
      sipocId: map['sipoc_id'],
      tipo: map['tipo'] ?? '',
      descricao: map['descricao'] ?? '',
      data: map['data'] ?? '',
      origem: map['origem'],
    );
  }
}