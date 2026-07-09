class ManualIa {
  final String cliente;
  final String programaMo;
  final String nomeManual;
  final String objetivo;
  final String tipoManual;
  final String tipoNivelPagina;
  final String descricaoRotina;
  final String passoAPasso;
  final String observacoes;
  final String imagemTelaPath;
  final String conteudoManual;

  const ManualIa({
    required this.cliente,
    required this.programaMo,
    required this.nomeManual,
    required this.objetivo,
    required this.tipoManual,
    required this.tipoNivelPagina,
    required this.descricaoRotina,
    required this.passoAPasso,
    required this.observacoes,
    required this.imagemTelaPath,
    required this.conteudoManual,
  });

  ManualIa copyWith({
    String? cliente,
    String? programaMo,
    String? nomeManual,
    String? objetivo,
    String? tipoManual,
    String? tipoNivelPagina,
    String? descricaoRotina,
    String? passoAPasso,
    String? observacoes,
    String? imagemTelaPath,
    String? conteudoManual,
  }) {
    return ManualIa(
      cliente: cliente ?? this.cliente,
      programaMo: programaMo ?? this.programaMo,
      nomeManual: nomeManual ?? this.nomeManual,
      objetivo: objetivo ?? this.objetivo,
      tipoManual: tipoManual ?? this.tipoManual,
      tipoNivelPagina: tipoNivelPagina ?? this.tipoNivelPagina,
      descricaoRotina: descricaoRotina ?? this.descricaoRotina,
      passoAPasso: passoAPasso ?? this.passoAPasso,
      observacoes: observacoes ?? this.observacoes,
      imagemTelaPath: imagemTelaPath ?? this.imagemTelaPath,
      conteudoManual: conteudoManual ?? this.conteudoManual,
    );
  }

  factory ManualIa.vazio() {
    return const ManualIa(
      cliente: '',
      programaMo: '',
      nomeManual: '',
      objetivo: '',
      tipoManual: 'Manual Operacional',
      tipoNivelPagina: 'Nível 3 – Tela Operacional',
      descricaoRotina: '',
      passoAPasso: '',
      observacoes: '',
      imagemTelaPath: '',
      conteudoManual: '',
    );
  }
}