import 'cronograma_item.dart';

class CronogramaProjeto {
  final int? id;
  final int? clienteId;
  final String clienteNome;
  final String setor;
  final String nomeProjeto;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final List<int> diasSemanaTrabalho;
  final List<CronogramaItem> itens;
  final String observacoes;

  const CronogramaProjeto({
    this.id,
    required this.clienteId,
    required this.clienteNome,
    required this.setor,
    required this.nomeProjeto,
    required this.dataInicio,
    required this.dataFim,
    required this.diasSemanaTrabalho,
    required this.itens,
    required this.observacoes,
  });

  double get realizadoMedio {
    if (itens.isEmpty) return 0;
    final soma = itens.fold<double>(
      0,
          (total, item) => total + item.realizadoPercentual,
    );
    return soma / itens.length;
  }
}