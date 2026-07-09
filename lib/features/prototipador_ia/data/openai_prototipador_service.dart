import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class OpenAiPrototipadorService {
  String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  String get _model => dotenv.env['OPENAI_MODEL'] ?? '';
  String get _baseUrl => dotenv.env['OPENAI_BASE_URL'] ?? '';

  Future<String> gerarTexto({
    required String prompt,
    String? fileId,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY não foi configurada no arquivo .env.');
    }

    final List<Map<String, dynamic>> input = [
      {
        'role': 'user',
        'content': [
          {
            'type': 'input_text',
            'text': prompt,
          },
        ],
      },
    ];

    if (fileId != null && fileId.isNotEmpty) {
      input[0]['content'].add(
        {
          'type': 'input_file',
          'file_id': fileId,
        },
      );
    }

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/responses'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $_apiKey',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4.1',
        'input': input,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Erro ao gerar texto com a OpenAI (${response.statusCode}): ${response.body}',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    final outputText = data['output_text']?.toString();
    if (outputText != null && outputText.trim().isNotEmpty) {
      return outputText.trim();
    }

    final output = data['output'];
    if (output is List) {
      for (final item in output) {
        if (item is Map<String, dynamic>) {
          final content = item['content'];
          if (content is List) {
            for (final part in content) {
              if (part is Map<String, dynamic>) {
                final text = part['text']?.toString();
                if (text != null && text.trim().isNotEmpty) {
                  return text.trim();
                }
              }
            }
          }
        }
      }
    }

    throw Exception('A OpenAI não retornou texto na resposta.');
  }

  String _extractOutputText(Map<String, dynamic> data) {
    final directText = data['output_text'];
    if (directText is String && directText.trim().isNotEmpty) {
      return directText;
    }

    final output = data['output'];
    if (output is List) {
      final buffer = StringBuffer();

      for (final item in output) {
        if (item is Map<String, dynamic>) {
          final content = item['content'];
          if (content is List) {
            for (final contentItem in content) {
              if (contentItem is Map<String, dynamic>) {
                final text = contentItem['text'];
                if (text is String && text.trim().isNotEmpty) {
                  if (buffer.isNotEmpty) buffer.writeln();
                  buffer.write(text);
                }
              }
            }
          }
        }
      }

      return buffer.toString();
    }

    return '';
  }
  Future<String> uploadArquivoParaOpenAi({
    required String caminhoArquivo,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY não foi configurada no arquivo .env.');
    }

    final arquivo = File(caminhoArquivo);

    if (!await arquivo.exists()) {
      throw Exception('Arquivo não encontrado no caminho informado.');
    }

    final extensao = path.extension(caminhoArquivo).toLowerCase();

    const extensoesPermitidas = {
      '.pdf',
      '.png',
      '.jpg',
      '.jpeg',
      '.webp',
      '.gif',
      '.txt',
      '.md',
      '.json',
      '.xml',
      '.html',
      '.csv',
      '.doc',
      '.docx',
      '.ppt',
      '.pptx',
      '.xls',
      '.xlsx',
    };

    if (!extensoesPermitidas.contains(extensao)) {
      throw Exception(
        'Extensão de arquivo não suportada para envio: $extensao',
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.openai.com/v1/files'),
    );

    request.headers[HttpHeaders.authorizationHeader] = 'Bearer $_apiKey';
    request.fields['purpose'] = 'user_data';
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        caminhoArquivo,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Erro ao enviar arquivo para OpenAI (${response.statusCode}): ${response.body}',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final fileId = data['id']?.toString() ?? '';

    if (fileId.isEmpty) {
      throw Exception('A OpenAI não retornou o file_id do arquivo enviado.');
    }

    return fileId;
  }
}