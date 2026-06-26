import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../domain/cliente.dart';
import '../domain/setor.dart';
import '../domain/cliente_com_setores.dart';

class ClienteRepository {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    sqfliteFfiInit();

    final Directory appDir = await getApplicationSupportDirectory();
    await Directory(appDir.path).create(recursive: true);

    final String dbPath = join(appDir.path, 'helios.db');
    print('CLIENTE_REPOSITORY -> caminho do banco: $dbPath');

    _database = await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: (db, version) async {
          await db.execute('''
        CREATE TABLE IF NOT EXISTS clientes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT NOT NULL,
          logo_path TEXT,
          dias_atendimento TEXT,
          cor_agenda TEXT
        );
      ''');

          await db.execute('''
        CREATE TABLE setores (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cliente_id INTEGER NOT NULL,
          nome TEXT NOT NULL
        )
      ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
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
          }

          if (oldVersion < 3) {
            await db.execute(
              "ALTER TABLE clientes ADD COLUMN dias_atendimento TEXT DEFAULT ''",
            );
            await db.execute(
              "ALTER TABLE clientes ADD COLUMN cor_agenda TEXT DEFAULT '#FEF3C7'",
            );
          }
        },
      ),
    );

    return _database!;
  }

  Future<int> inserirCliente(Cliente cliente) async {
    final db = await database;
    return db.insert('clientes', cliente.toMap());
  }

  Future<int> inserirSetor(Setor setor) async {
    final db = await database;
    return db.insert('setores', setor.toMap());
  }

  Future<void> excluirSetoresDoCliente(int clienteId) async {
    final db = await database;
    await db.delete(
      'setores',
      where: 'cliente_id = ?',
      whereArgs: [clienteId],
    );
  }

  Future<void> atualizarCliente(Cliente cliente) async {
    final db = await database;
    await db.update(
      'clientes',
      cliente.toMap(),
      where: 'id = ?',
      whereArgs: [cliente.id],
    );
  }

  Future<void> salvarClienteComSetores({
    required Cliente cliente,
    required List<String> setores,
  }) async {
    final db = await database;

    await db.transaction((txn) async {
      int clienteId;

      if (cliente.id == null) {
        clienteId = await txn.insert('clientes', cliente.toMap());
      } else {
        clienteId = cliente.id!;
        await txn.update(
          'clientes',
          cliente.toMap(),
          where: 'id = ?',
          whereArgs: [clienteId],
        );

        await txn.delete(
          'setores',
          where: 'cliente_id = ?',
          whereArgs: [clienteId],
        );
      }

      for (final setor in setores) {
        final nome = setor.trim();
        if (nome.isEmpty) continue;

        await txn.insert('setores', {
          'cliente_id': clienteId,
          'nome': nome,
        });
      }
    });
  }

  Future<List<Cliente>> listarClientes() async {
    final db = await database;
    final resultado = await db.query(
      'clientes',
      orderBy: 'nome ASC',
    );

    return resultado.map((map) => Cliente.fromMap(map)).toList();
  }

  Future<List<Setor>> listarSetoresPorCliente(int clienteId) async {
    final db = await database;
    final resultado = await db.query(
      'setores',
      where: 'cliente_id = ?',
      whereArgs: [clienteId],
      orderBy: 'nome ASC',
    );

    return resultado.map((map) => Setor.fromMap(map)).toList();
  }

  Future<List<Setor>> listarTodosSetores() async {
    final db = await database; // use o mesmo getter que você já usa em listarClientes()
    final result = await db.query('setores');
    return result.map((m) => Setor.fromMap(m)).toList();
  }

  Future<List<ClienteComSetores>> listarClientesComSetores() async {
    final clientes = await listarClientes();
    final List<ClienteComSetores> lista = [];

    for (final cliente in clientes) {
      if (cliente.id == null) continue;

      final setores = await listarSetoresPorCliente(cliente.id!);
      lista.add(
        ClienteComSetores(
          cliente: cliente,
          setores: setores,
        ),
      );
    }

    return lista;
  }

  Future<void> excluirCliente(int clienteId) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete(
        'setores',
        where: 'cliente_id = ?',
        whereArgs: [clienteId],
      );

      await txn.delete(
        'clientes',
        where: 'id = ?',
        whereArgs: [clienteId],
      );
    });
  }
}