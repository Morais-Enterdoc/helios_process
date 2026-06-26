class Evidencia {
  final int? id;
  final int sipocId;
  final int? gargaloId;
  final int? toBeId;
  final int? acaoId;
  final String titulo;
  final String tipo;
  final String observacao;
  final String arquivoPath;

  Evidencia({
    this.id,
    required this.sipocId,
    this.gargaloId,
    this.toBeId,
    this.acaoId,
    required this.titulo,
    required this.tipo,
    required this.observacao,
    required this.arquivoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sipoc_id': sipocId,
      'gargalo_id': gargaloId,
      'to_be_id': toBeId,
      'acao_id': acaoId,
      'titulo': titulo,
      'tipo': tipo,
      'observacao': observacao,
      'arquivo_path': arquivoPath,
    };
  }

  factory Evidencia.fromMap(Map<String, dynamic> map) {
    return Evidencia(
      id: map['id'],
      sipocId: map['sipoc_id'],
      gargaloId: map['gargalo_id'],
      toBeId: map['to_be_id'],
      acaoId: map['acao_id'],
      titulo: map['titulo'] ?? '',
      tipo: map['tipo'] ?? '',
      observacao: map['observacao'] ?? '',
      arquivoPath: map['arquivo_path'] ?? '',
    );
  }
}