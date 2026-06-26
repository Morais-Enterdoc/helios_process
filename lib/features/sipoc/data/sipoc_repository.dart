import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../domain/sipoc.dart';
import '../domain/sipoc_detalhe.dart';

class SipocRepository {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    sqfliteFfiInit();

    final Directory appDir = await getApplicationSupportDirectory();
    await Directory(appDir.path).create(recursive: true);

    final String dbPath = join(appDir.path, 'helios.db');
    print('SIPOC_REPOSITORY -> caminho do banco: $dbPath');

    _database = await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 4,
        onCreate: (db, version) async {
          print('SIPOC_REPOSITORY -> onCreate disparado. version: $version');

          await db.execute('''
          CREATE TABLE clientes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            logo_path TEXT
          )
        ''');
          print('SIPOC_REPOSITORY -> tabela clientes criada');

          await db.execute('''
          CREATE TABLE setores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cliente_id INTEGER NOT NULL,
            nome TEXT NOT NULL
          )
        ''');
          print('SIPOC_REPOSITORY -> tabela setores criada');

          await db.execute('''
          CREATE TABLE sipocs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cliente_id INTEGER NOT NULL,
            setor_id INTEGER NOT NULL,
            titulo TEXT,
            parte TEXT,
            codigo TEXT,
            revisao TEXT,
            data_emissao TEXT,
            responsaveis TEXT,
            objetivo TEXT,
            fornecedores TEXT,
            entradas TEXT,
            processo TEXT,
            saidas TEXT,
            clientes TEXT,
            indicadores TEXT,
            fluxo_texto TEXT
          )
        ''');
          print('SIPOC_REPOSITORY -> tabela sipocs criada');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          print(
            'SIPOC_REPOSITORY -> onUpgrade disparado. oldVersion: $oldVersion | newVersion: $newVersion',
          );

          if (oldVersion < 2) {
            print('SIPOC_REPOSITORY -> criando/garantindo tabelas clientes e setores');

            await db.execute('''
            CREATE TABLE IF NOT EXISTS clientes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nome TEXT NOT NULL,
              logo_path TEXT
            )
          ''');
            print('SIPOC_REPOSITORY -> clientes ok');

            await db.execute('''
            CREATE TABLE IF NOT EXISTS setores (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              cliente_id INTEGER NOT NULL,
              nome TEXT NOT NULL
            )
          ''');
            print('SIPOC_REPOSITORY -> setores ok');
          }

          if (oldVersion < 3) {
            print('SIPOC_REPOSITORY -> criando/garantindo tabela sipocs');

            await db.execute('''
            CREATE TABLE IF NOT EXISTS sipocs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              cliente_id INTEGER NOT NULL,
              setor_id INTEGER NOT NULL,
              titulo TEXT,
              codigo TEXT,
              revisao TEXT,
              data_emissao TEXT,
              responsaveis TEXT,
              objetivo TEXT,
              fornecedores TEXT,
              entradas TEXT,
              processo TEXT,
              saidas TEXT,
              clientes TEXT,
              indicadores TEXT,
              fluxo_texto TEXT
            )
          ''');
            print('SIPOC_REPOSITORY -> sipocs ok');
          }

          if (oldVersion < 4) {
            print('SIPOC_REPOSITORY -> tentando adicionar coluna parte');

            try {
              await db.execute('ALTER TABLE sipocs ADD COLUMN parte TEXT');
              print('SIPOC_REPOSITORY -> coluna parte adicionada');
            } catch (e) {
              print('SIPOC_REPOSITORY -> coluna parte ja existia ou falhou: $e');
            }
          }
        },
      ),
    );

    return _database!;
  }

  Future<void> _garantirEstruturaSipoc(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS clientes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      logo_path TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS setores (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cliente_id INTEGER NOT NULL,
      nome TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS sipocs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cliente_id INTEGER NOT NULL,
      setor_id INTEGER NOT NULL,
      titulo TEXT,
      parte TEXT,
      codigo TEXT,
      revisao TEXT,
      data_emissao TEXT,
      responsaveis TEXT,
      objetivo TEXT,
      fornecedores TEXT,
      entradas TEXT,
      processo TEXT,
      saidas TEXT,
      clientes TEXT,
      indicadores TEXT,
      fluxo_texto TEXT
    )
  ''');

    try {
      await db.execute('ALTER TABLE sipocs ADD COLUMN parte TEXT');
    } catch (_) {}
  }

  Future<int> inserirSipoc(Sipoc sipoc) async {
    final db = await database;
    await _garantirEstruturaSipoc(db);
    return db.insert('sipocs', sipoc.toMap());
  }

  Future<void> atualizarSipoc(Sipoc sipoc) async {
    final db = await database;
    await _garantirEstruturaSipoc(db);

    print('UPDATE SIPOC -> id: ${sipoc.id}');
    print('UPDATE SIPOC -> payload: ${sipoc.toMap(includeId: false)}');

    final linhasAfetadas = await db.update(
      'sipocs',
      sipoc.toMap(includeId: false),
      where: 'id = ?',
      whereArgs: [sipoc.id],
    );

    print('UPDATE SIPOC -> linhas afetadas: $linhasAfetadas');

    final registro = await db.query(
      'sipocs',
      where: 'id = ?',
      whereArgs: [sipoc.id],
    );

    print('UPDATE SIPOC -> banco apos salvar: $registro');
  }

  Future<void> excluirSipoc(int sipocId) async {
    final db = await database;
    await _garantirEstruturaSipoc(db);
    await db.delete(
      'sipocs',
      where: 'id = ?',
      whereArgs: [sipocId],
    );
  }

  Future<List<SipocDetalhe>> listarSipocsDetalhe() async {
    final db = await database;
    await _garantirEstruturaSipoc(db);

    final result = await db.rawQuery('''
    SELECT
      s.id,
      s.cliente_id,
      s.setor_id,
      s.titulo,
      s.parte,
      s.codigo,
      s.revisao,
      s.data_emissao,
      s.responsaveis,
      s.objetivo,
      s.fornecedores,
      s.entradas,
      s.processo,
      s.saidas,
      s.clientes,
      s.indicadores,
      s.fluxo_texto,
      c.nome AS cliente_nome,
      c.logo_path AS cliente_logo_path,
      st.nome AS setor_nome
    FROM sipocs s
    LEFT JOIN clientes c ON c.id = s.cliente_id
    LEFT JOIN setores st
      ON st.id = s.setor_id
     AND st.cliente_id = s.cliente_id
    ORDER BY s.id DESC
  ''');

    print('SIPOC_REPOSITORY -> listarSipocsDetalhe result: $result');

    return result.map((map) => SipocDetalhe.fromMap(map)).toList();
  }

  Future<void> debugBanco() async {
    final db = await database;

    final clientes = await db.query('clientes');
    final setores = await db.query('setores');
    final sipocs = await db.query('sipocs');

    print('DEBUG clientes: $clientes');
    print('DEBUG setores: $setores');
    print('DEBUG sipocs: $sipocs');
  }

}