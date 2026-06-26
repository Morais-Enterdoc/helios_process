class CronogramaItem {
  final int? id;
  final String atividadePrincipal;
  final String atividade;
  final String subatividade;
  final String responsavel;
  final DateTime? inicio;
  final DateTime? termino;
  final int diasUteis;
  final int diasCorridos;
  final DateTime? dataProximaAcao;
  final double realizadoPercentual;
  final String status;
  final int nivel;
  final int ordem;

  const CronogramaItem({
    this.id,
    required this.atividadePrincipal,
    required this.atividade,
    required this.subatividade,
    required this.responsavel,
    required this.inicio,
    required this.termino,
    required this.diasUteis,
    required this.diasCorridos,
    required this.dataProximaAcao,
    required this.realizadoPercentual,
    required this.status,
    required this.nivel,
    required this.ordem,
  });

  CronogramaItem copyWith({
    int? id,
    String? atividadePrincipal,
    String? atividade,
    String? subatividade,
    String? responsavel,
    DateTime? inicio,
    DateTime? termino,
    int? diasUteis,
    int? diasCorridos,
    DateTime? dataProximaAcao,
    double? realizadoPercentual,
    String? status,
    int? nivel,
    int? ordem,
  }) {
    return CronogramaItem(
      id: id ?? this.id,
      atividadePrincipal: atividadePrincipal ?? this.atividadePrincipal,
      atividade: atividade ?? this.atividade,
      subatividade: subatividade ?? this.subatividade,
      responsavel: responsavel ?? this.responsavel,
      inicio: inicio ?? this.inicio,
      termino: termino ?? this.termino,
      diasUteis: diasUteis ?? this.diasUteis,
      diasCorridos: diasCorridos ?? this.diasCorridos,
      dataProximaAcao: dataProximaAcao ?? this.dataProximaAcao,
      realizadoPercentual: realizadoPercentual ?? this.realizadoPercentual,
      status: status ?? this.status,
      nivel: nivel ?? this.nivel,
      ordem: ordem ?? this.ordem,
    );
  }
}