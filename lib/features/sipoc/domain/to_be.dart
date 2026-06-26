class ToBe {
  final int? id;
  final int sipocId;
  final int? gargaloId;
  final String titulo;
  final String descricao;
  final String tipoMelhoria;
  final String ganhoEsperado;
  final String complexidade;
  final String prioridade;
  final String status;

  ToBe({
    this.id,
    required this.sipocId,
    this.gargaloId,
    required this.titulo,
    required this.descricao,
    required this.tipoMelhoria,
    required this.ganhoEsperado,
    required this.complexidade,
    required this.prioridade,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sipoc_id': sipocId,
      'gargalo_id': gargaloId,
      'titulo': titulo,
      'descricao': descricao,
      'tipo_melhoria': tipoMelhoria,
      'ganho_esperado': ganhoEsperado,
      'complexidade': complexidade,
      'prioridade': prioridade,
      'status': status,
    };
  }

  factory ToBe.fromMap(Map<String, dynamic> map) {
    return ToBe(
      id: map['id'],
      sipocId: map['sipoc_id'],
      gargaloId: map['gargalo_id'],
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      tipoMelhoria: map['tipo_melhoria'] ?? '',
      ganhoEsperado: map['ganho_esperado'] ?? '',
      complexidade: map['complexidade'] ?? '',
      prioridade: map['prioridade'] ?? '',
      status: map['status'] ?? '',
    );
  }
}