import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../core/database/app_database.dart';
import '../domain/as_is.dart';

class AsIsRepository {
  Future<Database> get _db async => await AppDatabase.instance();

  Future<List<AsIs>> listarPorSipoc(int sipocId) async {
    final db = await _db;

    final result = await db.query(
      'as_is',
      where: 'sipoc_id = ?',
      whereArgs: [sipocId],
      orderBy: 'ordem_fluxo ASC, id ASC',
    );

    return result.map((e) => AsIs.fromMap(e)).toList();
  }

  Future<int> inserir(AsIs item) async {
    final db = await _db;

    final dados = Map<String, dynamic>.from(item.toMap());
    dados.remove('id');

    return db.insert(
      'as_is',
      dados,
    );
  }

  Future<int> atualizar(AsIs item) async {
    final db = await _db;

    final dados = Map<String, dynamic>.from(item.toMap());
    dados.remove('id');

    return db.update(
      'as_is',
      dados,
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> excluir(int id) async {
    final db = await _db;

    return db.delete(
      'as_is',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}