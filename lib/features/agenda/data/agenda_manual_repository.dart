import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../core/database/app_database.dart';
import '../domain/agenda_manual.dart';

class AgendaManualRepository {
  Future<Database> get _db async => AppDatabase.instance();

  Future<int> inserir(AgendaManual item) async {
    final db = await _db;
    return db.insert('agenda_manual', item.toMap());
  }

  Future<int> atualizar(AgendaManual item) async {
    final db = await _db;

    return db.update(
      'agenda_manual',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> excluir(int id) async {
    final db = await _db;

    return db.delete(
      'agenda_manual',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<AgendaManual?> buscarPorId(int id) async {
    final db = await _db;

    final result = await db.query(
      'agenda_manual',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return AgendaManual.fromMap(result.first);
  }

  Future<List<AgendaManual>> listarPorPeriodo({
    required String dataInicial,
    required String dataFinal,
  }) async {
    final db = await _db;

    final result = await db.query(
      'agenda_manual',
      where: 'data >= ? AND data <= ?',
      whereArgs: [dataInicial, dataFinal],
      orderBy: 'data ASC, hora_inicio ASC, id DESC',
    );

    return result.map(AgendaManual.fromMap).toList();
  }

  Future<List<AgendaManual>> listarTodos() async {
    final db = await _db;

    final result = await db.query(
      'agenda_manual',
      orderBy: 'data ASC, hora_inicio ASC, id DESC',
    );

    return result.map(AgendaManual.fromMap).toList();
  }

  Future<void> excluirAgenda(int id) async {
    final db = await AppDatabase.instance();

    await db.delete(
      'agenda_manual',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> atualizarAgendaManual(AgendaManual item) async {
    final db = await AppDatabase.instance();

    await db.update(
      'agenda_manual',
      {
        'titulo': item.titulo,
        'descricao': item.descricao,
        'observacoes': item.observacoes,
        'data': item.data,
        'hora_inicio': item.horaInicio,
        'hora_fim': item.horaFim,
        'status': item.status,
        'cor': item.cor,
        'tipo_vinculo': item.tipoVinculo,
        'vinculo_id': item.vinculoId,
        'created_at': item.createdAt,
        'updated_at': item.updatedAt,
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }
}