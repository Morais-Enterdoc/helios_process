import 'dart:convert';
import 'package:sqflite_common/sqlite_api.dart';
import '../../../core/database/app_database.dart';
import '../domain/chamado.dart';
class ChamadoRepository {
  Future<Database> get _database async => AppDatabase.instance();

  Future<List<Chamado>> listarChamados() async {
    final db = await _database;

    final resultado = await db.query(
      'chamados',
      orderBy: 'id DESC',
    );

    return resultado.map(_mapToChamado).toList();
  }

  Future<void> inserirChamado(Chamado chamado) async {
    final db = await _database;

    await db.insert(
      'chamados',
      _chamadoToMap(chamado),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> atualizarChamado(Chamado chamado) async {
    final db = await _database;

    await db.update(
      'chamados',
      _chamadoToMap(chamado),
      where: 'ticket = ?',
      whereArgs: [chamado.ticket],
    );
  }

  Future<int> atualizarMeuStatusEmLote({
    required String statusChamado,
    required String novoMeuStatus,
  }) async {
    final db = await _database;

    final linhasAfetadas = await db.update(
      'chamados',
      {'meu_status': novoMeuStatus},
      where: 'status = ?',
      whereArgs: [statusChamado],
    );

    return linhasAfetadas;
  }

  Future<void> excluirChamado(String ticket) async {
    final db = await _database;

    await db.delete(
      'chamados',
      where: 'ticket = ?',
      whereArgs: [ticket],
    );
  }

  Future<int> atualizarMeuStatusPorStatusAtual({
    required String statusAtual,
    required String novoMeuStatus,
  }) async {
    final db = await _database;

    return await db.update(
      'chamados',
      {
        'meu_status': novoMeuStatus,
      },
      where: 'status = ?',
      whereArgs: [statusAtual],
    );
  }



  Map<String, dynamic> _chamadoToMap(Chamado chamado) {
    return {
      'ticket': chamado.ticket,
      'cliente': chamado.cliente,
      'solicitante': chamado.solicitante,
      'assunto': chamado.assunto,
      'descricao': chamado.descricao,
      'numero_ro': chamado.numeroRo,
      'categoria': chamado.categoria,
      'status': chamado.status,
      'servico': chamado.servico,
      'data_abertura': chamado.dataAbertura,
      'ultima_atualizacao': chamado.ultimaAtualizacao,
      'agente_atual': chamado.agenteAtual,
      'equipe_atual': chamado.equipeAtual,
      'anotacoes': chamado.anotacoes,
      'meu_status': chamado.meuStatus,
      'anexos': jsonEncode(chamado.anexos),
      'prazo_entrega': _resolverPrazoEntrega(
        chamado.dataAbertura,
        chamado.prazoEntrega,
      ),
    };
  }

  Chamado _mapToChamado(Map map) {
    final idResolvido = _resolverIdChamado(map);

    return Chamado(
      id: idResolvido,
      ticket: map['ticket']?.toString() ?? '',
      cliente: map['cliente']?.toString() ?? '',
      solicitante: map['solicitante']?.toString() ?? '',
      assunto: map['assunto']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      numeroRo: map['numero_ro']?.toString() ?? '',
      categoria: map['categoria']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      servico: map['servico']?.toString() ?? '',
      dataAbertura: map['data_abertura']?.toString() ?? '',
      prazoEntrega: _resolverPrazoEntrega(
        map['data_abertura']?.toString() ?? '',
        map['prazo_entrega']?.toString() ?? '',
      ),
      ultimaAtualizacao: map['ultima_atualizacao']?.toString() ?? '',
      agenteAtual: map['agente_atual']?.toString() ?? '',
      equipeAtual: map['equipe_atual']?.toString() ?? '',
      anotacoes: map['anotacoes']?.toString() ?? '',
      meuStatus: map['meu_status']?.toString() ?? '',
      anexos: _parseAnexos(map['anexos']),
    );
  }

  int? _resolverIdChamado(Map map) {
    final valorId = map['id'];
    if (valorId is int) return valorId;
    if (valorId is String) return int.tryParse(valorId);

    final ticket = map['ticket']?.toString().trim() ?? '';
    return int.tryParse(ticket);
  }

  String _resolverPrazoEntrega(String dataAbertura, String prazoEntrega) {
    final prazo = prazoEntrega.trim();
    if (prazo.isNotEmpty) return prazo;

    final abertura = _tryParseData(dataAbertura);
    if (abertura == null) return '';

    final calculada = abertura.add(const Duration(days: 60));
    return _formatarData(calculada);
  }

  DateTime? _tryParseData(String valor) {
    final texto = valor.trim();
    if (texto.isEmpty) return null;

    try {
      if (texto.contains('/')) {
        final partes = texto.split('/');
        if (partes.length == 3) {
          final dia = int.tryParse(partes[0]) ?? 1;
          final mes = int.tryParse(partes[1]) ?? 1;
          final ano = int.tryParse(partes[2]) ?? 2000;
          return DateTime(ano, mes, dia);
        }
      }

      return DateTime.tryParse(texto);
    } catch (_) {
      return null;
    }
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    return '$dia/$mes/$ano';
  }

  List<String> _parseAnexos(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded.map((item) => item.toString()).toList();
      }
    } catch (_) {}

    return [];
  }
}