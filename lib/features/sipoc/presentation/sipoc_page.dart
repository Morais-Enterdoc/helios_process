import 'dart:io';

import 'package:flutter/material.dart';

import '../../clientes/data/cliente_repository.dart';
import '../../clientes/domain/cliente.dart';
import '../../clientes/domain/setor.dart';
import '../data/sipoc_repository.dart';
import '../domain/sipoc.dart';
import '../domain/sipoc_detalhe.dart';
import 'pages/sipoc_workspace_page.dart';
import 'pages/sipoc_workspace_page.dart';

class SipocPage extends StatefulWidget {
  const SipocPage({super.key});

  @override
  State<SipocPage> createState() => _SipocPageState();
}

class FluxoBox extends StatelessWidget {
  final String texto;
  final bool mostrarSeta;

  const FluxoBox({
    super.key,
    required this.texto,
    this.mostrarSeta = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 210,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black87),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ),
        if (mostrarSeta)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Icon(
              Icons.arrow_downward,
              size: 20,
              color: Colors.black87,
            ),
          ),
      ],
    );
  }
}

class SipocLinha extends StatelessWidget {
  final String letra;
  final String titulo;
  final Widget conteudoEsquerda;
  final Widget conteudoDireita;
  final double alturaMinima;

  const SipocLinha({
    super.key,
    required this.letra,
    required this.titulo,
    required this.conteudoEsquerda,
    required this.conteudoDireita,
    this.alturaMinima = 110,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54),
              color: Colors.white,
            ),
            child: Text(
              letra,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Container(
              constraints: BoxConstraints(minHeight: alturaMinima),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Container(
              constraints: BoxConstraints(minHeight: alturaMinima),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(10),
              child: conteudoDireita,
            ),
          ),
        ],
      ),
    );
  }
}

class _SipocPageState extends State<SipocPage> {
  final SipocRepository sipocRepository = SipocRepository();
  final ClienteRepository clienteRepository = ClienteRepository();

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

  List<SipocDetalhe> sipocs = [];
  List<Cliente> clientes = [];
  List<Setor> setores = [];
  List<Setor> todosSetores = [];

  Cliente? clienteSelecionado;
  Setor? setorSelecionado;

