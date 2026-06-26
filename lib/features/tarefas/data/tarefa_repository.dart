import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../core/database/app_database.dart';
import '../domain/tarefa.dart';
import '../domain/tarefa_detalhe.dart';

class TarefaRepository {
  Future<Database> get _db async => AppDatabase.instance();

  Future inserirTarefa(Tarefa tarefa) async {
    final db = await _db;
    final dados = tarefa.toMap();

    print('===== INSERT TAREFA =====');
    print(dados);
    print('=========================');

    return db.insert('tarefas', dados);
  }

  Future<int> atualizarTarefa(Tarefa tarefa) async {
    final db = await _db;
    return db.update(
      'tarefas',
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }

  Future<int> excluirTarefa(int id) async {
    final db = await _db;
    return db.delete(
      'tarefas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Tarefa?> buscarPorId(int id) async {
    final db = await _db;
    final result = await db.query(
      'tarefas',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Tarefa.fromMap(result.first);
  }

  Future<List<Tarefa>> listarTarefas() async {
    final db = await _db;
    final result = await db.query(
      'tarefas',
      orderBy: 'data ASC, hora_inicio ASC, id DESC',
    );

    return result.map(Tarefa.fromMap).toList();
  }

  Future<List<TarefaDetalhe>> listarTarefasComCliente() async {
    final db = await _db;

    final resultado = await db.rawQuery('''
  SELECT
    t.*,
    c.nome AS cliente_nome,
    c.logo_path AS cliente_logo_path
  FROM tarefas t
  LEFT JOIN clientes c ON c.id = t.cliente_id
  ORDER BY t.data ASC, t.hora_inicio ASC, t.id DESC
''');

    return resultado.map(TarefaDetalhe.fromMap).toList();
  }

  Future<void> iniciarTarefa(int id) async {
    final db = await _db;
    final agora = DateTime.now().toIso8601String();

    await db.update(
      'tarefas',
      {
        'status': 'Em andamento',
        'iniciada_em': agora,
        'updated_at': agora,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> pausarTarefa(Tarefa tarefa) async {
    final db = await _db;
    final agora = DateTime.now();

    int acumulado = tarefa.tempoAcumuladoSegundos;

    if (tarefa.iniciadaEm != null && tarefa.iniciadaEm!.isNotEmpty) {
      final inicio = DateTime.tryParse(tarefa.iniciadaEm!);
      if (inicio != null) {
        acumulado += agora.difference(inicio).inSeconds;
      }
    }

    await db.update(
      'tarefas',
      {
        'status': 'Pausada',
        'tempo_acumulado_segundos': acumulado,
        'iniciada_em': null,
        'updated_at': agora.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }

  Future<void> fecharTarefa(Tarefa tarefa) async {
    final db = await _db;
    final agora = DateTime.now();

    int acumulado = tarefa.tempoAcumuladoSegundos;

    if (tarefa.iniciadaEm != null && tarefa.iniciadaEm!.isNotEmpty) {
      final inicio = DateTime.tryParse(tarefa.iniciadaEm!);
      if (inicio != null) {
        acumulado += agora.difference(inicio).inSeconds;
      }
    }

    await db.update(
      'tarefas',
      {
        'status': 'Fechada',
        'tempo_acumulado_segundos': acumulado,
        'iniciada_em': null,
        'encerrada_em': agora.toIso8601String(),
        'updated_at': agora.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }

  Future<void> reabrirTarefa(int id) async {
    final db = await _db;
    final agora = DateTime.now().toIso8601String();

    await db.update(
      'tarefas',
      {
        'status': 'Pausada',
        'encerrada_em': null,
        'updated_at': agora,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Tarefa>> listarPorData(String data) async {
    final db = await _db;
    final result = await db.query(
      'tarefas',
      where: 'data = ?',
      whereArgs: [data],
      orderBy: 'hora_inicio ASC, hora_fim ASC',
    );

    return result.map(Tarefa.fromMap).toList();
  }

  Future<List<Tarefa>> listarPorPeriodo({
    required String dataInicial,
    required String dataFinal,
  }) async {
    final db = await _db;
    final result = await db.query(
      'tarefas',
      where: 'data >= ? AND data <= ?',
      whereArgs: [dataInicial, dataFinal],
      orderBy: 'data ASC, hora_inicio ASC',
    );

    return result.map(Tarefa.fromMap).toList();
  }
}