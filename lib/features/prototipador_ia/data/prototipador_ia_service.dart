import 'dart:convert';

import 'package:http/http.dart' as http;

class PrototipadorIaService {
  static const String _apiUrl = 'COLOQUE_AQUI_SUA_URL_DA_API';
  static const String _apiKey = 'COLOQUE_AQUI_SUA_CHAVE_DA_API';

  Future<String> gerarDocumentacao({
    required String cliente,
    required String projetoMacroprocesso,
    required String numeroChamadoMo,
    required String tituloChamado,
    required String vinculacaoChamado,
    required String moduloMo,
    required String programaMoRelacionado,
    required String nomeTelaFuncionalidade,
    required String objetivoTela,
    required String usuariosPrincipais,
    required String prioridade,
    required String descricaoDetalhada,
    required String problemaAtual,
    required String resultadoEsperado,
    required String camposNecessarios,
    required String filtrosNecessarios,
    required String botoesNecessarios,
    required String colunasGrid,
    required String regrasNegocio,
    required String integracoesEnvolvidas,
  }) async {
    final prompt = '''
Você é um analista funcional sênior.
Gere uma documentação funcional clara, objetiva e organizada com base nos dados abaixo.

Cliente: $cliente
Projeto/Macroprocesso: $projetoMacroprocesso
Número do chamado M&O: $numeroChamadoMo
Título do chamado: $tituloChamado
Vinculação do chamado: $vinculacaoChamado
Módulo M&O: $moduloMo
Programa relacionado: $programaMoRelacionado
Nome da tela/funcionalidade: $nomeTelaFuncionalidade
Objetivo da tela: $objetivoTela
Usuários principais: $usuariosPrincipais
Prioridade: $prioridade
Descrição detalhada: $descricaoDetalhada
Problema atual: $problemaAtual
Resultado esperado: $resultadoEsperado
Campos necessários: $camposNecessarios
Filtros necessários: $filtrosNecessarios
Botões necessários: $botoesNecessarios
Colunas do grid: $colunasGrid
Regras de negócio: $regrasNegocio
Integrações envolvidas: $integracoesEnvolvidas

Estruture a resposta em tópicos:
1. Visão geral
2. Objetivo
3. Usuários envolvidos
4. Campos e filtros
5. Grid / colunas
6. Botões e ações
7. Regras de negócio
8. Integrações
9. Benefícios
10. Critérios de aceite
''';

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'prompt': prompt,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao chamar IA: ${response.statusCode} - ${response.body}');
    }

    final data = jsonDecode(response.body);

    if (data is Map<String, dynamic> && data['text'] != null) {
      return data['text'].toString();
    }

    throw Exception('Resposta da IA em formato inesperado.');
  }
}