  List<String> extrairBlocosFluxo(String texto) {
    final regex = RegExp(r'"(.*?)"');
    return regex
        .allMatches(texto)
        .map((m) => (m.group(1) ?? '').trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    await carregarClientes();
    await carregarTodosSetores();  // <-- novo
    await carregarSipocs();
  }

  Future<void> carregarTodosSetores() async {
    final lista = await clienteRepository.listarTodosSetores();
    if (!mounted) return;
    setState(() {
      todosSetores = lista;
    });
  }

  @override
  void dispose() {
    tituloController.dispose();
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
    parteController.dispose();
    super.dispose();
  }

  Future<void> carregarClientes() async {
    final lista = await clienteRepository.listarClientes();
    if (!mounted) return;
    setState(() {
      clientes = lista;
    });
  }

  Future<void> carregarSetores(int clienteId) async {
    final lista = await clienteRepository.listarSetoresPorCliente(clienteId);
    if (!mounted) return;
    setState(() {
      setores = lista;
    });
  }

  Future<void> carregarSipocs() async {
    final lista = await sipocRepository.listarSipocsDetalhe();
    if (!mounted) return;
    setState(() {
      sipocs = lista;
    });
  }

  void limparFormulario() {
    tituloController.clear();
    codigoController.clear();
    revisaoController.clear();
    dataController.clear();
    responsaveisController.clear();
    objetivoController.clear();
    fornecedoresController.clear();
    entradasController.clear();
    processoController.clear();
    saidasController.clear();
    clientesController.clear();
    indicadoresController.clear();
    fluxoTextoController.clear();
    clienteSelecionado = null;
    setorSelecionado = null;
    setores = [];
    parteController.clear();
  }

  Future<void> abrirSipocDialog({SipocDetalhe? item}) async {
    limparFormulario();

    if (item != null) {
      final sipoc = item.sipoc;
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

      final listaClientes = await clienteRepository.listarClientes();
      clientes = listaClientes;

      try {
        clienteSelecionado = listaClientes.firstWhere(
              (c) => c.id == sipoc.clienteId,
        );
      } catch (_) {
        clienteSelecionado = null;
      }

      final listaSetores = await clienteRepository.listarSetoresPorCliente(sipoc.clienteId);
      setores = listaSetores;

      try {
        setorSelecionado = listaSetores.firstWhere(
              (s) => s.id == sipoc.setorId,
        );
      } catch (_) {
        setorSelecionado = null;
      }
    }

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            final size = MediaQuery.of(context).size;

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: size.width * 0.96,
                height: size.height * 0.94,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item == null ? 'Novo SIPOC' : 'Editar SIPOC',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Digite as informações do processo nos campos do lado esquerdo da tela e coloque o fluxo com texto entre aspas no final do formulário',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DropdownButtonFormField<Cliente>(
                                            value: clientes.any((c) => c.id == clienteSelecionado?.id)
                                                ? clientes.firstWhere((c) => c.id == clienteSelecionado?.id)
                                                : null,
                                            decoration: buildInputDecoration(
                                              label: 'Cliente',
                                              hint: 'Selecione o cliente',
                                            ),
                                            items: clientes.map((cliente) {
                                              return DropdownMenuItem<Cliente>(
                                                value: cliente,
                                                child: Text(cliente.nome),
                                              );
                                            }).toList(),
                                            onChanged: (value) async {
                                              dialogSetState(() {
                                                clienteSelecionado = value;
                                                setorSelecionado = null;
                                                setores = [];
                                              });

                                              if (value != null) {
                                                final lista =
                                                await clienteRepository.listarSetoresPorCliente(value.id!);

                                                dialogSetState(() {
                                                  setores = lista;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: DropdownButtonFormField<Setor>(
                                            value: setores.any((s) => s.id == setorSelecionado?.id)
                                                ? setores.firstWhere((s) => s.id == setorSelecionado?.id)
                                                : null,
                                            decoration: buildInputDecoration(
                                              label: 'Setor',
                                              hint: 'Selecione o setor',
                                            ),
                                            items: setores.map((setor) {
                                              return DropdownMenuItem<Setor>(
                                                value: setor,
                                                child: Text(setor.nome),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              dialogSetState(() {
                                                setorSelecionado = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: tituloController,
                                            decoration: buildInputDecoration(
                                              label: 'Título',
                                              hint: 'Ex: Emissão Documentos de Transporte',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: TextField(
                                            controller: parteController,
                                            decoration: buildInputDecoration(
                                              label: 'Parte',
                                              hint: 'Ex: Parte 1',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: TextField(
                                            controller: codigoController,
                                            decoration: buildInputDecoration(
                                              label: 'Código',
                                              hint: 'Ex: ASDA',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: revisaoController,
                                            decoration: buildInputDecoration(
                                              label: 'Revisão',
                                              hint: 'Ex: 01',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: TextField(
                                            controller: dataController,
                                            decoration: buildInputDecoration(
                                              label: 'Data',
                                              hint: 'Ex: 03/03/2026',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: TextField(
                                            controller: responsaveisController,
                                            decoration: buildInputDecoration(
                                              label: 'Responsáveis',
                                              hint: 'Ex: Morais / Wesley',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: objetivoController,
                                      maxLines: 3,
                                      decoration: buildInputDecoration(
                                        label: 'Objetivo',
                                        hint: 'Digite o objetivo',
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: fornecedoresController,
                                      maxLines: 4,
                                      decoration: buildInputDecoration(
                                        label: 'Fornecedores',
                                        hint: 'Um ou mais fornecedores',
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: entradasController,
                                      maxLines: 4,
                                      decoration: buildInputDecoration(
                                        label: 'Entradas',
                                        hint: 'Digite as entradas',
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: processoController,
                                      maxLines: 6,
                                      decoration: buildInputDecoration(
                                        label: 'Processo',
                                        hint: 'Digite o processo',
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: saidasController,
                                      maxLines: 3,
                                      decoration: buildInputDecoration(
                                        label: 'Saídas',
                                        hint: 'Digite as saídas',
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: clientesController,
                                      maxLines: 3,
                                      decoration: buildInputDecoration(
                                        label: 'Clientes',
                                        hint: 'Digite os clientes',
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: indicadoresController,
                                      maxLines: 2,
                                      decoration: buildInputDecoration(
                                        label: 'Indicadores',
                                        hint: 'Digite os indicadores',
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: fluxoTextoController,
                                      maxLines: 4,
                                      decoration: buildInputDecoration(
                                        label: 'Fluxo texto',
                                        hint: 'Use aspas para marcar os blocos do fluxo',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 7,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: SingleChildScrollView(
                                child: Builder(
                                  builder: (context) {
                                    final blocosFluxo = extrairBlocosFluxo(fluxoTextoController.text);

                                    return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: const Color(0xFFE5E7EB)),
                                      ),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          width: 980,
                                          color: Colors.white,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.black54),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 220,
                                                          height: 90,
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.black54),
                                                            color: Colors.white,
                                                          ),
                                                          alignment: Alignment.center,
                                                          child: clienteSelecionado != null &&
                                                              clienteSelecionado!.logoPath.isNotEmpty
                                                              ? Padding(
                                                            padding: const EdgeInsets.all(8),
                                                            child: Image.file(
                                                              File(clienteSelecionado!.logoPath),
                                                              fit: BoxFit.contain,
                                                              errorBuilder: (_, __, ___) {
                                                                return const Icon(
                                                                  Icons.business,
                                                                  size: 40,
                                                                );
                                                              },
                                                            ),
                                                          )
                                                              : const Icon(Icons.business, size: 40),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            height: 90,
                                                            decoration: BoxDecoration(
                                                              border: Border.all(color: Colors.black54),
                                                              color: Colors.white,
                                                            ),
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Text(
                                                                  clienteSelecionado?.nome ?? '',
                                                                  style: const TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 15,
                                                                    color: Colors.black,
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 4),
                                                                Text(
                                                                  setorSelecionado?.nome ?? '',
                                                                  style: const TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 14,
                                                                    color: Colors.black,
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 8),
                                                                Text(
                                                                  parteController.text,
                                                                  style: const TextStyle(
                                                                    fontSize: 14,
                                                                    color: Colors.black,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 220,
                                                          constraints: const BoxConstraints(minHeight: 120),
                                                          padding: const EdgeInsets.all(8),
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.black54),
                                                            color: Colors.white,
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Text('Código: ${codigoController.text}'),
                                                              Text('Revisão: ${revisaoController.text}'),
                                                              Text('Data: ${dataController.text}'),
                                                              Text(
                                                                'Resp.: ${responsaveisController.text}',
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 220,
                                                          height: 64,
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.black54),
                                                            color: Colors.white,
                                                          ),
                                                          padding: const EdgeInsets.all(8),
                                                          child: const Align(
                                                            alignment: Alignment.centerLeft,
                                                            child: Text(
                                                              'OBJETIVO:',
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            height: 64,
                                                            decoration: BoxDecoration(
                                                              border: Border.all(color: Colors.black54),
                                                              color: Colors.white,
                                                            ),
                                                            padding: const EdgeInsets.all(8),
                                                            alignment: Alignment.centerLeft,
                                                            child: Text(
                                                              objetivoController.text,
                                                              style: const TextStyle(
                                                                color: Color(0xFFB91C1C),
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 40,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 9,
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                border: Border.all(color: Colors.black54),
                                                                color: const Color(0xFFF9FAFB),
                                                              ),
                                                              alignment: Alignment.center,
                                                              child: const Text(
                                                                'Descrição do SIPOC',
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 10,
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                border: Border.all(color: Colors.black54),
                                                                color: const Color(0xFFF9FAFB),
                                                              ),
                                                              alignment: Alignment.center,
                                                              child: const Text(
                                                                'Fluxograma',
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 560,
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                                        children: [
                                                          Expanded(
                                                            flex: 9,
                                                            child: Row(
                                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                                              children: [
                                                                Container(
                                                                  width: 36,
                                                                  decoration: BoxDecoration(
                                                                    border: Border.all(color: Colors.black54),
                                                                    color: Colors.white,
                                                                  ),
                                                                  child: Column(
                                                                    children: const [
                                                                      Expanded(
                                                                        flex: 12,
                                                                        child: Center(
                                                                          child: Text(
                                                                            'S',
                                                                            style: TextStyle(
                                                                              fontSize: 20,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 12,
                                                                        child: Center(
                                                                          child: Text(
                                                                            'I',
                                                                            style: TextStyle(
                                                                              fontSize: 20,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 28,
                                                                        child: Center(
                                                                          child: Text(
                                                                            'P',
                                                                            style: TextStyle(
                                                                              fontSize: 20,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 10,
                                                                        child: Center(
                                                                          child: Text(
                                                                            'O',
                                                                            style: TextStyle(
                                                                              fontSize: 20,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 10,
                                                                        child: Center(
                                                                          child: Text(
                                                                            'C',
                                                                            style: TextStyle(
                                                                              fontSize: 20,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    children: [
                                                                      Expanded(
                                                                        flex: 12,
                                                                        child: _buildDescricaoLinha(
                                                                          titulo: 'Fornecedores',
                                                                          texto: fornecedoresController.text,
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 12,
                                                                        child: _buildDescricaoLinha(
                                                                          titulo: 'Entrada',
                                                                          texto: entradasController.text,
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 28,
                                                                        child: _buildDescricaoLinha(
                                                                          titulo: 'Processo',
                                                                          texto: processoController.text,
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 10,
                                                                        child: _buildDescricaoLinha(
                                                                          titulo: 'Saída',
                                                                          texto: saidasController.text,
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 10,
                                                                        child: _buildDescricaoLinha(
                                                                          titulo: 'Clientes',
                                                                          texto: clientesController.text,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 10,
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                border: Border.all(color: Colors.black54),
                                                                color: Colors.white,
                                                              ),
                                                              alignment: Alignment.topCenter,
                                                              padding: const EdgeInsets.only(
                                                                top: 16,
                                                                left: 16,
                                                                right: 16,
                                                                bottom: 16,
                                                              ),
                                                              child: _buildFluxoColuna(blocosFluxo),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 254,
                                                          padding: const EdgeInsets.all(10),
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.black54),
                                                            color: Colors.white,
                                                          ),
                                                          child: const Text(
                                                            'INDICADORES DESEMPENHO',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            padding: const EdgeInsets.all(10),
                                                            decoration: BoxDecoration(
                                                              border: Border.all(color: Colors.black54),
                                                              color: Colors.white,
                                                            ),
                                                            child: Text(
                                                              indicadoresController.text,
                                                              style: const TextStyle(
                                                                color: Color(0xFFB91C1C),
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(Icons.close),
                          label: const Text('Cancelar'),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () async {
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
                                id: item?.sipoc.id,
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

                              if (item == null) {
                                await sipocRepository.inserirSipoc(sipoc);
                              } else {
                                await sipocRepository.atualizarSipoc(sipoc);
                              }

                              await carregarSipocs();
                              if (!mounted) return;

                              setState(() {});

                              Navigator.of(dialogContext).pop();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    item == null
                                        ? 'SIPOC salvo com sucesso!'
                                        : 'SIPOC atualizado com sucesso!',
                                  ),
                                  backgroundColor: const Color(0xFF059669),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro ao salvar SIPOC: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.save),
                          label: Text(item == null ? 'Salvar SIPOC' : 'Salvar alterações'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> excluirSipoc(SipocDetalhe item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir SIPOC'),
          content: Text(
            'Deseja realmente excluir o SIPOC "${item.sipoc.titulo}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    await sipocRepository.excluirSipoc(item.sipoc.id!);
    await carregarSipocs();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SIPOC excluído com sucesso!'),
        backgroundColor: Color(0xFF059669),
      ),
    );
  }

  Widget _buildDescricaoLinha({
    required String titulo,
    required String texto,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                texto,
                style: const TextStyle(
                  color: Color(0xFFB91C1C),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildTextoSecao(String titulo, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          valor,
          style: const TextStyle(
            color: Color(0xFFB91C1C),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFluxoColuna(List<String> blocos) {
    if (blocos.isEmpty) {
      return const Center(
        child: Text(
          'Digite frases entre aspas no campo Fluxo texto.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(blocos.length, (index) {
          final ultimo = index == blocos.length - 1;

          return Column(
            children: [
              Container(
                width: 210,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black87),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  blocos[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ),
              if (!ultimo)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Icon(
                    Icons.arrow_downward,
                    size: 20,
                    color: Colors.black87,
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFluxo(List<String> blocos) {
    if (blocos.isEmpty) {
      return const Center(
        child: Text(
          'Digite frases entre aspas no campo "Fluxo texto".',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
          ),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(blocos.length, (index) {
          return FluxoBox(
            texto: blocos[index],
            mostrarSeta: index < blocos.length - 1,
          );
        }),
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
        borderSide: const BorderSide(color: Color(0xFF1D4ED8), width: 1.4),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SIPOC',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cadastro e gerenciamento de SIPOCs por cliente e setor.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => abrirSipocDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Novo SIPOC'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF12324A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: sipocs.isEmpty
              ? Container(
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Nenhum SIPOC cadastrado.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          )
              : LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 1;
              if (constraints.maxWidth > 1400) {
                crossAxisCount = 3;
              } else if (constraints.maxWidth > 900) {
                crossAxisCount = 2;
              }

              return GridView.builder(
                itemCount: sipocs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.70,
                ),
                itemBuilder: (context, index) {
                  final item = sipocs[index];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SipocWorkspacePage(item: item),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: item.clienteLogoPath.isNotEmpty
                                    ? Image.file(
                                  File(item.clienteLogoPath),
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) {
                                    return const Icon(
                                      Icons.business,
                                      color: Color(0xFF6B7280),
                                    );
                                  },
                                )
                                    : const Icon(
                                  Icons.business,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (() {
                                        // 1) se a query já trouxe nome, usa ele
                                        if (item.clienteNome.trim().isNotEmpty &&
                                            item.clienteNome != 'Cliente não encontrado') {
                                          return item.clienteNome;
                                        }

                                        // 2) tenta achar na lista de clientes carregada na tela
                                        final clienteDaTela = clientes
                                            .where((c) => c.id == item.sipoc.clienteId)
                                            .cast<Cliente?>()
                                            .firstWhere(
                                              (c) => c != null,
                                          orElse: () => null,
                                        );

                                        if (clienteDaTela != null && clienteDaTela.nome.trim().isNotEmpty) {
                                          return clienteDaTela.nome;
                                        }

                                        // 3) fallback final
                                        return 'Cliente ID ${item.sipoc.clienteId}';
                                      })(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      (() {
                                        // 1) se veio nome do banco, usa
                                        if (item.setorNome.trim().isNotEmpty &&
                                            item.setorNome != 'Setor não encontrado') {
                                          return item.setorNome;
                                        }

                                        // 2) tenta achar o setor na lista global
                                        final setorDaTela = todosSetores
                                            .where((s) => s.id == item.sipoc.setorId)
                                            .cast<Setor?>()
                                            .firstWhere(
                                              (s) => s != null,
                                          orElse: () => null,
                                        );

                                        if (setorDaTela != null && setorDaTela.nome.trim().isNotEmpty) {
                                          return setorDaTela.nome;
                                        }

                                        // 3) fallback final
                                        return 'Setor ID ${item.sipoc.setorId}';
                                      })(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            item.sipoc.titulo.isEmpty ? 'Sem título' : item.sipoc.titulo,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Código: ${item.sipoc.codigo.isEmpty ? '-' : item.sipoc.codigo}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Revisão: ${item.sipoc.revisao.isEmpty ? '-' : item.sipoc.revisao}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Data: ${item.sipoc.dataEmissao.isEmpty ? '-' : item.sipoc.dataEmissao}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 20),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => abrirSipocDialog(item: item),
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  label: const Text('Editar'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => excluirSipoc(item),
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  label: const Text('Excluir'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}