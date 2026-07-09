import 'package:flutter/material.dart';

import '../data/openai_prototipador_service.dart';
import '../data/prototipador_prompt_builder.dart';
import '../data/prototipo_ia_repository.dart';
import '../domain/prototipo_ia.dart';
import 'package:file_picker/file_picker.dart';

class PrototipadorIaPage extends StatefulWidget {
  const PrototipadorIaPage({super.key});

  @override
  State<PrototipadorIaPage> createState() => _PrototipadorIaPageState();
}

class _PrototipadorIaPageState extends State<PrototipadorIaPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<String> _prioridades = ['Baixa', 'Média', 'Alta', 'Crítica'];

  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _projetoMacroprocessoController = TextEditingController();
  final TextEditingController _numeroChamadoController = TextEditingController();
  final TextEditingController _tituloChamadoController = TextEditingController();
  final TextEditingController _vinculoChamadoController = TextEditingController();
  final TextEditingController _moduloMoController = TextEditingController();
  final TextEditingController _programaMoController = TextEditingController();
  final TextEditingController _nomeTelaController = TextEditingController();
  final TextEditingController _objetivoTelaController = TextEditingController();
  final TextEditingController _usuariosPrincipaisController = TextEditingController();

  final TextEditingController _descricaoDetalhadaController = TextEditingController();
  final TextEditingController _problemaAtualController = TextEditingController();
  final TextEditingController _resultadoEsperadoController = TextEditingController();
  final TextEditingController _camposNecessariosController = TextEditingController();
  final TextEditingController _filtrosNecessariosController = TextEditingController();
  final TextEditingController _botoesNecessariosController = TextEditingController();
  final TextEditingController _colunasGridController = TextEditingController();
  final TextEditingController _regrasNegocioController = TextEditingController();
  final TextEditingController _integracoesEnvolvidasController = TextEditingController();

  final PrototipoIaRepository _repository = PrototipoIaRepository();
  final PrototipadorPromptBuilder _promptBuilder = PrototipadorPromptBuilder();
  final OpenAiPrototipadorService _openAiService = OpenAiPrototipadorService();

  String _prioridadeSelecionada = 'Alta';
  PrototipoIa? _ultimoPrototipoSalvo;
  PrototipoIa? _prototipoEmEdicao;
  String _arquivoAnexadoPath = '';

  List<PrototipoIa> _historicoPrototipos = [];

  Future<void> _carregarHistorico() async {
    final historico = await _repository.listarTodos();

    if (!mounted) return;

    setState(() {
      _historicoPrototipos = historico;
    });
  }

  Future<void> _salvarPrototipoSimulado() async {
    final agora = DateTime.now();

    if (_clienteController.text.trim().isEmpty ||
        _nomeTelaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha pelo menos Cliente e Nome da tela para salvar.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final prototipo = PrototipoIa(
      id: _prototipoEmEdicao?.id ?? agora.millisecondsSinceEpoch.toString(),
      cliente: _clienteController.text.trim(),
      projetoMacroprocesso: _projetoMacroprocessoController.text.trim(),
      numeroChamadoMo: _numeroChamadoController.text.trim(),
      tituloChamado: _tituloChamadoController.text.trim(),
      vinculacaoChamado: _vinculoChamadoController.text.trim(),
      moduloMo: _moduloMoController.text.trim(),
      programaMoRelacionado: _programaMoController.text.trim(),
      nomeTelaFuncionalidade: _nomeTelaController.text.trim(),
      objetivoTela: _objetivoTelaController.text.trim(),
      usuariosPrincipais: _usuariosPrincipaisController.text.trim(),
      prioridade: _prioridadeSelecionada,
      descricaoDetalhada: _descricaoDetalhadaController.text.trim(),
      problemaAtual: _problemaAtualController.text.trim(),
      resultadoEsperado: _resultadoEsperadoController.text.trim(),
      camposNecessarios: _camposNecessariosController.text.trim(),
      filtrosNecessarios: _filtrosNecessariosController.text.trim(),
      botoesNecessarios: _botoesNecessariosController.text.trim(),
      colunasGrid: _colunasGridController.text.trim(),
      regrasNegocio: _regrasNegocioController.text.trim(),
      integracoesEnvolvidas: _integracoesEnvolvidasController.text.trim(),
      imagemTelaAtualPath: _arquivoAnexadoPath.isNotEmpty
          ? _arquivoAnexadoPath
          : _prototipoEmEdicao?.imagemTelaAtualPath ?? '',
      documentacaoGerada: _prototipoEmEdicao?.documentacaoGerada ?? '',
      htmlGerado: _prototipoEmEdicao?.htmlGerado ?? '',
      arquivoHtmlLocal: _prototipoEmEdicao?.arquivoHtmlLocal ?? '',
      createdAt: _prototipoEmEdicao?.createdAt ?? agora,
      updatedAt: agora,
    );

    await _repository.salvar(prototipo);

    setState(() {
      _ultimoPrototipoSalvo = prototipo;
      _prototipoEmEdicao = null;
    });

    await _carregarHistorico();

    _tabController.animateTo(3);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Protótipo salvo em memória com sucesso.'),
        backgroundColor: Color(0xFF059669),
      ),
    );
  }

  void _novoPrototipo() {
    _clienteController.clear();
    _projetoMacroprocessoController.clear();
    _numeroChamadoController.clear();
    _tituloChamadoController.clear();
    _vinculoChamadoController.clear();
    _moduloMoController.clear();
    _programaMoController.clear();
    _nomeTelaController.clear();
    _objetivoTelaController.clear();
    _usuariosPrincipaisController.clear();

    _descricaoDetalhadaController.clear();
    _problemaAtualController.clear();
    _resultadoEsperadoController.clear();
    _camposNecessariosController.clear();
    _filtrosNecessariosController.clear();
    _botoesNecessariosController.clear();
    _colunasGridController.clear();
    _regrasNegocioController.clear();
    _integracoesEnvolvidasController.clear();

    setState(() {
      _prioridadeSelecionada = 'Alta';
      _ultimoPrototipoSalvo = null;
      _prototipoEmEdicao = null;
      _arquivoAnexadoPath = '';
    });

    _tabController.animateTo(0);
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formulário limpo para um novo protótipo.'),
        backgroundColor: Color(0xFF2563EB),
      ),
    );
  }

  Future<void> _excluirUltimoPrototipoSalvo() async {
    if (_ultimoPrototipoSalvo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum protótipo salvo para excluir.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final id = _ultimoPrototipoSalvo!.id;
    await _repository.removerPorId(id);

    setState(() {
      _ultimoPrototipoSalvo = null;
    });

    await _carregarHistorico();

    _tabController.animateTo(0);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Último protótipo salvo foi excluído.'),
        backgroundColor: Color(0xFFDC2626),
      ),
    );
  }

  Future<void> _excluirPrototipoDoHistorico(PrototipoIa prototipo) async {
    await _repository.removerPorId(prototipo.id);

    setState(() {
      if (_ultimoPrototipoSalvo?.id == prototipo.id) {
        _ultimoPrototipoSalvo = null;
      }
    });

    await _carregarHistorico();

    _tabController.animateTo(3);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Protótipo removido do histórico com sucesso.'),
        backgroundColor: Color(0xFFDC2626),
      ),
    );
  }

  Future<void> _editarPrototipoDoHistorico(PrototipoIa prototipo) async {
    _clienteController.text = prototipo.cliente;
    _projetoMacroprocessoController.text = prototipo.projetoMacroprocesso;
    _numeroChamadoController.text = prototipo.numeroChamadoMo;
    _tituloChamadoController.text = prototipo.tituloChamado;
    _vinculoChamadoController.text = prototipo.vinculacaoChamado;
    _moduloMoController.text = prototipo.moduloMo;
    _programaMoController.text = prototipo.programaMoRelacionado;
    _nomeTelaController.text = prototipo.nomeTelaFuncionalidade;
    _objetivoTelaController.text = prototipo.objetivoTela;
    _usuariosPrincipaisController.text = prototipo.usuariosPrincipais;

    _descricaoDetalhadaController.text = prototipo.descricaoDetalhada;
    _problemaAtualController.text = prototipo.problemaAtual;
    _resultadoEsperadoController.text = prototipo.resultadoEsperado;
    _camposNecessariosController.text = prototipo.camposNecessarios;
    _filtrosNecessariosController.text = prototipo.filtrosNecessarios;
    _botoesNecessariosController.text = prototipo.botoesNecessarios;
    _colunasGridController.text = prototipo.colunasGrid;
    _regrasNegocioController.text = prototipo.regrasNegocio;
    _integracoesEnvolvidasController.text = prototipo.integracoesEnvolvidas;

    setState(() {
      _prioridadeSelecionada =
      prototipo.prioridade.isEmpty ? 'Alta' : prototipo.prioridade;
      _ultimoPrototipoSalvo = prototipo;
      _prototipoEmEdicao = prototipo;
    });

    await _carregarHistorico();

    _tabController.animateTo(0);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Protótipo carregado para edição.'),
        backgroundColor: Color(0xFF2563EB),
      ),
    );
  }

  void _abrirAbaHistorico() {
    _tabController.animateTo(3);
  }

  Future<void> _selecionarArquivoAnexo() async {
    final resultado = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf', 'doc', 'docx', 'txt'],
    );

    if (resultado == null || resultado.files.isEmpty) {
      return;
    }

    final arquivo = resultado.files.first;
    final caminho = arquivo.path ?? '';

    if (caminho.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível obter o caminho do arquivo selecionado.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _arquivoAnexadoPath = caminho;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Arquivo selecionado: ${arquivo.name}'),
        backgroundColor: const Color(0xFF059669),
      ),
    );
  }

  Future _gerarDocumentacaoComIa() async {
    final agora = DateTime.now();

    final prototipoBase = PrototipoIa(
      id: _prototipoEmEdicao?.id ?? agora.millisecondsSinceEpoch.toString(),
      cliente: _clienteController.text.trim(),
      projetoMacroprocesso: _projetoMacroprocessoController.text.trim(),
      numeroChamadoMo: _numeroChamadoController.text.trim(),
      tituloChamado: _tituloChamadoController.text.trim(),
      vinculacaoChamado: _vinculoChamadoController.text.trim(),
      moduloMo: _moduloMoController.text.trim(),
      programaMoRelacionado: _programaMoController.text.trim(),
      nomeTelaFuncionalidade: _nomeTelaController.text.trim(),
      objetivoTela: _objetivoTelaController.text.trim(),
      usuariosPrincipais: _usuariosPrincipaisController.text.trim(),
      prioridade: _prioridadeSelecionada,
      descricaoDetalhada: _descricaoDetalhadaController.text.trim(),
      problemaAtual: _problemaAtualController.text.trim(),
      resultadoEsperado: _resultadoEsperadoController.text.trim(),
      camposNecessarios: _camposNecessariosController.text.trim(),
      filtrosNecessarios: _filtrosNecessariosController.text.trim(),
      botoesNecessarios: _botoesNecessariosController.text.trim(),
      colunasGrid: _colunasGridController.text.trim(),
      regrasNegocio: _regrasNegocioController.text.trim(),
      integracoesEnvolvidas: _integracoesEnvolvidasController.text.trim(),
      imagemTelaAtualPath: '',
      documentacaoGerada: _prototipoEmEdicao?.documentacaoGerada ?? '',
      htmlGerado: _prototipoEmEdicao?.htmlGerado ?? '',
      arquivoHtmlLocal: _prototipoEmEdicao?.arquivoHtmlLocal ?? '',
      createdAt: _prototipoEmEdicao?.createdAt ?? agora,
      updatedAt: agora,
    );

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Testando conexão com a OpenAI...'),
          backgroundColor: Color(0xFF1D4ED8),
        ),
      );

      const promptTeste =
          'Responda apenas a frase: Conexão realizada com sucesso.';

      final textoGerado = await _openAiService.gerarTexto(prompt: promptTeste);

      final prototipoAtualizado = PrototipoIa(
        id: prototipoBase.id,
        cliente: prototipoBase.cliente,
        projetoMacroprocesso: prototipoBase.projetoMacroprocesso,
        numeroChamadoMo: prototipoBase.numeroChamadoMo,
        tituloChamado: prototipoBase.tituloChamado,
        vinculacaoChamado: prototipoBase.vinculacaoChamado,
        moduloMo: prototipoBase.moduloMo,
        programaMoRelacionado: prototipoBase.programaMoRelacionado,
        nomeTelaFuncionalidade: prototipoBase.nomeTelaFuncionalidade,
        objetivoTela: prototipoBase.objetivoTela,
        usuariosPrincipais: prototipoBase.usuariosPrincipais,
        prioridade: prototipoBase.prioridade,
        descricaoDetalhada: prototipoBase.descricaoDetalhada,
        problemaAtual: prototipoBase.problemaAtual,
        resultadoEsperado: prototipoBase.resultadoEsperado,
        camposNecessarios: prototipoBase.camposNecessarios,
        filtrosNecessarios: prototipoBase.filtrosNecessarios,
        botoesNecessarios: prototipoBase.botoesNecessarios,
        colunasGrid: prototipoBase.colunasGrid,
        regrasNegocio: prototipoBase.regrasNegocio,
        integracoesEnvolvidas: prototipoBase.integracoesEnvolvidas,
        imagemTelaAtualPath: '',
        documentacaoGerada: textoGerado.trim(),
        htmlGerado: '',
        arquivoHtmlLocal: '',
        createdAt: prototipoBase.createdAt,
        updatedAt: DateTime.now(),
      );

      await _repository.salvar(prototipoAtualizado);

      if (!mounted) return;

      setState(() {
        _ultimoPrototipoSalvo = prototipoAtualizado;
        _prototipoEmEdicao = prototipoAtualizado;
      });

      await _carregarHistorico();
      _tabController.animateTo(0);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conexão com a OpenAI testada com sucesso.'),
          backgroundColor: Color(0xFF059669),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final mensagemErro = e.toString().replaceFirst('Exception: ', '');

      final prototipoErro = PrototipoIa(
        id: prototipoBase.id,
        cliente: prototipoBase.cliente,
        projetoMacroprocesso: prototipoBase.projetoMacroprocesso,
        numeroChamadoMo: prototipoBase.numeroChamadoMo,
        tituloChamado: prototipoBase.tituloChamado,
        vinculacaoChamado: prototipoBase.vinculacaoChamado,
        moduloMo: prototipoBase.moduloMo,
        programaMoRelacionado: prototipoBase.programaMoRelacionado,
        nomeTelaFuncionalidade: prototipoBase.nomeTelaFuncionalidade,
        objetivoTela: prototipoBase.objetivoTela,
        usuariosPrincipais: prototipoBase.usuariosPrincipais,
        prioridade: prototipoBase.prioridade,
        descricaoDetalhada: prototipoBase.descricaoDetalhada,
        problemaAtual: prototipoBase.problemaAtual,
        resultadoEsperado: prototipoBase.resultadoEsperado,
        camposNecessarios: prototipoBase.camposNecessarios,
        filtrosNecessarios: prototipoBase.filtrosNecessarios,
        botoesNecessarios: prototipoBase.botoesNecessarios,
        colunasGrid: prototipoBase.colunasGrid,
        regrasNegocio: prototipoBase.regrasNegocio,
        integracoesEnvolvidas: prototipoBase.integracoesEnvolvidas,
        imagemTelaAtualPath: '',
        documentacaoGerada: mensagemErro,
        htmlGerado: '',
        arquivoHtmlLocal: '',
        createdAt: prototipoBase.createdAt,
        updatedAt: DateTime.now(),
      );

      await _repository.salvar(prototipoErro);

      if (!mounted) return;

      setState(() {
        _ultimoPrototipoSalvo = prototipoErro;
        _prototipoEmEdicao = prototipoErro;
      });

      await _carregarHistorico();
      _tabController.animateTo(0);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagemErro),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _projetoMacroprocessoController.dispose();
    _numeroChamadoController.dispose();
    _tituloChamadoController.dispose();
    _vinculoChamadoController.dispose();
    _moduloMoController.dispose();
    _programaMoController.dispose();
    _nomeTelaController.dispose();
    _objetivoTelaController.dispose();
    _usuariosPrincipaisController.dispose();

    _descricaoDetalhadaController.dispose();
    _problemaAtualController.dispose();
    _resultadoEsperadoController.dispose();
    _camposNecessariosController.dispose();
    _filtrosNecessariosController.dispose();
    _botoesNecessariosController.dispose();
    _colunasGridController.dispose();
    _regrasNegocioController.dispose();
    _integracoesEnvolvidasController.dispose();

    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _carregarHistorico();
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD9E2EC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD9E2EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1D4ED8), width: 1.5),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Icon(icon, color: const Color(0xFF1D4ED8), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prototipador IA',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Estruture necessidades, gere documentação funcional e visualize protótipos simulados.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFE5E7EB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUltimoPrototipoSalvoCard() {
    if (_ultimoPrototipoSalvo == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF059669),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Último protótipo salvo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF065F46),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _excluirUltimoPrototipoSalvo,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFB91C1C),
                  size: 18,
                ),
                label: const Text(
                  'Excluir',
                  style: TextStyle(
                    color: Color(0xFFB91C1C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Chamado M&O: ${_ultimoPrototipoSalvo!.numeroChamadoMo.isEmpty ? 'Não informado' : _ultimoPrototipoSalvo!.numeroChamadoMo}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF065F46),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Título do chamado: ${_ultimoPrototipoSalvo!.tituloChamado.isEmpty ? 'Não informado' : _ultimoPrototipoSalvo!.tituloChamado}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF065F46),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Contexto do vínculo: ${_ultimoPrototipoSalvo!.vinculacaoChamado.isEmpty ? 'Não informado' : _ultimoPrototipoSalvo!.vinculacaoChamado}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF065F46),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Nome da tela: ${_ultimoPrototipoSalvo!.nomeTelaFuncionalidade.isEmpty ? 'Não informado' : _ultimoPrototipoSalvo!.nomeTelaFuncionalidade}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF065F46),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Problema atual: ${_ultimoPrototipoSalvo!.problemaAtual.isEmpty ? 'Não informado' : _ultimoPrototipoSalvo!.problemaAtual}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF065F46),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBlock() {
    return _buildSectionCard(
      title: 'Bloco 1 – Informações da Tela',
      icon: Icons.dashboard_customize_outlined,
      child: Column(
        children: [
          TextField(
            controller: _clienteController,
            decoration: _inputDecoration(
              label: 'Cliente',
              hint: 'Selecione ou informe o cliente',
              icon: Icons.business_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _projetoMacroprocessoController,
            decoration: _inputDecoration(
              label: 'Projeto / Macroprocesso',
              hint: 'Ex.: Implantação PCP',
              icon: Icons.account_tree_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _numeroChamadoController,
            decoration: _inputDecoration(
              label: 'Número do chamado M&O',
              hint: 'Ex.: CH-1024 ou 1024',
              icon: Icons.confirmation_number_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tituloChamadoController,
            decoration: _inputDecoration(
              label: 'Título resumido do chamado',
              hint: 'Ex.: Ajuste no apontamento de produção',
              icon: Icons.receipt_long_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _vinculoChamadoController,
            maxLines: 2,
            decoration: _inputDecoration(
              label: 'Vínculo com chamado / contexto',
              hint: 'Explique rapidamente como este protótipo se relaciona com o chamado',
              icon: Icons.link_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _moduloMoController,
            decoration: _inputDecoration(
              label: 'Módulo M&O',
              hint: 'Ex.: Produção, Estoque, Qualidade',
              icon: Icons.widgets_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _programaMoController,
            decoration: _inputDecoration(
              label: 'Programa M&O relacionado',
              hint: 'Informe o programa relacionado',
              icon: Icons.link_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nomeTelaController,
            decoration: _inputDecoration(
              label: 'Nome da tela ou funcionalidade',
              hint: 'Ex.: Painel de Apontamento',
              icon: Icons.web_asset_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _objetivoTelaController,
            maxLines: 2,
            decoration: _inputDecoration(
              label: 'Objetivo da tela',
              hint: 'Descreva o objetivo principal',
              icon: Icons.flag_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _usuariosPrincipaisController,
            decoration: _inputDecoration(
              label: 'Usuários principais',
              hint: 'Ex.: PCP, liderança, analistas',
              icon: Icons.groups_outlined,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _prioridadeSelecionada,
            decoration: _inputDecoration(
              label: 'Prioridade',
              icon: Icons.priority_high_outlined,
            ),
            items: _prioridades
                .map(
                  (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ),
            )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _prioridadeSelecionada = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetalhamentoBlock() {
    return _buildSectionCard(
      title: 'Bloco 2 – Detalhamento da Necessidade',
      icon: Icons.description_outlined,
      child: Column(
        children: [
          TextField(
            controller: _descricaoDetalhadaController,
            maxLines: 4,
            decoration: _inputDecoration(
              label: 'Descrição detalhada da necessidade',
              hint: 'Explique a demanda com o máximo de contexto possível',
              icon: Icons.notes_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _problemaAtualController,
            maxLines: 3,
            decoration: _inputDecoration(
              label: 'Problema atual',
              hint: 'Quais são as dores atuais?',
              icon: Icons.report_problem_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _resultadoEsperadoController,
            maxLines: 3,
            decoration: _inputDecoration(
              label: 'Resultado esperado',
              hint: 'Qual resultado a nova solução deve entregar?',
              icon: Icons.track_changes_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _camposNecessariosController,
            maxLines: 2,
            decoration: _inputDecoration(
              label: 'Campos necessários',
              hint: 'Liste os campos importantes',
              icon: Icons.view_list_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _filtrosNecessariosController,
            maxLines: 2,
            decoration: _inputDecoration(
              label: 'Filtros necessários',
              hint: 'Liste os filtros desejados',
              icon: Icons.filter_alt_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _botoesNecessariosController,
            maxLines: 2,
            decoration: _inputDecoration(
              label: 'Botões necessários',
              hint: 'Liste as ações principais',
              icon: Icons.smart_button_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _colunasGridController,
            maxLines: 2,
            decoration: _inputDecoration(
              label: 'Colunas do grid',
              hint: 'Ex.: código, descrição, status, responsável',
              icon: Icons.table_rows_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _regrasNegocioController,
            maxLines: 3,
            decoration: _inputDecoration(
              label: 'Regras de negócio / observações',
              hint: 'Informe validações, travas e critérios',
              icon: Icons.rule_folder_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _integracoesEnvolvidasController,
            maxLines: 2,
            decoration: _inputDecoration(
              label: 'Integrações envolvidas',
              hint: 'Ex.: estoque, pedidos, cadastro de clientes',
              icon: Icons.device_hub_outlined,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _selecionarArquivoAnexo,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD1D5DB),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.attach_file_outlined,
                    size: 36,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Anexar arquivo para análise',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _arquivoAnexadoPath.isEmpty
                        ? 'Clique para selecionar imagem, PDF, DOC, DOCX ou TXT.'
                        : 'Arquivo selecionado:\n$_arquivoAnexadoPath',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    Widget button({
      required String label,
      required IconData icon,
      required Color backgroundColor,
      required Color foregroundColor,
      VoidCallback? onPressed,
    }) {
      return ElevatedButton.icon(
        onPressed: onPressed ?? () {},
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        button(
          label: 'Novo Protótipo',
          icon: Icons.add_circle_outline,
          backgroundColor: const Color(0xFFE5E7EB),
          foregroundColor: const Color(0xFF111827),
          onPressed: _novoPrototipo,
        ),
        button(
          label: 'Gerar com IA',
          icon: Icons.auto_awesome,
          backgroundColor: const Color(0xFF1D4ED8),
          foregroundColor: Colors.white,
          onPressed: _gerarDocumentacaoComIa,
        ),
        button(
          label: 'Salvar no Projeto',
          icon: Icons.save_outlined,
          backgroundColor: const Color(0xFF0F766E),
          foregroundColor: Colors.white,
          onPressed: _salvarPrototipoSimulado,
        ),
        button(
          label: 'Copiar Documentação',
          icon: Icons.copy_all_outlined,
          backgroundColor: const Color(0xFFF59E0B),
          foregroundColor: Colors.white,
        ),
        button(
          label: 'Baixar HTML',
          icon: Icons.download_outlined,
          backgroundColor: const Color(0xFF7C3AED),
          foregroundColor: Colors.white,
        ),
        button(
          label: 'Exportar PDF',
          icon: Icons.picture_as_pdf_outlined,
          backgroundColor: const Color(0xFFDC2626),
          foregroundColor: Colors.white,
        ),
        button(
          label: 'Ver Histórico',
          icon: Icons.history,
          backgroundColor: const Color(0xFF374151),
          foregroundColor: Colors.white,
          onPressed: _abrirAbaHistorico,
        ),
      ],
    );
  }

  Widget _buildDocumentacaoTab() {
    final textoDocumentacao =
        _prototipoEmEdicao?.documentacaoGerada ??
            _ultimoPrototipoSalvo?.documentacaoGerada ??
            '';

    final temConteudo = textoDocumentacao.trim().isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Documentação para DEV',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Nesta etapa estamos exibindo apenas o retorno bruto da OpenAI para validar a conexão.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1D4ED8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!temConteudo)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Text(
                'Nenhum retorno da IA ainda.\n\nClique em "Gerar com IA" para testar a conexão com a OpenAI.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF4B5563),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: SelectableText(
                textoDocumentacao.trim(),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Color(0xFF111827),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHtmlTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.language, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Prévia visual do protótipo HTML',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E3A8A),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(14),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Row(
                              children: [
                                Icon(Icons.dashboard, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Painel de Solicitações M&O',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: _mockField('Cliente')),
                                      const SizedBox(width: 12),
                                      Expanded(child: _mockField('Projeto')),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(child: _mockField('Status')),
                                      const SizedBox(width: 12),
                                      Expanded(child: _mockField('Responsável')),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      _mockButton('Filtrar'),
                                      const SizedBox(width: 8),
                                      _mockButton('Novo'),
                                      const SizedBox(width: 8),
                                      _mockButton('Exportar'),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFB),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE5E7EB),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Color(0xFFE5E7EB),
                                                ),
                                              ),
                                            ),
                                            child: const Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Código',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    'Descrição',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    'Status',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Expanded(
                                            child: Center(
                                              child: Text(
                                                'Grid simulado do protótipo HTML',
                                                style: TextStyle(
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Link/local do arquivo HTML',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 8),
                SelectableText(
                  r'C:\Enterdoc\prototipos\cliente_x\painel_solicitacoes_mo_v1.html',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArquivosTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        _ArquivoTile(
          titulo: 'documentacao_funcional_v1.pdf',
          subtitulo: 'Documento funcional exportado',
          icon: Icons.picture_as_pdf_outlined,
          color: Color(0xFFDC2626),
        ),
        SizedBox(height: 12),
        _ArquivoTile(
          titulo: 'prototipo_tela_v1.html',
          subtitulo: 'Protótipo navegável gerado',
          icon: Icons.language_outlined,
          color: Color(0xFF2563EB),
        ),
        SizedBox(height: 12),
        _ArquivoTile(
          titulo: 'imagem_referencia_atual.png',
          subtitulo: 'Imagem anexada da tela atual',
          icon: Icons.image_outlined,
          color: Color(0xFF0F766E),
        ),
      ],
    );
  }

  Widget _buildHistoricoTab() {
    if (_historicoPrototipos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Nenhum protótipo salvo até o momento.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      );
    }

    final historicoOrdenado = _historicoPrototipos.reversed.toList();

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: historicoOrdenado.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = historicoOrdenado[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _ultimoPrototipoSalvo?.id == item.id
                ? const Color(0xFFECFDF5)
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _ultimoPrototipoSalvo?.id == item.id
                  ? const Color(0xFFA7F3D0)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: _ultimoPrototipoSalvo?.id == item.id
                    ? const Color(0xFFD1FAE5)
                    : const Color(0xFFEFF6FF),
                child: Icon(
                  _ultimoPrototipoSalvo?.id == item.id ? Icons.check : Icons.history,
                  color: _ultimoPrototipoSalvo?.id == item.id
                      ? const Color(0xFF059669)
                      : const Color(0xFF1D4ED8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_ultimoPrototipoSalvo?.id == item.id) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Último salvo',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ),
                    ],
                    Text(
                      item.nomeTelaFuncionalidade.isEmpty
                          ? 'Protótipo sem nome'
                          : item.nomeTelaFuncionalidade,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cliente: ${item.cliente.isEmpty ? 'Não informado' : item.cliente}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chamado M&O: ${item.numeroChamadoMo.isEmpty ? 'Não informado' : item.numeroChamadoMo}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Problema atual: ${item.problemaAtual.isEmpty ? 'Não informado' : item.problemaAtual}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  IconButton(
                    onPressed: () => _editarPrototipoDoHistorico(item),
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF2563EB),
                    ),
                    tooltip: 'Editar protótipo',
                  ),
                  IconButton(
                    onPressed: () => _excluirPrototipoDoHistorico(item),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFB91C1C),
                    ),
                    tooltip: 'Excluir protótipo',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultadoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.psychology_alt_outlined,
                  color: Color(0xFF1D4ED8),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Bloco 3 – Resultado Gerado pela IA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Resultado simulado',
                    style: TextStyle(
                      color: Color(0xFF065F46),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFF1D4ED8),
            unselectedLabelColor: const Color(0xFF6B7280),
            indicatorColor: const Color(0xFF1D4ED8),
            tabs: const [
              Tab(text: 'Documentação para DEV'),
              Tab(text: 'Protótipo HTML'),
              Tab(text: 'Arquivos'),
              Tab(text: 'Histórico (teste)'),
            ],
          ),
          SizedBox(
            height: 640,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDocumentacaoTab(),
                _buildHtmlTab(),
                _buildArquivosTab(),
                _buildHistoricoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _mockField(String label) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  static Widget _mockButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF1D4ED8),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildUltimoPrototipoSalvoCard(),
              if (_ultimoPrototipoSalvo != null) const SizedBox(height: 20),
              if (_prototipoEmEdicao != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Modo edição ativo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _prototipoEmEdicao!.nomeTelaFuncionalidade.isEmpty
                            ? 'Você está editando um protótipo salvo.'
                            : 'Você está editando: ${_prototipoEmEdicao!.nomeTelaFuncionalidade}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_prototipoEmEdicao != null) const SizedBox(height: 20),
              _buildActionButtons(),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 1100;

                  if (isMobile) {
                    return Column(
                      children: [
                        _buildInfoBlock(),
                        const SizedBox(height: 16),
                        _buildDetalhamentoBlock(),
                        const SizedBox(height: 16),
                        _buildResultadoCard(),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            _buildInfoBlock(),
                            const SizedBox(height: 16),
                            _buildDetalhamentoBlock(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 6,
                        child: _buildResultadoCard(),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultadoSecao extends StatelessWidget {
  final String titulo;
  final String conteudo;

  const _ResultadoSecao({
    required this.titulo,
    required this.conteudo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            conteudo,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArquivoTile extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icon;
  final Color color;

  const _ArquivoTile({
    required this.titulo,
    required this.subtitulo,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.open_in_new, color: Color(0xFF6B7280)),
        ],
      ),
    );
  }
}

class _HistoricoTile extends StatelessWidget {
  final String versao;
  final String data;
  final String descricao;

  const _HistoricoTile({
    required this.versao,
    required this.data,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFEFF6FF),
            child: Icon(Icons.history, color: Color(0xFF1D4ED8)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$versao • $data',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  descricao,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}