import '../domain/prototipo_ia.dart';

class PrototipadorPromptBuilder {
  String build(PrototipoIa prototipo) {
    return '''
Você é um analista funcional sênior especializado em levantamento de requisitos, documentação funcional e especificação de telas corporativas.

Sua tarefa é gerar uma documentação funcional clara, objetiva, bem estruturada e profissional com base nas informações abaixo.

DADOS DO PROTÓTIPO

Cliente: ${prototipo.cliente}
Projeto / Macroprocesso: ${prototipo.projetoMacroprocesso}
Número do chamado M&O: ${prototipo.numeroChamadoMo}
Título do chamado: ${prototipo.tituloChamado}
Vinculação do chamado: ${prototipo.vinculacaoChamado}
Módulo M&O: ${prototipo.moduloMo}
Programa M&O relacionado: ${prototipo.programaMoRelacionado}
Nome da tela / funcionalidade: ${prototipo.nomeTelaFuncionalidade}
Objetivo da tela: ${prototipo.objetivoTela}
Usuários principais: ${prototipo.usuariosPrincipais}
Prioridade: ${prototipo.prioridade}
Descrição detalhada: ${prototipo.descricaoDetalhada}
Problema atual: ${prototipo.problemaAtual}
Resultado esperado: ${prototipo.resultadoEsperado}
Campos necessários: ${prototipo.camposNecessarios}
Filtros necessários: ${prototipo.filtrosNecessarios}
Botões necessários: ${prototipo.botoesNecessarios}
Colunas do grid: ${prototipo.colunasGrid}
Regras de negócio: ${prototipo.regrasNegocio}
Integrações envolvidas: ${prototipo.integracoesEnvolvidas}

Gere a resposta em português do Brasil e organize obrigatoriamente nas seguintes seções:

1. Visão geral da solicitação
2. Objetivo da funcionalidade
3. Usuários envolvidos
4. Problema atual
5. Resultado esperado
6. Estrutura da tela
7. Campos necessários
8. Filtros
9. Botões e ações
10. Grid e colunas
11. Regras de negócio
12. Integrações envolvidas
13. Critérios de aceite
14. Benefícios esperados

Regras importantes:
- Não invente informações que não estejam no texto.
- Quando algum item não tiver sido informado, sinalize isso claramente.
- Escreva de forma corporativa, funcional e objetiva.
- Não responda em JSON.
- Não use markdown em formato de tabela.
- Entregue texto pronto para uso em documentação funcional.
''';
  }
}