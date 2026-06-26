class Setor {
  final int? id;
  final int clienteId;
  final String nome;

  const Setor({
    this.id,
    required this.clienteId,
    required this.nome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'nome': nome,
    };
  }

  factory Setor.fromMap(Map<String, dynamic> map) {
    return Setor(
      id: map['id'] as int?,
      clienteId: map['cliente_id'] as int,
      nome: (map['nome'] ?? '').toString(),
    );
  }

  Setor copyWith({
    int? id,
    int? clienteId,
    String? nome,
  }) {
    return Setor(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      nome: nome ?? this.nome,
    );
  }
}