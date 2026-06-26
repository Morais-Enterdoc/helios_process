class Cliente {
  final int? id;
  final String nome;
  final String logoPath;
  final String diasAtendimento;
  final String corAgenda;

  const Cliente({
    this.id,
    required this.nome,
    required this.logoPath,
    this.diasAtendimento = '',
    this.corAgenda = '#FEF3C7',
  });

  List<int> get diasAtendimentoList {
    if (diasAtendimento.trim().isEmpty) return [];

    return diasAtendimento
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .where((e) => e != null && e! >= 1 && e <= 7)
        .cast<int>()
        .toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'logo_path': logoPath,
      'dias_atendimento': diasAtendimento,
      'cor_agenda': corAgenda,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'] as int?,
      nome: (map['nome'] ?? '').toString(),
      logoPath: (map['logo_path'] ?? '').toString(),
      diasAtendimento: (map['dias_atendimento'] ?? '').toString(),
      corAgenda: (map['cor_agenda'] ?? '#FEF3C7').toString(),
    );
  }

  Cliente copyWith({
    int? id,
    String? nome,
    String? logoPath,
    String? diasAtendimento,
    String? corAgenda,
  }) {
    return Cliente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      logoPath: logoPath ?? this.logoPath,
      diasAtendimento: diasAtendimento ?? this.diasAtendimento,
      corAgenda: corAgenda ?? this.corAgenda,
    );
  }
}