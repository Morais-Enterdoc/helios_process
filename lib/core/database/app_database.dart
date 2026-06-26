import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  static DatabaseFactory? _dbFactory;
  static Database? _db;

  static Future<void> init() async {
    sqfliteFfiInit();
    _dbFactory = databaseFactoryFfi;
  }

  static Future<Database> instance() async {
    if (_db != null) return _db!;

    if (_dbFactory == null) {
      await init();
    }

    final Directory dir = await getApplicationSupportDirectory();
    final String dbPath = p.join(dir.path, 'helios.db');

    debugPrint('CAMINHO DO BANCO: $dbPath');

    _db = await _dbFactory!.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 12,
        onCreate: (db, version) async {
          await _createTables(db);
        },
        onOpen: (db) async {
          await _createTables(db);

          await _addColumnIfNotExists(db, 'clientes', 'dias_atendimento', 'TEXT');
          await _addColumnIfNotExists(db, 'clientes', 'cor_agenda', 'TEXT');
          await _addColumnIfNotExists(db, 'clientes', 'logo_path', 'TEXT');

          await _addColumnIfNotExists(db, 'tarefas', 'origem_tipo', 'TEXT');
          await _addColumnIfNotExists(db, 'tarefas', 'origem_id', 'INTEGER');
          await _addColumnIfNotExists(db, 'tarefas', 'cliente_nome_ref', 'TEXT');
          await _addColumnIfNotExists(db, 'tarefas', 'projeto_ref', 'TEXT');
          await _addColumnIfNotExists(db, 'tarefas', 'chamado_ref', 'TEXT');

          await _addColumnIfNotExists(db, 'chamados', 'numero_ro', 'TEXT');
          await _addColumnIfNotExists(db, 'chamados', 'prazo_entrega', 'TEXT');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 3) {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS tarefas (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                clienteid INTEGER,
                titulo TEXT NOT NULL,
                descricao TEXT,
                data TEXT NOT NULL,
                horainicio TEXT NOT NULL,
                horafim TEXT NOT NULL,
                status TEXT NOT NULL DEFAULT 'Planejada',
                tempoacumuladosegundos INTEGER NOT NULL DEFAULT 0,
                iniciadaem TEXT,
                encerradaem TEXT,
                observacoes TEXT,
                sincronizadaagendaexterna INTEGER NOT NULL DEFAULT 0,
                origem TEXT NOT NULL DEFAULT 'manual',
                eventoexternoid TEXT,
                cor TEXT,
                createdat TEXT NOT NULL,
                updatedat TEXT NOT NULL,
                origemtipo TEXT,
                origemid INTEGER,
                clientenomeref TEXT,
                projetoref TEXT,
                chamadoref TEXT,
                FOREIGN KEY (clienteid) REFERENCES clientes(id)
              );
            ''');
          }

          if (oldVersion < 5) {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS agenda_manual (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                titulo TEXT NOT NULL,
                descricao TEXT,
                observacoes TEXT,
                data TEXT NOT NULL,
                hora_inicio TEXT,
                hora_fim TEXT,
                status TEXT NOT NULL,
                cor TEXT,
                tipo_vinculo TEXT NOT NULL DEFAULT 'geral',
                vinculo_id INTEGER,
                created_at TEXT,
                updated_at TEXT
              )
            ''');
          }

          if (oldVersion < 6) {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS as_is (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                sipoc_id INTEGER NOT NULL,
                titulo TEXT,
                descricao TEXT,
                responsavel TEXT,
                data_registro TEXT
              )
            ''');
          }

          if (oldVersion < 7) {
            await _addColumnIfNotExists(db, 'as_is', 'processo', 'TEXT');
            await _addColumnIfNotExists(db, 'as_is', 'fluxo', 'TEXT');
            await _addColumnIfNotExists(
              db,
              'as_is',
              'ordem_fluxo',
              'INTEGER NOT NULL DEFAULT 0',
            );
            await _addColumnIfNotExists(db, 'as_is', 'observacoes', 'TEXT');
          }

          if (oldVersion < 8) {
            await _addColumnIfNotExists(db, 'chamados', 'numero_ro', 'TEXT');
          }

          if (oldVersion < 9) {
          await _addColumnIfNotExists(
          db,
          'clientes',
          'dias_atendimento',
          'TEXT',
          );
          await _addColumnIfNotExists(
          db,
          'clientes',
          'cor_agenda',
          'TEXT',
          );
          await _addColumnIfNotExists(
          db,
          'clientes',
          'logo_path',
          'TEXT',
          );
          }

          if (oldVersion < 10) {
          await _addColumnIfNotExists(db, 'tarefas', 'origem_tipo', 'TEXT');
          await _addColumnIfNotExists(db, 'tarefas', 'origem_id', 'INTEGER');
          await _addColumnIfNotExists(db, 'tarefas', 'cliente_nome_ref', 'TEXT');
          await _addColumnIfNotExists(db, 'tarefas', 'projeto_ref', 'TEXT');
          await _addColumnIfNotExists(db, 'tarefas', 'chamado_ref', 'TEXT');
          }

          if (oldVersion < 11) {
          await _addColumnIfNotExists(db, 'chamados', 'prazo_entrega', 'TEXT');
          }

          if (oldVersion < 12) {
            await _addColumnIfNotExists(
              db,
              'agenda_manual',
              'tipo_vinculo',
              "TEXT NOT NULL DEFAULT 'geral'",
            );
            await _addColumnIfNotExists(
              db,
              'agenda_manual',
              'vinculo_id',
              'INTEGER',
            );
          }

        },
      ),
    );

    return _db!;

  }



  static Future<bool> _tableExists(Database db, String table) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name = ?",
      [table],
    );
    return result.isNotEmpty;
  }

  static Future<bool> _columnExists(
      Database db,
      String table,
      String column,
      ) async {
    final exists = await _tableExists(db, table);
    if (!exists) return false;

    final result = await db.rawQuery("PRAGMA table_info($table)");
    return result.any((row) => row['name']?.toString() == column);
  }

  static Future<void> _addColumnIfNotExists(
      Database db,
      String table,
      String column,
      String definition,
      ) async {
    final exists = await _columnExists(db, table, column);
    if (!exists) {
      await db.execute(
        "ALTER TABLE $table ADD COLUMN $column $definition",
      );
    }
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chamados (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ticket TEXT NOT NULL,
        cliente TEXT NOT NULL,
        solicitante TEXT,
        assunto TEXT NOT NULL,
        categoria TEXT NOT NULL,
        status TEXT NOT NULL,
        servico TEXT,
        data_abertura TEXT NOT NULL,
        prazo_entrega TEXT,
        ultima_atualizacao TEXT,
        agente_atual TEXT,
        equipe_atual TEXT,
        anotacoes TEXT,
        descricao TEXT,
        numero_ro TEXT,
        meu_status TEXT,
        anexos TEXT
      );
    ''');

    await db.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_chamados_ticket
      ON chamados(ticket);
    ''');

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
      CREATE TABLE IF NOT EXISTS tarefas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER,
        titulo TEXT NOT NULL,
        descricao TEXT,
        data TEXT NOT NULL,
        hora_inicio TEXT NOT NULL,
        hora_fim TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'Planejada',
        tempo_acumulado_segundos INTEGER NOT NULL DEFAULT 0,
        iniciada_em TEXT,
        encerrada_em TEXT,
        observacoes TEXT,
        sincronizada_agenda_externa INTEGER NOT NULL DEFAULT 0,
        origem TEXT NOT NULL DEFAULT 'manual',
        evento_externo_id TEXT,
        cor TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (cliente_id) REFERENCES clientes(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS cronogramas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER NOT NULL,
        setor_id INTEGER NOT NULL,
        nome_projeto TEXT NOT NULL,
        responsavel TEXT,
        data_inicio TEXT,
        data_termino TEXT,
        realizado_percentual INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'Em andamento',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (cliente_id) REFERENCES clientes(id),
        FOREIGN KEY (setor_id) REFERENCES setores(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS cronograma_itens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cronograma_id INTEGER NOT NULL,
        atividade TEXT NOT NULL,
        responsavel TEXT,
        data_inicio TEXT,
        dias_uteis INTEGER NOT NULL DEFAULT 1,
        dias_corridos INTEGER NOT NULL DEFAULT 1,
        data_termino TEXT,
        data_proxima_acao TEXT,
        realizado_percentual INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'Em andamento',
        inicio_semana INTEGER NOT NULL DEFAULT 0,
        duracao_semanas INTEGER NOT NULL DEFAULT 1,
        destaque INTEGER NOT NULL DEFAULT 0,
        nivel INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (cronograma_id) REFERENCES cronogramas(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS agenda_manual (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descricao TEXT,
        observacoes TEXT,
        data TEXT NOT NULL,
        hora_inicio TEXT,
        hora_fim TEXT,
        status TEXT NOT NULL,
        cor TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS as_is (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sipoc_id INTEGER NOT NULL,
        titulo TEXT,
        descricao TEXT,
        processo TEXT,
        fluxo TEXT,
        ordem_fluxo INTEGER NOT NULL DEFAULT 0,
        responsavel TEXT,
        data_registro TEXT,
        observacoes TEXT
      )
    ''');
  }
}