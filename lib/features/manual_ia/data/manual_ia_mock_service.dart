import '../domain/manual_ia.dart';

class ManualIaService {
  Future<String> gerarConteudo(ManualIa manual) async {
    final cliente = manual.cliente.isEmpty ? 'Cliente não informado' : manual.cliente;
    final programa = manual.programaMo.isEmpty ? 'Programa não informado' : manual.programaMo;
    final nomeManual = manual.nomeManual.isEmpty ? 'Manual sem nome' : manual.nomeManual;
    final objetivo = manual.objetivo.isEmpty
        ? 'Padronizar a execução da rotina e facilitar a consulta pelos usuários.'
        : manual.objetivo;
    final descricaoRotina = manual.descricaoRotina.isEmpty
        ? 'A rotina contempla atividades operacionais executadas diariamente no sistema.'
        : manual.descricaoRotina;
    final passoAPasso = manual.passoAPasso.isEmpty
        ? '1. Acessar o programa.\n'
        '2. Informar os dados obrigatórios.\n'
        '3. Validar as informações.\n'
        '4. Confirmar a execução.\n'
        '5. Consultar o resultado.'
        : manual.passoAPasso;
    final observacoes = manual.observacoes.isEmpty
        ? 'Manter atenção aos campos obrigatórios e às validações exibidas na tela.'
        : manual.observacoes;

    return '''
🎯 Finalidade
Orientar os usuários do cliente $cliente na utilização do manual "$nomeManual", garantindo execução padronizada, clareza operacional e apoio no uso do programa $programa.

💡 Conceito
Este material foi estruturado como um ${manual.tipoManual.toLowerCase()}, com linguagem simples e foco prático para apoiar consulta rápida da rotina.

📌 Abrangência
O conteúdo se aplica exclusivamente ao cliente $cliente e ao processo relacionado ao programa M&O $programa.

🎯 Objetivo
$objetivo

⚙️ Atividade
Descrição da rotina:
$descricaoRotina

Passo a passo:
$passoAPasso

Observações:
$observacoes

🖥️ Tela
A tela utilizada nesta rotina possui apoio visual para preenchimento, conferência de dados e execução das ações principais do processo. Quando disponível, a imagem anexada serve como referência visual do ambiente operacional.

🏁 Resultado
Ao final da execução, o usuário consegue concluir a atividade com mais segurança, reduzir dúvidas operacionais e manter maior consistência no processo.
''';
  }
}