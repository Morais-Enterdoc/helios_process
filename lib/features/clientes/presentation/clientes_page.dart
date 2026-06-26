import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/cliente_repository.dart';
import '../domain/cliente.dart';
import '../domain/cliente_com_setores.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final ClienteRepository repository = ClienteRepository();

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController setorController = TextEditingController();

  List<ClienteComSetores> clientes = [];
  List<String> setoresTemporarios = [];
  String? logoPath;

  List<int> diasAtendimentoTemporarios = [];
  String corAgendaSelecionada = '#FEF3C7';

  static const List<Map<String, dynamic>> diasSemanaOpcoes = [
    {'valor': 1, 'label': 'Seg'},
    {'valor': 2, 'label': 'Ter'},
    {'valor': 3, 'label': 'Qua'},
    {'valor': 4, 'label': 'Qui'},
    {'valor': 5, 'label': 'Sex'},
    {'valor': 6, 'label': 'Sáb'},
    {'valor': 7, 'label': 'Dom'},
  ];

  static const List<String> coresAgendaOpcoes = [
    '#FEF3C7',
    '#DBEAFE',
    '#DCFCE7',
    '#FCE7F3',
    '#EDE9FE',
    '#FEE2E2',
  ];

  @override
  void initState() {
    super.initState();
    carregarClientes();
  }

  @override
  void dispose() {
    nomeController.dispose();
    setorController.dispose();
    super.dispose();
  }

  Future<void> carregarClientes() async {
    try {
      final lista = await repository.listarClientesComSetores();
      if (!mounted) return;

      setState(() {
        clientes = lista;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar clientes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> abrirClienteDialog({ClienteComSetores? item}) async {
    nomeController.text = item?.cliente.nome ?? '';
    logoPath = item?.cliente.logoPath.isNotEmpty == true ? item!.cliente.logoPath : null;
    setoresTemporarios = item?.setores.map((e) => e.nome).toList() ?? [];
    setorController.clear();

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            Future<void> selecionarLogoDialog() async {
              final resultado = await FilePicker.platform.pickFiles(
                type: FileType.image,
              );

              if (resultado == null || resultado.files.single.path == null) return;

              dialogSetState(() {
                logoPath = resultado.files.single.path!;
              });

              setState(() {});
            }

            void adicionarSetorDialog() {
              final nome = setorController.text.trim();
              if (nome.isEmpty) return;
              if (setoresTemporarios.any((s) => s.toLowerCase() == nome.toLowerCase())) {
                setorController.clear();
                return;
              }

              dialogSetState(() {
                setoresTemporarios.add(nome);
                setorController.clear();
              });
            }

            void removerSetorDialog(String setor) {
              dialogSetState(() {
                setoresTemporarios.remove(setor);
              });
            }

            void alternarDiaAtendimento(int dia) {
              dialogSetState(() {
                if (diasAtendimentoTemporarios.contains(dia)) {
                  diasAtendimentoTemporarios.remove(dia);
                } else {
                  diasAtendimentoTemporarios.add(dia);
                  diasAtendimentoTemporarios.sort();
                }
              });
            }

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                width: 760,
                constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item == null ? 'Novo cliente' : 'Editar cliente',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Cadastre o cliente, selecione a logo e adicione os setores individualmente.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextField(
                              controller: nomeController,
                              decoration: buildInputDecoration(
                                label: 'Nome do cliente',
                                hint: 'Ex: Lotus Logística',
                              ),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: setorController,
                                    decoration: buildInputDecoration(
                                      label: 'Setor',
                                      hint: 'Ex: Transporte',
                                    ),
                                    onSubmitted: (_) => adicionarSetorDialog(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: ElevatedButton.icon(
                                    onPressed: adicionarSetorDialog,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Adicionar setor'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF12324A),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: setoresTemporarios.isEmpty
                                  ? const Text(
                                'Nenhum setor adicionado.',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 13,
                                ),
                              )
                                  : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: setoresTemporarios.map((setor) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F2FE),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          setor,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF0369A1),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: () => removerSetorDialog(setor),
                                          child: const Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Color(0xFF0369A1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 16),

                            const SizedBox(height: 16),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Dias de atendimento',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Selecione os dias recorrentes em que você costuma atender este cliente.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: diasSemanaOpcoes.map((dia) {
                                      final valor = dia['valor'] as int;
                                      final label = dia['label'] as String;
                                      final selecionado = diasAtendimentoTemporarios.contains(valor);

                                      return InkWell(
                                        onTap: () => alternarDiaAtendimento(valor),
                                        borderRadius: BorderRadius.circular(999),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: selecionado
                                                ? const Color(0xFF12324A)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(999),
                                            border: Border.all(
                                              color: selecionado
                                                  ? const Color(0xFF12324A)
                                                  : const Color(0xFFD1D5DB),
                                            ),
                                          ),
                                          child: Text(
                                            label,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: selecionado
                                                  ? Colors.white
                                                  : const Color(0xFF374151),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Cor da coluna na agenda',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: coresAgendaOpcoes.map((cor) {
                                      final selecionada = corAgendaSelecionada == cor;

                                      return InkWell(
                                        onTap: () {
                                          dialogSetState(() {
                                            corAgendaSelecionada = cor;
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(999),
                                        child: Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: Color(int.parse('FF${cor.replaceAll('#', '')}', radix: 16)),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: selecionada
                                                  ? const Color(0xFF111827)
                                                  : const Color(0xFFD1D5DB),
                                              width: selecionada ? 2 : 1,
                                            ),
                                          ),
                                          child: selecionada
                                              ? const Icon(Icons.check, size: 18, color: Color(0xFF111827))
                                              : null,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),

                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: selecionarLogoDialog,
                                  icon: const Icon(Icons.image_outlined),
                                  label: Text(
                                    logoPath == null ? 'Selecionar logo' : 'Trocar logo',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            if (logoPath != null)
                              Container(
                                width: 160,
                                height: 120,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: Image.file(
                                  File(logoPath!),
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) {
                                    return const Center(
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
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
                            final nome = nomeController.text.trim();
                            if (nome.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Informe o nome do cliente.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (setoresTemporarios.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Adicione pelo menos um setor.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            try {
                              await repository.salvarClienteComSetores(
                                cliente: Cliente(
                                  id: item?.cliente.id,
                                  nome: nome,
                                  logoPath: logoPath ?? '',
                                  diasAtendimento: diasAtendimentoTemporarios.join(','),
                                  corAgenda: corAgendaSelecionada,
                                ),
                                setores: setoresTemporarios,
                              );

                              await carregarClientes();
                              if (!mounted) return;

                              Navigator.of(dialogContext).pop();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    item == null
                                        ? 'Cliente cadastrado com sucesso!'
                                        : 'Cliente atualizado com sucesso!',
                                  ),
                                  backgroundColor: const Color(0xFF059669),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro ao salvar cliente: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.save),
                          label: Text(item == null ? 'Salvar cliente' : 'Salvar alterações'),
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

  Future<void> excluirCliente(ClienteComSetores item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir cliente'),
          content: Text(
            'Deseja realmente excluir o cliente "${item.cliente.nome}" e todos os setores vinculados?',
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

    try {
      await repository.excluirCliente(item.cliente.id!);
      await carregarClientes();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente excluído com sucesso!'),
          backgroundColor: Color(0xFF059669),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir cliente: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  InputDecoration buildInputDecoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF0F766E),
          width: 1.4,
        ),
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
                    'Clientes',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cadastro de clientes com logo e setores vinculados.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => abrirClienteDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Novo cliente'),
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
          child: clientes.isEmpty
              ? Container(
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Nenhum cliente cadastrado.',
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
                itemCount: clientes.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.25,
                ),
                itemBuilder: (context, index) {
                  final item = clientes[index];
                  final cliente = item.cliente;
                  final setores = item.setores.map((e) => e.nome).join(', ');

                  return Container(
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
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 78,
                                height: 78,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: cliente.logoPath.isNotEmpty
                                    ? Image.file(
                                  File(cliente.logoPath),
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) {
                                    return const Icon(
                                      Icons.broken_image_outlined,
                                      color: Color(0xFF9CA3AF),
                                    );
                                  },
                                )
                                    : const Icon(
                                  Icons.business,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      cliente.nome,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      setores,
                                      maxLines: 4,
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
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => abrirClienteDialog(item: item),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('Editar'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () => excluirCliente(item),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text('Excluir'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
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