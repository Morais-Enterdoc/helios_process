import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

import 'chamado.dart';

class ChamadoImportResultado {
  final List<Chamado> chamados;
  final int novos;
  final int atualizados;

  const ChamadoImportResultado({
    required this.chamados,
    required this.novos,
    required this.atualizados,
  });
}

class ChamadoImportService {
  Future<ChamadoImportResultado?> importarCsv({
    required List<Chamado> chamadosAtuais,
  }) async {
    final resultadoArquivo = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (resultadoArquivo == null || resultadoArquivo.files.isEmpty) {
      return null;
    }

    final arquivo = resultadoArquivo.files.first;
    final bytes = arquivo.bytes;

    if (bytes == null) {
      throw Exception('Não foi possível ler o arquivo CSV.');
    }

    String conteudo;

    try {
      conteudo = utf8.decode(bytes);
    } catch (_) {
      conteudo = latin1.decode(bytes);
    }

    final linhas = const CsvToListConverter(
      fieldDelimiter: ';',
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(conteudo);

    if (linhas.isEmpty) {
      throw Exception('O arquivo CSV está vazio.');
    }

    final cabecalho = linhas.first.map((e) => e.toString().trim()).toList();
    final registros = linhas.skip(1);

    final Map<String, Chamado> chamadosImportadosPorTicket = {};

    for (final linha in registros) {
      if (linha.isEmpty) continue;

      final registro = <String, String>{};

      for (int i = 0; i < cabecalho.length; i++) {
        final chave = cabecalho[i];
        final valor = i < linha.length ? linha[i].toString().trim() : '';
        registro[chave] = valor;
      }

      final ticket = registro['Ticket'] ?? '';
      if (ticket.isEmpty) continue;

      final data = registro['Data'] ?? '';
      final fim = registro['Fim'] ?? '';
      final dataHoraAtualizacao = '$data $fim'.trim();

      final chamadoNovo = Chamado(
        ticket: ticket,
        cliente: registro['Cliente'] ?? '',
        solicitante: registro['Solicitante'] ?? '',
        assunto: registro['Assunto'] ?? '',
        descricao: '',
        numeroRo: '',
        categoria: registro['Categoria'] ?? '',
        status: registro['Status'] ?? '',
        servico: registro['Serviço'] ?? '',
        dataAbertura: data,
        prazoEntrega: '',
        ultimaAtualizacao: dataHoraAtualizacao,
        agenteAtual: registro['Agente'] ?? '',
        equipeAtual: registro['Equipe'] ?? '',
        anotacoes: '',
        meuStatus: 'Em análise',
        anexos: [],
      );

      final chamadoExistente = chamadosImportadosPorTicket[ticket];

      if (chamadoExistente == null) {
        chamadosImportadosPorTicket[ticket] = chamadoNovo;
      } else {
        final atualizacaoMaisRecente = _compararDataHora(
          chamadoNovo.ultimaAtualizacao,
          chamadoExistente.ultimaAtualizacao,
        ) >=
            0;

        chamadosImportadosPorTicket[ticket] = Chamado(
          ticket: ticket,
          cliente: chamadoExistente.cliente.isNotEmpty
              ? chamadoExistente.cliente
              : chamadoNovo.cliente,
          solicitante: chamadoExistente.solicitante.isNotEmpty
              ? chamadoExistente.solicitante
              : chamadoNovo.solicitante,
          assunto: chamadoExistente.assunto.isNotEmpty
              ? chamadoExistente.assunto
              : chamadoNovo.assunto,
          descricao: chamadoExistente.descricao,
          numeroRo: chamadoExistente.numeroRo,
          categoria: chamadoExistente.categoria.isNotEmpty
              ? chamadoExistente.categoria
              : chamadoNovo.categoria,
          status: atualizacaoMaisRecente
              ? chamadoNovo.status
              : chamadoExistente.status,
          servico: chamadoExistente.servico.isNotEmpty
              ? chamadoExistente.servico
              : chamadoNovo.servico,
          dataAbertura: _menorData(
            chamadoExistente.dataAbertura,
            chamadoNovo.dataAbertura,
          ),
          prazoEntrega: chamadoExistente.prazoEntrega.isNotEmpty
              ? chamadoExistente.prazoEntrega
              : chamadoNovo.prazoEntrega,
          ultimaAtualizacao: atualizacaoMaisRecente
              ? chamadoNovo.ultimaAtualizacao
              : chamadoExistente.ultimaAtualizacao,
          agenteAtual: atualizacaoMaisRecente
              ? chamadoNovo.agenteAtual
              : chamadoExistente.agenteAtual,
          equipeAtual: atualizacaoMaisRecente
              ? chamadoNovo.equipeAtual
              : chamadoExistente.equipeAtual,
          anotacoes: chamadoExistente.anotacoes,
          meuStatus: chamadoExistente.meuStatus,
          anexos: chamadoExistente.anexos,
        );
      }
    }

    final Map<String, Chamado> chamadosFinais = {
      for (final chamado in chamadosAtuais) chamado.ticket: chamado,
    };

    int novos = 0;
    int atualizados = 0;

    chamadosImportadosPorTicket.forEach((ticket, chamadoImportado) {
      if (chamadosFinais.containsKey(ticket)) {
        final chamadoAtual = chamadosFinais[ticket]!;

        chamadosFinais[ticket] = Chamado(
          ticket: chamadoImportado.ticket,
          cliente: chamadoImportado.cliente,
          solicitante: chamadoImportado.solicitante,
          assunto: chamadoImportado.assunto,
          descricao: chamadoAtual.descricao,
          numeroRo: chamadoAtual.numeroRo,
          categoria: chamadoImportado.categoria,
          status: chamadoImportado.status,
          servico: chamadoImportado.servico,
          dataAbertura: chamadoImportado.dataAbertura,
          prazoEntrega: chamadoAtual.prazoEntrega.isNotEmpty
              ? chamadoAtual.prazoEntrega
              : chamadoImportado.prazoEntrega,
          ultimaAtualizacao: chamadoImportado.ultimaAtualizacao,
          agenteAtual: chamadoImportado.agenteAtual,
          equipeAtual: chamadoImportado.equipeAtual,
          anotacoes: chamadoAtual.anotacoes,
          meuStatus: chamadoAtual.meuStatus,
          anexos: chamadoAtual.anexos,
        );

        atualizados++;
      } else {
        chamadosFinais[ticket] = chamadoImportado;
        novos++;
      }
    });

    final listaFinal = chamadosFinais.values.toList()
      ..sort(
            (a, b) => _compararDataHora(
          b.ultimaAtualizacao,
          a.ultimaAtualizacao,
        ),
      );

    return ChamadoImportResultado(
      chamados: listaFinal,
      novos: novos,
      atualizados: atualizados,
    );
  }

  int _compararDataHora(String valor1, String valor2) {
    final data1 = _parseDataHora(valor1);
    final data2 = _parseDataHora(valor2);
    return data1.compareTo(data2);
  }

  DateTime _parseDataHora(String valor) {
    try {
      final partes = valor.split(' ');
      final data = partes.isNotEmpty ? partes[0] : '';
      final hora = partes.length > 1 ? partes[1] : '00:00';

      final dataPartes = data.split('/');
      final horaPartes = hora.split(':');

      if (dataPartes.length != 3) {
        return DateTime(1900);
      }

      final dia = int.tryParse(dataPartes[0]) ?? 1;
      final mes = int.tryParse(dataPartes[1]) ?? 1;
      final ano = int.tryParse(dataPartes[2]) ?? 1900;
      final h = horaPartes.isNotEmpty ? int.tryParse(horaPartes[0]) ?? 0 : 0;
      final m = horaPartes.length > 1 ? int.tryParse(horaPartes[1]) ?? 0 : 0;

      return DateTime(ano, mes, dia, h, m);
    } catch (_) {
      return DateTime(1900);
    }
  }

  String _menorData(String data1, String data2) {
    final d1 = _parseDataHora(data1);
    final d2 = _parseDataHora(data2);

    if (d1.isBefore(d2)) return data1;
    return data2;
  }
}