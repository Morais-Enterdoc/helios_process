class PrototipoIa {
  final String id;
  final String cliente;
  final String projetoMacroprocesso;
  final String numeroChamadoMo;
  final String tituloChamado;
  final String vinculacaoChamado;
  final String moduloMo;
  final String programaMoRelacionado;
  final String nomeTelaFuncionalidade;
  final String objetivoTela;
  final String usuariosPrincipais;
  final String prioridade;
  final String descricaoDetalhada;
  final String problemaAtual;
  final String resultadoEsperado;
  final String camposNecessarios;
  final String filtrosNecessarios;
  final String botoesNecessarios;
  final String colunasGrid;
  final String regrasNegocio;
  final String integracoesEnvolvidas;
  final String imagemTelaAtualPath;
  final String documentacaoGerada;
  final String htmlGerado;
  final String arquivoHtmlLocal;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PrototipoIa({
    required this.id,
    required this.cliente,
    required this.projetoMacroprocesso,
    required this.numeroChamadoMo,
    required this.tituloChamado,
    required this.vinculacaoChamado,
    required this.moduloMo,
    required this.programaMoRelacionado,
    required this.nomeTelaFuncionalidade,
    required this.objetivoTela,
    required this.usuariosPrincipais,
    required this.prioridade,
    required this.descricaoDetalhada,
    required this.problemaAtual,
    required this.resultadoEsperado,
    required this.camposNecessarios,
    required this.filtrosNecessarios,
    required this.botoesNecessarios,
    required this.colunasGrid,
    required this.regrasNegocio,
    required this.integracoesEnvolvidas,
    required this.imagemTelaAtualPath,
    required this.documentacaoGerada,
    required this.htmlGerado,
    required this.arquivoHtmlLocal,
    required this.createdAt,
    required this.updatedAt,
  });

  PrototipoIa copyWith({
    String? id,
    String? cliente,
    String? projetoMacroprocesso,
    String? numeroChamadoMo,
    String? tituloChamado,
    String? vinculacaoChamado,
    String? moduloMo,
    String? programaMoRelacionado,
    String? nomeTelaFuncionalidade,
    String? objetivoTela,
    String? usuariosPrincipais,
    String? prioridade,
    String? descricaoDetalhada,
    String? problemaAtual,
    String? resultadoEsperado,
    String? camposNecessarios,
    String? filtrosNecessarios,
    String? botoesNecessarios,
    String? colunasGrid,
    String? regrasNegocio,
    String? integracoesEnvolvidas,
    String? imagemTelaAtualPath,
    String? documentacaoGerada,
    String? htmlGerado,
    String? arquivoHtmlLocal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PrototipoIa(
      id: id ?? this.id,
      cliente: cliente ?? this.cliente,
      projetoMacroprocesso: projetoMacroprocesso ?? this.projetoMacroprocesso,
      numeroChamadoMo: numeroChamadoMo ?? this.numeroChamadoMo,
      tituloChamado: tituloChamado ?? this.tituloChamado,
      vinculacaoChamado: vinculacaoChamado ?? this.vinculacaoChamado,
      moduloMo: moduloMo ?? this.moduloMo,
      programaMoRelacionado: programaMoRelacionado ?? this.programaMoRelacionado,
      nomeTelaFuncionalidade: nomeTelaFuncionalidade ?? this.nomeTelaFuncionalidade,
      objetivoTela: objetivoTela ?? this.objetivoTela,
      usuariosPrincipais: usuariosPrincipais ?? this.usuariosPrincipais,
      prioridade: prioridade ?? this.prioridade,
      descricaoDetalhada: descricaoDetalhada ?? this.descricaoDetalhada,
      problemaAtual: problemaAtual ?? this.problemaAtual,
      resultadoEsperado: resultadoEsperado ?? this.resultadoEsperado,
      camposNecessarios: camposNecessarios ?? this.camposNecessarios,
      filtrosNecessarios: filtrosNecessarios ?? this.filtrosNecessarios,
      botoesNecessarios: botoesNecessarios ?? this.botoesNecessarios,
      colunasGrid: colunasGrid ?? this.colunasGrid,
      regrasNegocio: regrasNegocio ?? this.regrasNegocio,
      integracoesEnvolvidas: integracoesEnvolvidas ?? this.integracoesEnvolvidas,
      imagemTelaAtualPath: imagemTelaAtualPath ?? this.imagemTelaAtualPath,
      documentacaoGerada: documentacaoGerada ?? this.documentacaoGerada,
      htmlGerado: htmlGerado ?? this.htmlGerado,
      arquivoHtmlLocal: arquivoHtmlLocal ?? this.arquivoHtmlLocal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente': cliente,
      'projetoMacroprocesso': projetoMacroprocesso,
      'numeroChamadoMo': numeroChamadoMo,
      'tituloChamado': tituloChamado,
      'vinculacaoChamado': vinculacaoChamado,
      'moduloMo': moduloMo,
      'programaMoRelacionado': programaMoRelacionado,
      'nomeTelaFuncionalidade': nomeTelaFuncionalidade,
      'objetivoTela': objetivoTela,
      'usuariosPrincipais': usuariosPrincipais,
      'prioridade': prioridade,
      'descricaoDetalhada': descricaoDetalhada,
      'problemaAtual': problemaAtual,
      'resultadoEsperado': resultadoEsperado,
      'camposNecessarios': camposNecessarios,
      'filtrosNecessarios': filtrosNecessarios,
      'botoesNecessarios': botoesNecessarios,
      'colunasGrid': colunasGrid,
      'regrasNegocio': regrasNegocio,
      'integracoesEnvolvidas': integracoesEnvolvidas,
      'imagemTelaAtualPath': imagemTelaAtualPath,
      'documentacaoGerada': documentacaoGerada,
      'htmlGerado': htmlGerado,
      'arquivoHtmlLocal': arquivoHtmlLocal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PrototipoIa.fromMap(Map<String, dynamic> map) {
    return PrototipoIa(
      id: map['id']?.toString() ?? '',
      cliente: map['cliente']?.toString() ?? '',
      projetoMacroprocesso: map['projetoMacroprocesso']?.toString() ?? '',
      numeroChamadoMo: map['numeroChamadoMo']?.toString() ?? '',
      tituloChamado: map['tituloChamado']?.toString() ?? '',
      vinculacaoChamado: map['vinculacaoChamado']?.toString() ?? '',
      moduloMo: map['moduloMo']?.toString() ?? '',
      programaMoRelacionado: map['programaMoRelacionado']?.toString() ?? '',
      nomeTelaFuncionalidade: map['nomeTelaFuncionalidade']?.toString() ?? '',
      objetivoTela: map['objetivoTela']?.toString() ?? '',
      usuariosPrincipais: map['usuariosPrincipais']?.toString() ?? '',
      prioridade: map['prioridade']?.toString() ?? '',
      descricaoDetalhada: map['descricaoDetalhada']?.toString() ?? '',
      problemaAtual: map['problemaAtual']?.toString() ?? '',
      resultadoEsperado: map['resultadoEsperado']?.toString() ?? '',
      camposNecessarios: map['camposNecessarios']?.toString() ?? '',
      filtrosNecessarios: map['filtrosNecessarios']?.toString() ?? '',
      botoesNecessarios: map['botoesNecessarios']?.toString() ?? '',
      colunasGrid: map['colunasGrid']?.toString() ?? '',
      regrasNegocio: map['regrasNegocio']?.toString() ?? '',
      integracoesEnvolvidas: map['integracoesEnvolvidas']?.toString() ?? '',
      imagemTelaAtualPath: map['imagemTelaAtualPath']?.toString() ?? '',
      documentacaoGerada: map['documentacaoGerada']?.toString() ?? '',
      htmlGerado: map['htmlGerado']?.toString() ?? '',
      arquivoHtmlLocal: map['arquivoHtmlLocal']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}