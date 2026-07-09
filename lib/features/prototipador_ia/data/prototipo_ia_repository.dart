import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../core/database/app_database.dart';
import '../domain/prototipo_ia.dart';

class PrototipoIaRepository {
  static const String _tableName = 'prototipos_ia';

  Future<Database> _database() async {
    return await AppDatabase.instance();
  }

  Map<String, dynamic> _toMap(PrototipoIa prototipo) {
    return {
      'id': prototipo.id,
      'cliente': prototipo.cliente,
      'projeto_macroprocesso': prototipo.projetoMacroprocesso,
      'numero_chamado_mo': prototipo.numeroChamadoMo,
      'titulo_chamado': prototipo.tituloChamado,
      'vinculacao_chamado': prototipo.vinculacaoChamado,
      'modulo_mo': prototipo.moduloMo,
      'programa_mo_relacionado': prototipo.programaMoRelacionado,
      'nome_tela_funcionalidade': prototipo.nomeTelaFuncionalidade,
      'objetivo_tela': prototipo.objetivoTela,
      'usuarios_principais': prototipo.usuariosPrincipais,
      'prioridade': prototipo.prioridade,
      'descricao_detalhada': prototipo.descricaoDetalhada,
      'problema_atual': prototipo.problemaAtual,
      'resultado_esperado': prototipo.resultadoEsperado,
      'campos_necessarios': prototipo.camposNecessarios,
      'filtros_necessarios': prototipo.filtrosNecessarios,
      'botoes_necessarios': prototipo.botoesNecessarios,
      'colunas_grid': prototipo.colunasGrid,
      'regras_negocio': prototipo.regrasNegocio,
      'integracoes_envolvidas': prototipo.integracoesEnvolvidas,
      'imagem_tela_atual_path': prototipo.imagemTelaAtualPath,
      'documentacao_gerada': prototipo.documentacaoGerada,
      'html_gerado': prototipo.htmlGerado,
      'arquivo_html_local': prototipo.arquivoHtmlLocal,
      'created_at': prototipo.createdAt.toIso8601String(),
      'updated_at': prototipo.updatedAt.toIso8601String(),
    };
  }

  PrototipoIa _fromMap(Map<String, dynamic> map) {
    return PrototipoIa(
      id: map['id'] as String,
      cliente: (map['cliente'] ?? '') as String,
      projetoMacroprocesso: (map['projeto_macroprocesso'] ?? '') as String,
      numeroChamadoMo: (map['numero_chamado_mo'] ?? '') as String,
      tituloChamado: (map['titulo_chamado'] ?? '') as String,
      vinculacaoChamado: (map['vinculacao_chamado'] ?? '') as String,
      moduloMo: (map['modulo_mo'] ?? '') as String,
      programaMoRelacionado:
      (map['programa_mo_relacionado'] ?? '') as String,
      nomeTelaFuncionalidade:
      (map['nome_tela_funcionalidade'] ?? '') as String,
      objetivoTela: (map['objetivo_tela'] ?? '') as String,
      usuariosPrincipais: (map['usuarios_principais'] ?? '') as String,
      prioridade: (map['prioridade'] ?? '') as String,
      descricaoDetalhada: (map['descricao_detalhada'] ?? '') as String,
      problemaAtual: (map['problema_atual'] ?? '') as String,
      resultadoEsperado: (map['resultado_esperado'] ?? '') as String,
      camposNecessarios: (map['campos_necessarios'] ?? '') as String,
      filtrosNecessarios: (map['filtros_necessarios'] ?? '') as String,
      botoesNecessarios: (map['botoes_necessarios'] ?? '') as String,
      colunasGrid: (map['colunas_grid'] ?? '') as String,
      regrasNegocio: (map['regras_negocio'] ?? '') as String,
      integracoesEnvolvidas: (map['integracoes_envolvidas'] ?? '') as String,
      imagemTelaAtualPath: (map['imagem_tela_atual_path'] ?? '') as String,
      documentacaoGerada: (map['documentacao_gerada'] ?? '') as String,
      htmlGerado: (map['html_gerado'] ?? '') as String,
      arquivoHtmlLocal: (map['arquivo_html_local'] ?? '') as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Future<List<PrototipoIa>> listarTodos() async {
    final db = await _database();

    final result = await db.query(
      _tableName,
      orderBy: 'updated_at DESC',
    );

    return result.map(_fromMap).toList();
  }

  Future<PrototipoIa?> buscarPorId(String id) async {
    final db = await _database();

    final result = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return _fromMap(result.first);
  }

  Future<void> salvar(PrototipoIa prototipo) async {
    final db = await _database();

    await db.insert(
      _tableName,
      _toMap(prototipo),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removerPorId(String id) async {
    final db = await _database();

    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> limparTudo() async {
    final db = await _database();
    await db.delete(_tableName);
  }
}