import 'tarefa.dart';

class TarefaDetalhe {
  final Tarefa tarefa;
  final String? clienteNome;
  final String? clienteLogoPath;
  final String? clienteCor;
  final String? clienteDiasAtendimento;
  final String? clienteLabelAgenda;


  const TarefaDetalhe({
    required this.tarefa,
    this.clienteNome,
    this.clienteLogoPath,
    this.clienteCor,
    this.clienteDiasAtendimento,
    this.clienteLabelAgenda,
  });

  factory TarefaDetalhe.fromMap(Map<String, dynamic> map) {
    return TarefaDetalhe(
      tarefa: Tarefa.fromMap(map),
      clienteNome: map['cliente_nome']?.toString(),
      clienteLogoPath: map['cliente_logo_path']?.toString(),
      clienteCor: map['cliente_cor']?.toString(),
      clienteDiasAtendimento: map['cliente_dias_atendimento']?.toString(),
      clienteLabelAgenda: map['cliente_label_agenda']?.toString(),
    );
  }
}