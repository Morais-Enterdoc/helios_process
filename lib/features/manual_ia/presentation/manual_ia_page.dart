import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../prototipador_ia/data/openai_prototipador_service.dart';
import 'package:file_picker/file_picker.dart';
import '../domain/manual_ia.dart';
import '../data/manual_prompt_builder.dart';



class ManualIaPage extends StatefulWidget {
  const ManualIaPage({super.key});

  @override
  State<ManualIaPage> createState() => _ManualIaPageState();
}

class _ManualIaPageState extends State<ManualIaPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _clienteController = TextEditingController();
  final _programaMoController = TextEditingController();
  final _nomeManualController = TextEditingController();
  final _objetivoController = TextEditingController();
  final _descricaoRotinaController = TextEditingController();
  final _passoAPassoController = TextEditingController();
  final _observacoesController = TextEditingController();
  final _conteudoManualController = TextEditingController();

  final List<String> _tiposDocumento = const [
    '💻 Manual Sistêmico',
    '📗 Manual Operacional',
    '🎓 Material de Treinamento',
    '⚡ Guia Rápido',
  ];

  String _tipoManualSelecionado = '💻 Manual Sistêmico';
  String _tipoNivelPaginaSelecionado = 'Nível 3 – Tela Operacional';
  String _imagemSelecionadaPath = '';
  String _conteudoManual = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _conteudoManual = '';
  }

  final _manualIaService = OpenAiPrototipadorService();
  bool _gerandoManual = false;

  @override
  void dispose() {
    _clienteController.dispose();
    _programaMoController.dispose();
    _nomeManualController.dispose();
    _objetivoController.dispose();
    _descricaoRotinaController.dispose();
    _passoAPassoController.dispose();
    _observacoesController.dispose();
    _conteudoManualController.dispose();
    _tabController.dispose();
    super.dispose();
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
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E3A8A),
          ],
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
              Icons.menu_book_outlined,
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
                  'Gerador Inteligente de Documentação',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Gere páginas de documentação, guias rápidos e roteiros de treinamento com apoio de IA no padrão da Enterdoc.',
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

  Future<void> _selecionarImagem() async {
    try {
      final resultado = await FilePicker.platform.pickFiles(
        dialogTitle: 'Selecionar imagem da tela',
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'webp', 'bmp'],
      );

      if (resultado == null || resultado.files.isEmpty) {
        return;
      }

      final arquivo = resultado.files.single;
      final caminho = arquivo.path;

      if (caminho == null || caminho.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível obter o caminho da imagem selecionada.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        _imagemSelecionadaPath = caminho;
      });

      _tabController.animateTo(1);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imagem selecionada com sucesso: ${arquivo.name}'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar imagem: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  void _novoManual() {
    _clienteController.clear();
    _programaMoController.clear();
    _nomeManualController.clear();
    _objetivoController.clear();
    _descricaoRotinaController.clear();
    _passoAPassoController.clear();
    _observacoesController.clear();
    _conteudoManualController.clear();

    setState(() {
      _tipoManualSelecionado = '💻 Manual Sistêmico';
      _imagemSelecionadaPath = '';
      _conteudoManual = '';
      _gerandoManual = false;
    });

    _tabController.animateTo(0);
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formulário limpo para um novo manual.'),
        backgroundColor: Color(0xFF2563EB),
      ),
    );
  }

  Future<void> _gerarManual() async {
    if (_clienteController.text.trim().isEmpty ||
        _programaMoController.text.trim().isEmpty ||
        _nomeManualController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha Cliente, Programa M&O e Nome do Manual antes de gerar.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final manual = ManualIa(
      cliente: _clienteController.text.trim(),
      programaMo: _programaMoController.text.trim(),
      nomeManual: _nomeManualController.text.trim(),
      objetivo: _objetivoController.text.trim(),
      tipoManual: _tipoManualSelecionado,
      tipoNivelPagina: _tipoNivelPaginaSelecionado,
      descricaoRotina: _descricaoRotinaController.text.trim(),
      passoAPasso: _passoAPassoController.text.trim(),
      observacoes: _observacoesController.text.trim(),
      imagemTelaPath: _imagemSelecionadaPath,
      conteudoManual: '',
    );

    setState(() {
      _gerandoManual = true;
    });

    try {
      final prompt = ManualPromptBuilder.build(manual);

      final conteudo = await _manualIaService.gerarTexto(prompt: prompt);

      if (!mounted) return;

      setState(() {
        _conteudoManual = conteudo;
        _conteudoManualController.text = conteudo;
        _gerandoManual = false;
      });

      _tabController.animateTo(0);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Manual gerado com sucesso.'),
          backgroundColor: Color(0xFF059669),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _gerandoManual = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar manual: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _salvarRascunho() async {
    final temAlgumConteudo =
        _clienteController.text.trim().isNotEmpty ||
            _programaMoController.text.trim().isNotEmpty ||
            _nomeManualController.text.trim().isNotEmpty ||
            _objetivoController.text.trim().isNotEmpty ||
            _descricaoRotinaController.text.trim().isNotEmpty ||
            _passoAPassoController.text.trim().isNotEmpty ||
            _observacoesController.text.trim().isNotEmpty;

    if (!temAlgumConteudo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha pelo menos um campo antes de salvar o rascunho.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final nomeArquivoBase = _nomeManualController.text.trim().isEmpty
          ? 'rascunho_manual_ia'
          : _nomeManualController.text
          .trim()
          .toLowerCase()
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^a-z0-9_]'), '');

      final dados = {
        'cliente': _clienteController.text.trim(),
        'programaMo': _programaMoController.text.trim(),
        'nomeManual': _nomeManualController.text.trim(),
        'objetivo': _objetivoController.text.trim(),
        'tipoManual': _tipoManualSelecionado,
        'tipoNivelPagina': _tipoNivelPaginaSelecionado,
        'descricaoRotina': _descricaoRotinaController.text.trim(),
        'passoAPasso': _passoAPassoController.text.trim(),
        'observacoes': _observacoesController.text.trim(),
        'imagemSelecionadaPath': _imagemSelecionadaPath,
        'conteudoManual': _conteudoManualController.text.trim(),
        'salvoEm': DateTime.now().toIso8601String(),
      };

      final caminhoArquivo = await FilePicker.platform.saveFile(
        dialogTitle: 'Salvar rascunho do manual',
        fileName: '${nomeArquivoBase}_rascunho.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (caminhoArquivo == null || caminhoArquivo.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Salvamento do rascunho cancelado pelo usuário.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final arquivo = File(caminhoArquivo);

      await arquivo.writeAsString(
        const JsonEncoder.withIndent('  ').convert(dados),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rascunho salvo em: ${arquivo.path}'),
          backgroundColor: const Color(0xFF7C3AED),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar rascunho: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _abrirRascunho() async {
    try {
      final resultado = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (resultado == null || resultado.files.isEmpty) {
        return;
      }

      final arquivoSelecionado = resultado.files.first;
      final caminho = arquivoSelecionado.path;

      if (caminho == null || caminho.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível obter o caminho do arquivo selecionado.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final arquivo = File(caminho);

      if (!await arquivo.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O arquivo selecionado não foi encontrado.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final conteudo = await arquivo.readAsString();
      final dados = jsonDecode(conteudo) as Map<String, dynamic>;

      _clienteController.text = (dados['cliente'] ?? '').toString();
      _programaMoController.text = (dados['programaMo'] ?? '').toString();
      _nomeManualController.text = (dados['nomeManual'] ?? '').toString();
      _objetivoController.text = (dados['objetivo'] ?? '').toString();
      _descricaoRotinaController.text = (dados['descricaoRotina'] ?? '').toString();
      _passoAPassoController.text = (dados['passoAPasso'] ?? '').toString();
      _observacoesController.text = (dados['observacoes'] ?? '').toString();
      _conteudoManualController.text = (dados['conteudoManual'] ?? '').toString();
      _conteudoManual = _conteudoManualController.text;
      _imagemSelecionadaPath = (dados['imagemSelecionadaPath'] ?? '').toString();

      final tipoManual = (dados['tipoManual'] ?? 'Manual Operacional').toString();
      final tipoNivelPagina =
      (dados['tipoNivelPagina'] ?? 'Nível 3 – Tela Operacional').toString();

      const tiposNivelPagina = [
        'Nível 1 – Processo Macro',
        'Nível 2 – Processo / Subprocesso',
        'Nível 3 – Tela Operacional',
      ];

      setState(() {
        _tipoManualSelecionado = _tiposDocumento.contains(tipoManual)
            ? tipoManual
            : '💻 Manual Sistêmico';

        _tipoNivelPaginaSelecionado = tiposNivelPagina.contains(tipoNivelPagina)
            ? tipoNivelPagina
            : 'Nível 3 – Tela Operacional';
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rascunho carregado com sucesso: ${arquivoSelecionado.name}'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao abrir rascunho: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _copiarConteudo() async {
    final texto = _conteudoManual.trim();

    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não há conteúdo para copiar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: texto));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conteúdo copiado para a área de transferência.'),
        backgroundColor: Color(0xFF059669),
      ),
    );
  }

  Future<void> _salvarManual() async {
    final conteudo = _conteudoManualController.text.trim();

    if (conteudo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gere ou edite um manual antes de salvar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final nomeBase = _nomeManualController.text.trim().isEmpty
          ? 'manual_ia'
          : _nomeManualController.text
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '_');

      final caminhoArquivo = await FilePicker.platform.saveFile(
        dialogTitle: 'Salvar manual',
        fileName: '$nomeBase.txt',
        type: FileType.custom,
        allowedExtensions: ['txt'],
        bytes: utf8.encode(conteudo),
      );

      if (caminhoArquivo == null || caminhoArquivo.isEmpty) {
        return;
      }

      final arquivo = File(caminhoArquivo);
      await arquivo.writeAsString(conteudo, encoding: utf8);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Manual salvo com sucesso em: $caminhoArquivo'),
          backgroundColor: const Color(0xFF0F766E),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar manual: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  Future<void> _abrirManual() async {
    try {
      final resultado = await FilePicker.platform.pickFiles(
        dialogTitle: 'Abrir manual',
        type: FileType.custom,
        allowedExtensions: ['txt'],
        withData: true,
      );

      if (resultado == null || resultado.files.isEmpty) {
        return;
      }

      final arquivoSelecionado = resultado.files.single;

      String conteudo = '';

      if (arquivoSelecionado.bytes != null) {
        conteudo = utf8.decode(arquivoSelecionado.bytes!);
      } else if (arquivoSelecionado.path != null &&
          arquivoSelecionado.path!.isNotEmpty) {
        final arquivo = File(arquivoSelecionado.path!);
        conteudo = await arquivo.readAsString(encoding: utf8);
      }

      if (conteudo.trim().isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O arquivo selecionado está vazio.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        _conteudoManual = conteudo;
        _conteudoManualController.text = conteudo;
      });

      _tabController.animateTo(0);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Manual carregado com sucesso: ${arquivoSelecionado.name}',
          ),
          backgroundColor: const Color(0xFF2563EB),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao abrir manual: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  Widget _buildInformacoesCard() {
    const tiposNivelPagina = [
      'Nível 1 – Processo Macro',
      'Nível 2 – Processo / Subprocesso',
      'Nível 3 – Tela Operacional',
    ];

    return _buildSectionCard(
      title: 'Card 1 · Informações do Documento',
      icon: Icons.menu_book_outlined,
      child: Column(
        children: [
          TextField(
            controller: _clienteController,
            decoration: _inputDecoration(
              label: 'Cliente *',
              hint: 'Selecione ou informe o cliente',
              icon: Icons.business_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _programaMoController,
            decoration: _inputDecoration(
              label: 'Programa M&O *',
              hint: 'Informe o programa relacionado',
              icon: Icons.widgets_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nomeManualController,
            decoration: _inputDecoration(
              label: 'Nome da Página / Documento *',
              hint: 'Ex. Tela de Ocorrências, Guia Rápido de Expedição, Treinamento de Transferências',
              icon: Icons.title_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _objetivoController,
            maxLines: 2,
            decoration: _inputDecoration(
              label: 'Objetivo',
              hint: 'Descreva o objetivo principal do manual',
              icon: Icons.flag_outlined,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _tipoManualSelecionado,
            decoration: _inputDecoration(
              label: 'Tipo do Documento',
              icon: Icons.category_outlined,
            ),
            items: _tiposDocumento
                .map(
                  (tipo) => DropdownMenuItem<String>(
                value: tipo,
                child: Text(tipo),
              ),
            )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _tipoManualSelecionado = value;
              });
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _tipoNivelPaginaSelecionado,
            decoration: _inputDecoration(
              label: 'Tipo / Nível da Página *',
              icon: Icons.layers_outlined,
            ),
            items: tiposNivelPagina
                .map(
                  (nivel) => DropdownMenuItem(
                value: nivel,
                child: Text(nivel),
              ),
            )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _tipoNivelPaginaSelecionado = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConteudoCard() {
    final temImagem = _imagemSelecionadaPath.isNotEmpty;

    return _buildSectionCard(
      title: 'Card 2 · Conteúdo',
      icon: Icons.description_outlined,
      child: Column(
        children: [
          TextField(
            controller: _descricaoRotinaController,
            maxLines: 4,
            decoration: _inputDecoration(
              label: 'Descrição da Rotina',
              hint: 'Explique a rotina que será documentada',
              icon: Icons.notes_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passoAPassoController,
            maxLines: 5,
            decoration: _inputDecoration(
              label: 'Passo a Passo',
              hint: 'Descreva a sequência das ações',
              icon: Icons.format_list_numbered_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _observacoesController,
            maxLines: 3,
            decoration: _inputDecoration(
              label: 'Observações',
              hint: 'Inclua alertas, validações ou observações importantes',
              icon: Icons.info_outline,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.image_outlined,
                  size: 36,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Imagem da Tela',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  temImagem
                      ? _imagemSelecionadaPath.split(Platform.pathSeparator).last
                      : 'Nenhuma imagem selecionada.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: _selecionarImagem,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Selecionar imagem'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1D4ED8),
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _gerandoManual ? null : _gerarManual,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF1D4ED8),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF93C5FD),
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_gerandoManual) ...[
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Gerando documento...'),
                  ] else ...[
                    const Icon(Icons.auto_awesome),
                    const SizedBox(width: 8),
                    const Text('Gerar Documento'),
                  ],
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
          label: 'Novo Documento',
          icon: Icons.add_circle_outline,
          backgroundColor: const Color(0xFFE5E7EB),
          foregroundColor: const Color(0xFF111827),
          onPressed: _novoManual,
        ),
        button(
          label: 'Salvar Rascunho',
          icon: Icons.save_as_outlined,
          backgroundColor: const Color(0xFF7C3AED),
          foregroundColor: Colors.white,
          onPressed: _salvarRascunho,
        ),
        button(
          label: 'Abrir Rascunho',
          icon: Icons.folder_open_outlined,
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          onPressed: _abrirRascunho,
        ),
        button(
          label: _gerandoManual ? 'Gerando...' : 'Gerar Documento',
          icon: _gerandoManual ? Icons.hourglass_top : Icons.auto_awesome,
          backgroundColor: _gerandoManual
              ? const Color(0xFF93C5FD)
              : const Color(0xFF1D4ED8),
          foregroundColor: Colors.white,
          onPressed: _gerandoManual ? null : _gerarManual,
        ),
        button(
          label: 'Copiar Conteúdo',
          icon: Icons.copy_all_outlined,
          backgroundColor: _conteudoManual.trim().isEmpty || _gerandoManual
              ? const Color(0xFFFCD34D)
              : const Color(0xFFF59E0B),
          foregroundColor: Colors.white,
          onPressed: _conteudoManual.trim().isEmpty || _gerandoManual
              ? null
              : _copiarConteudo,
        ),
        button(
          label: 'Abrir Documento',
          icon: Icons.folder_open_outlined,
          backgroundColor: const Color(0xFF7C3AED),
          foregroundColor: Colors.white,
          onPressed: _abrirManual,
        ),
        button(
          label: 'Salvar Documento',
          icon: Icons.save_outlined,
          backgroundColor: _conteudoManual.trim().isEmpty
              ? const Color(0xFF99F6E4)
              : const Color(0xFF0F766E),
          foregroundColor: Colors.white,
          onPressed: _conteudoManual.trim().isEmpty ? null : _salvarManual,
        ),
      ],
    );
  }

  Widget _buildManualTab() {
    final texto = _conteudoManual.trim();

    if (texto.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Nenhum documento gerado ainda.\nPreencha os dados ao lado e clique em "Gerar Documento".',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFCFD),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: TextField(
          controller: _conteudoManualController,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'O conteúdo do manual aparecerá aqui.',
            hintStyle: TextStyle(
              color: Color(0xFF9CA3AF),
            ),
          ),
          style: const TextStyle(
            fontSize: 14,
            height: 1.7,
            color: Color(0xFF374151),
          ),
          onChanged: (value) {
            _conteudoManual = value;
          },
        ),
      ),
    );
  }

  Widget _buildImagemTab() {
    if (_imagemSelecionadaPath.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Nenhuma imagem selecionada.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            File(_imagemSelecionadaPath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Não foi possível carregar a imagem selecionada.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              );
            },
          ),
        ),
      ),
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
                    'Bloco 3 · Visualização do Documento',
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
                  child: Text(
                    _gerandoManual ? 'Gerando...' : 'Pronto',
                    style: const TextStyle(
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
              Tab(text: '📄 Documento'),
              Tab(text: '🖼️ Imagem'),
            ],
          ),
          SizedBox(
            height: 640,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildManualTab(),
                _buildImagemTab(),
              ],
            ),
          ),
        ],
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
              _buildActionButtons(),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 1100;

                  if (isMobile) {
                    return Column(
                      children: [
                        _buildInformacoesCard(),
                        const SizedBox(height: 16),
                        _buildConteudoCard(),
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
                            _buildInformacoesCard(),
                            const SizedBox(height: 16),
                            _buildConteudoCard(),
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