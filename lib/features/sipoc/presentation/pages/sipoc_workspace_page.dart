import 'package:flutter/material.dart';
import '../../../clientes/domain/cliente.dart';
import '../../../clientes/domain/setor.dart';
import '../../domain/sipoc_detalhe.dart';
import '../widgets/sipoc_form_content.dart';
import '../widgets/as_is_tab.dart';
import '../../../clientes/data/cliente_repository.dart';
import '../../data/sipoc_repository.dart';
import '../../domain/sipoc.dart';
import '../../data/as_is_repository.dart';
import '../../domain/as_is.dart';

class SipocWorkspacePage extends StatefulWidget {
  final SipocDetalhe item;

  const SipocWorkspacePage({
    super.key,
    required this.item,
  });

  @override
  State<SipocWorkspacePage> createState() => _SipocWorkspacePageState();
}

class _SipocWorkspacePageState extends State<SipocWorkspacePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ClienteRepository clienteRepository = ClienteRepository();
  final SipocRepository sipocRepository = SipocRepository();
  final AsIsRepository asIsRepository = AsIsRepository();
  List<AsIs> itensAsIs = [];

  final List<Cliente> clientes = [];
  final List<Setor> setores = [];
  Cliente? clienteSelecionado;
  Setor? setorSelecionado;

  final TextEditingController tituloController = TextEditingController();
  final TextEditingController parteController = TextEditingController();
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController revisaoController = TextEditingController();
  final TextEditingController dataController = TextEditingController();
  final TextEditingController responsaveisController = TextEditingController();
  final TextEditingController objetivoController = TextEditingController();
  final TextEditingController fornecedoresController = TextEditingController();
  final TextEditingController entradasController = TextEditingController();
  final TextEditingController processoController = TextEditingController();
  final TextEditingController saidasController = TextEditingController();
  final TextEditingController clientesController = TextEditingController();
  final TextEditingController indicadoresController = TextEditingController();
  final TextEditingController fluxoTextoController = TextEditingController();

  final List<String> abas = const [
    'SIPOC',
    'AS-IS',
    'Gargalos',
    'TO-BE',
    'Plano de Ação',
    'Evidências',
    'Timeline',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: abas.length, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index == 0) {
        carregarAsIsDoSipoc();
      }
    });

    final sipoc = widget.item.sipoc;
    tituloController.text = sipoc.titulo;
    parteController.text = sipoc.parte;
    codigoController.text = sipoc.codigo;
    revisaoController.text = sipoc.revisao;
    dataController.text = sipoc.dataEmissao;
    responsaveisController.text = sipoc.responsaveis;
    objetivoController.text = sipoc.objetivo;
    fornecedoresController.text = sipoc.fornecedores;
    entradasController.text = sipoc.entradas;
    processoController.text = sipoc.processo;
    saidasController.text = sipoc.saidas;
    clientesController.text = sipoc.clientes;
    indicadoresController.text = sipoc.indicadores;
    fluxoTextoController.text = sipoc.fluxoTexto;

    carregarClienteESetorDoSipoc();
    carregarAsIsDoSipoc();
  }

  Future<void> carregarAsIsDoSipoc() async {
    final sipocId = widget.item.sipoc.id;

    if (sipocId == null) return;

    final lista = await asIsRepository.listarPorSipoc(sipocId);

    if (!mounted) return;

    setState(() {
      itensAsIs = lista;
    });
  }



  @override
  void dispose() {
    _tabController.dispose();
    tituloController.dispose();
    parteController.dispose();
    codigoController.dispose();
    revisaoController.dispose();
    dataController.dispose();
    responsaveisController.dispose();
    objetivoController.dispose();
    fornecedoresController.dispose();
    entradasController.dispose();
    processoController.dispose();
    saidasController.dispose();
    clientesController.dispose();
    indicadoresController.dispose();
    fluxoTextoController.dispose();
    super.dispose();
  }

  Future<void> carregarClienteESetorDoSipoc() async {
    final sipoc = widget.item.sipoc;

    final listaClientes = await clienteRepository.listarClientes();
    final listaSetores =
    await clienteRepository.listarSetoresPorCliente(sipoc.clienteId);

    Cliente? clienteAtual;
    Setor? setorAtual;

    try {
      clienteAtual = listaClientes.firstWhere((c) => c.id == sipoc.clienteId);
    } catch (_) {
      clienteAtual = null;
    }

    try {
      setorAtual = listaSetores.firstWhere((s) => s.id == sipoc.setorId);
    } catch (_) {
      setorAtual = null;
    }

    if (!mounted) return;

    setState(() {
      clientes
        ..clear()
        ..addAll(listaClientes);

      setores
        ..clear()
        ..addAll(listaSetores);

      clienteSelecionado = clienteAtual;
      setorSelecionado = setorAtual;
    });
  }

  Widget _buildPlaceholder(String titulo) {
    return Center(
      child: Text(
        '$titulo em construção.',
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  InputDecoration buildInputDecoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      alignLabelWithHint: true,
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF1D4ED8),
          width: 1.4,
        ),
      ),
    );
  }

  List<String> extrairBlocosFluxo(String texto) {
    final regex = RegExp(r'"(.*?)"');
    return regex
        .allMatches(texto)
        .map((m) => (m.group(1) ?? '').trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<String> obterBlocosFluxoDoAsIs() {
    return itensAsIs
        .where((item) => item.fluxo.trim().isNotEmpty)
        .map((item) => item.fluxo.trim())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final sipoc = widget.item.sipoc;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF111827),
        title: Text(
          sipoc.titulo.isEmpty ? 'Workspace SIPOC' : sipoc.titulo,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF12324A),
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: const Color(0xFF12324A),
          tabs: abas.map((aba) => Tab(text: aba)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SipocFormContent(
              item: widget.item,
              clientes: clientes,
              setores: setores,
              clienteSelecionado: clienteSelecionado,
              setorSelecionado: setorSelecionado,
              tituloController: tituloController,
              parteController: parteController,
              codigoController: codigoController,
              revisaoController: revisaoController,
              dataController: dataController,
              responsaveisController: responsaveisController,
              objetivoController: objetivoController,
              fornecedoresController: fornecedoresController,
              entradasController: entradasController,
              processoController: processoController,
              saidasController: saidasController,
              clientesController: clientesController,
              indicadoresController: indicadoresController,
              fluxoTextoController: fluxoTextoController,
              onClienteChanged: (value) {
                setState(() {
                  clienteSelecionado = value;
                });
              },
              onSetorChanged: (value) {
                setState(() {
                  setorSelecionado = value;
                });
              },
              onSalvar: () async {
                if (clienteSelecionado == null || setorSelecionado == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Selecione o cliente e o setor.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final sipoc = Sipoc(
                    id: widget.item.sipoc.id,
                    clienteId: clienteSelecionado!.id!,
                    setorId: setorSelecionado!.id!,
                    titulo: tituloController.text.trim(),
                    parte: parteController.text.trim(),
                    codigo: codigoController.text.trim(),
                    revisao: revisaoController.text.trim(),
                    dataEmissao: dataController.text.trim(),
                    responsaveis: responsaveisController.text.trim(),
                    objetivo: objetivoController.text.trim(),
                    fornecedores: fornecedoresController.text.trim(),
                    entradas: entradasController.text.trim(),
                    processo: processoController.text.trim(),
                    saidas: saidasController.text.trim(),
                    clientes: clientesController.text.trim(),
                    indicadores: indicadoresController.text.trim(),
                    fluxoTexto: fluxoTextoController.text.trim(),
                  );

                  await sipocRepository.atualizarSipoc(sipoc);

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('SIPOC atualizado com sucesso!'),
                      backgroundColor: Color(0xFF059669),
                    ),
                  );

                  setState(() {});
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao salvar SIPOC: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              buildInputDecoration: buildInputDecoration,
              extrairBlocosFluxo: (_) => obterBlocosFluxoDoAsIs(),
            ),
          ),
          AsIsTab(sipocId: widget.item.sipoc.id!),
          _buildPlaceholder('Gargalos'),
          _buildPlaceholder('TO-BE'),
          _buildPlaceholder('Plano de Ação'),
          _buildPlaceholder('Evidências'),
          _buildPlaceholder('Timeline'),
        ],
      ),
    );
  }
}