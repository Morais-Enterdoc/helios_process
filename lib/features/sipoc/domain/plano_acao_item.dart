class PlanoAcaoItem {
  final int? id;
  final int sipocId;
  final int? toBeId;
  final String acao;
  final String responsavel;
  final String prazo;
  final String status;
  final String observacoes;
  final int percentual;

  PlanoAcaoItem({
    this.id,
    required this.sipocId,
    this.toBeId,
    required this.acao,
    required this.responsavel,
    required this.prazo,
    required this.status,
    required this.observacoes,
    required this.percentual,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sipoc_id': sipocId,
      'to_be_id': toBeId,
      'acao': acao,
      'responsavel': responsavel,
      'prazo': prazo,
      'status': status,
      'observacoes': observacoes,
      'percentual': percentual,
    };
  }

  factory PlanoAcaoItem.fromMap(Map<String, dynamic> map) {
    return PlanoAcaoItem(
      id: map['id'],
      sipocId: map['sipoc_id'],
      toBeId: map['to_be_id'],
      acao: map['acao'] ?? '',
      responsavel: map['responsavel'] ?? '',
      prazo: map['prazo'] ?? '',
      status: map['status'] ?? '',
      observacoes: map['observacoes'] ?? '',
      percentual: map['percentual'] ?? 0,
    );
  }
}