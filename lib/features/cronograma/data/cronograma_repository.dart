import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../core/database/app_database.dart';
import '../domain/cronograma_models.dart';

class CronogramaRepository {
  Future<Database> get db async => AppDatabase.instance();

  Future<int> inserirCronograma(CronogramaProjeto projeto) async {
    final db = await this.db;

    return db.transaction<int>((txn) async {
      final agora = DateTime.now().toIso8601String();

      final projetoParaSalvar = projeto.copyWith(
        createdAt: projeto.createdAt.isEmpty ? agora : projeto.createdAt,
        updatedAt: agora,
      );

      final idProjeto = await txn.insert(
        'cronogramas',
        projetoParaSalvar.toMap(),
      );

      for (final item in projeto.itens) {
        final dadosItem = item.toMap()
          ..['id'] = null
          ..['cronograma_id'] = idProjeto;

        await txn.insert('cronograma_itens', dadosItem);
      }

      return idProjeto;
    });
  }

  Future<void> atualizarCronograma(CronogramaProjeto projeto) async {
    if (projeto.id == null) {
      throw ArgumentError('projeto.id não pode ser nulo para atualizar.');
    }

    final db = await this.db;

    await db.transaction((txn) async {
      final agora = DateTime.now().toIso8601String();

      final projetoParaSalvar = projeto.copyWith(
        updatedAt: agora,
      );

      await txn.update(
        'cronogramas',
        projetoParaSalvar.toMap(),
        where: 'id = ?',
        whereArgs: [projeto.id],
      );

      await txn.delete(
        'cronograma_itens',
        where: 'cronograma_id = ?',
        whereArgs: [projeto.id],
      );

      for (final item in projeto.itens) {
        final dadosItem = item.toMap()
          ..['id'] = null
          ..['cronograma_id'] = projeto.id;

        await txn.insert('cronograma_itens', dadosItem);
      }
    });
  }

  Future<int> excluirCronograma(int id) async {
    final db = await this.db;

    return db.transaction<int>((txn) async {
      await txn.delete(
        'cronograma_itens',
        where: 'cronograma_id = ?',
        whereArgs: [id],
      );

      final qtd = await txn.delete(
        'cronogramas',
        where: 'id = ?',
        whereArgs: [id],
      );

      return qtd;
    });
  }

  Future<List<CronogramaProjeto>> listarCronogramas() async {
    final db = await this.db;

    final resultado = await db.rawQuery('''
  SELECT
    c.*,
    cli.nome AS cliente_nome,
    cli.logo_path AS cliente_logo_path,
    s.nome AS setor_nome
  FROM cronogramas c
  LEFT JOIN clientes cli ON cli.id = c.cliente_id
  LEFT JOIN setores s ON s.id = c.setor_id
  ORDER BY c.created_at DESC, c.id DESC
''');

    final List<CronogramaProjeto> projetos = [];

    for (final map in resultado) {
      final projetoBase = CronogramaProjeto.fromMap(map);
      final projetoId = projetoBase.id;

      final itens = projetoId == null
          ? <CronogramaItem>[]
          : await listarItensDoCronograma(projetoId);

      projetos.add(projetoBase.copyWith(itens: itens));
    }

    return projetos;
  }

  Future<CronogramaProjeto?> buscarPorId(int id) async {
    final db = await this.db;

    final cab = await db.rawQuery('''
  SELECT
    c.*,
    cli.nome AS cliente_nome,
    cli.logo_path AS cliente_logo_path,
    s.nome AS setor_nome
  FROM cronogramas c
  LEFT JOIN clientes cli ON cli.id = c.cliente_id
  LEFT JOIN setores s ON s.id = c.setor_id
  WHERE c.id = ?
  LIMIT 1
''', [id]);

    if (cab.isEmpty) return null;

    final projeto = CronogramaProjeto.fromMap(cab.first);

    final itensRows = await db.query(
      'cronograma_itens',
      where: 'cronograma_id = ?',
      whereArgs: [id],
      orderBy: 'id ASC',
    );

    final itens = itensRows.map(CronogramaItem.fromMap).toList();

    return projeto.copyWith(itens: itens);
  }

  Future<List<CronogramaItem>> listarItensDoCronograma(int cronogramaId) async {
    final db = await this.db;

    final rows = await db.query(
      'cronograma_itens',
      where: 'cronograma_id = ?',
      whereArgs: [cronogramaId],
      orderBy: 'id ASC',
    );

    return rows.map(CronogramaItem.fromMap).toList();
  }
}