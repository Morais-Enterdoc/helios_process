class Gargalo {
  final int? id;
  final int sipocId;
  final String titulo;
  final String descricao;
  final String impacto;
  final String criticidade;
  final String tipo;
  final String consequencia;
  final String? evidenciaRelacionada;

  Gargalo({
    this.id,
    required this.sipocId,
    required this.titulo,
    required this.descricao,
    required this.impacto,
    required this.criticidade,
    required this.tipo,
    required this.consequencia,
    this.evidenciaRelacionada,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sipoc_id': sipocId,
      'titulo': titulo,
      'descricao': descricao,
      'impacto': impacto,
      'criticidade': criticidade,
      'tipo': tipo,
      'consequencia': consequencia,
      'evidencia_relacionada': evidenciaRelacionada,
    };
  }

  factory Gargalo.fromMap(Map<String, dynamic> map) {
    return Gargalo(
      id: map['id'],
      sipocId: map['sipoc_id'],
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      impacto: map['impacto'] ?? '',
      criticidade: map['criticidade'] ?? '',
      tipo: map['tipo'] ?? '',
      consequencia: map['consequencia'] ?? '',
      evidenciaRelacionada: map['evidencia_relacionada'],
    );
  }
}