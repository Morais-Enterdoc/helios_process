import 'package:flutter/material.dart';
import 'dart:io';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import '../../chamados/data/chamado_repository.dart';
import '../../chamados/domain/chamado.dart';
import '../../chamados/presentation/chamados_page.dart';
import '../../clientes/presentation/clientes_page.dart';
import '../../sipoc/presentation/sipoc_page.dart';
import '../../tarefas/presentation/tarefas_page.dart';
import '../../../shared/widgets/app_menu.dart';
import '../../agenda/presentation/agenda_page.dart';
import '../../cronograma/presentation/cronograma_projeto_page.dart';
import '../../tarefas/data/tarefa_repository.dart';
import '../../agenda/data/agenda_manual_repository.dart';
import '../../sipoc/data/sipoc_repository.dart';
import '../../cronograma/data/cronograma_repository.dart';
import '../../tarefas/domain/tarefa_detalhe.dart';
import '../../agenda/domain/agenda_manual.dart';
import '../../timeline/presentation/timeline_page.dart';

bool menuRecolhido = false;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedMenu = 'dashboard';

  final ChamadoRepository chamadoRepository = ChamadoRepository();

  List<Chamado> chamadosDashboard = [];
  bool carregandoDashboardReal = true;
  String dashboardCardSelecionado = 'chamados_mo';

  final TarefaRepository tarefaRepository = TarefaRepository();
  final AgendaManualRepository agendaManualRepository = AgendaManualRepository();
  final CronogramaRepository cronogramaRepository = CronogramaRepository();

  final TextEditingController agendaTituloController = TextEditingController();
  final TextEditingController agendaDescricaoController = TextEditingController();
  final TextEditingController agendaObservacoesController = TextEditingController();
  final TextEditingController agendaDataController = TextEditingController();
  final TextEditingController agendaHoraInicioController = TextEditingController();
  final TextEditingController agendaHoraFimController = TextEditingController();

  String agendaStatusSelecionado = 'Planejada';
  String agendaCorSelecionada = 'DBEAFE';
  AgendaManual? agendaDashboardSelecionada;

  int totalTarefasDia = 0;
  int totalTarefasSemana = 0;
  int totalAgendasDia = 0;
  int totalAgendasAmanha = 0;
  int totalAgendasSemana = 0;
  int totalProjetosAtivos = 0;

  List<Map<String, dynamic>> projetosAtivosPorEmpresa = [];

  List<dynamic> tarefasDoDiaDetalhadas = [];
  List<dynamic> tarefasAmanhaDetalhadas = [];

  List<AgendaManual> agendasHojeDetalhadas = [];
  List<AgendaManual> agendasAmanhaDetalhadas = [];

  final List<Map<String, dynamic>> dashboardChamadosFake = [
    {
      'cliente': 'Enterdoc Interno',
      'total': 8,
      'abertos': 5,
      'fechados': 3,
      'emAnalise': 2,
      'desenvolvimento': 3,
    },
    {
      'cliente': 'Cliente Exemplo 01',
      'total': 6,
      'abertos': 4,
      'fechados': 2,
      'emAnalise': 1,
      'desenvolvimento': 2,
    },
    {
      'cliente': 'Cliente Exemplo 02',
      'total': 11,
      'abertos': 8,
      'fechados': 3,
      'emAnalise': 4,
      'desenvolvimento': 2,
    },
  ];

  Future<void> _carregarChamadosDashboard() async {
    try {
      final chamados = await chamadoRepository.listarChamados();

      if (!mounted) return;

      setState(() {
        chamadosDashboard = chamados;
        carregandoDashboardReal = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregandoDashboardReal = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar chamados do dashboard: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  InputDecoration buildInputDecorationAgendaDashboard({
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

  Widget buildTextFieldAgendaDashboard({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: buildInputDecorationAgendaDashboard(
        label: label,
        hint: hint,
      ),
    );
  }

  Widget _buildChipAgenda(String texto, {bool destaque = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: destaque ? const Color(0xFFEEF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: destaque ? null : Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: destaque ? const Color(0xFF4338CA) : const Color(0xFF374151),
        ),
      ),
    );
  }



  DateTime? parseDataBr(String valor) {
    try {
      final partes = valor.split('/');
      if (partes.length != 3) return null;

      final dia = int.parse(partes[0]);
      final mes = int.parse(partes[1]);
      final ano = int.parse(partes[2]);

      return DateTime(ano, mes, dia);
    } catch (_) {
      return null;
    }
  }

  Future<void> carregarIndicadoresDashboard() async {
    try {
      final agora = DateTime.now();
      final hoje = DateTime(agora.year, agora.month, agora.day);
      final amanha = hoje.add(const Duration(days: 1));

      final inicioSemana = hoje.subtract(
        Duration(days: hoje.weekday - DateTime.monday),
      );
      final fimSemana = inicioSemana.add(const Duration(days: 6));

      final tarefas = await tarefaRepository.listarTarefasComCliente();
      final agendas = await agendaManualRepository.listarTodos();
      final cronogramas = await cronogramaRepository.listarCronogramas();


      int tarefasDia = 0;
      int tarefasSemana = 0;
      int agendasDia = 0;
      int agendasAmanha = 0;
      int agendasSemana = 0;
      int projetosAtivos = 0;
      final List<dynamic> tarefasDiaLista = [];
      final List<dynamic> tarefasAmanhaLista = [];
      final List<AgendaManual> agendasHojeLista = [];
      final List<AgendaManual> agendasAmanhaLista = [];
      final Map<String, int> agrupadoProjetosEmpresa = {};

      for (final item in tarefas) {
        final data = parseDataBr(item.tarefa.data);
        if (data == null) continue;

        final dataNormalizada = DateTime(data.year, data.month, data.day);

        if (dataNormalizada == hoje) {
          tarefasDia++;
          tarefasDiaLista.add(item);
        }

        if (dataNormalizada == amanha) {
          tarefasAmanhaLista.add(item);
        }

        final estaNaSemana = !dataNormalizada.isBefore(inicioSemana) &&
            !dataNormalizada.isAfter(fimSemana);

        if (estaNaSemana) {
          tarefasSemana++;
        }
      }

      for (final agenda in agendas) {
        final data = parseDataBr(agenda.data);
        if (data == null) continue;

        final dataNormalizada = DateTime(data.year, data.month, data.day);

        if (dataNormalizada == hoje) {
          agendasDia++;
          agendasHojeLista.add(agenda);
        }

        if (dataNormalizada == amanha) {
          agendasAmanha++;
          agendasAmanhaLista.add(agenda);
        }

        final estaNaSemana = !dataNormalizada.isBefore(inicioSemana) &&
            !dataNormalizada.isAfter(fimSemana);

        if (estaNaSemana) {
          agendasSemana++;
        }
      }

      for (final projeto in cronogramas) {
        final statusProjeto = (projeto.status ?? '').toString().trim().toLowerCase();

        final ativo = statusProjeto.isEmpty ||
            statusProjeto == 'ativo' ||
            statusProjeto == 'em andamento';

        if (!ativo) continue;

        projetosAtivos++;

        final empresa = (projeto.nomeProjeto).toString().trim().isEmpty
            ? 'Sem projeto'
            : projeto.nomeProjeto.toString().trim();
        agrupadoProjetosEmpresa[empresa] =
            (agrupadoProjetosEmpresa[empresa] ?? 0) + 1;
      }

      final resumoProjetosEmpresa = agrupadoProjetosEmpresa.entries
          .map(
            (entry) => {
          'empresa': entry.key,
          'total': entry.value,
        },
      )
          .toList();

      resumoProjetosEmpresa.sort(
            (a, b) => a['empresa']
            .toString()
            .toLowerCase()
            .compareTo(b['empresa'].toString().toLowerCase()),
      );

      if (!mounted) return;

      setState(() {
        totalTarefasDia = tarefasDia;
        totalTarefasSemana = tarefasSemana;
        totalAgendasDia = agendasDia;
        totalAgendasAmanha = agendasAmanha;
        totalAgendasSemana = agendasSemana;
        totalProjetosAtivos = projetosAtivos;
        projetosAtivosPorEmpresa = resumoProjetosEmpresa;
        tarefasDoDiaDetalhadas = tarefasDiaLista;
        agendasHojeDetalhadas = agendasHojeLista;
        agendasAmanhaDetalhadas = agendasAmanhaLista;
        tarefasAmanhaDetalhadas = tarefasAmanhaLista;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar indicadores do dashboard: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> abrirDialogEditarAgendaDashboard(AgendaManual item) async {
    agendaDashboardSelecionada = item;
    agendaTituloController.text = item.titulo;
    agendaDescricaoController.text = item.descricao;
    agendaObservacoesController.text = item.observacoes;
    agendaDataController.text = item.data;
    agendaHoraInicioController.text = item.horaInicio ?? '';
    agendaHoraFimController.text = item.horaFim ?? '';
    agendaStatusSelecionado = item.status;
    agendaCorSelecionada = item.cor ?? 'DBEAFE';

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        String statusDialog = agendaStatusSelecionado;

        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                width: 760,
                constraints: const BoxConstraints(
                  maxWidth: 760,
                  maxHeight: 720,
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.edit_calendar_outlined,
                            color: Color(0xFF0369A1),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Editar agenda',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Visualize e altere os dados do compromisso.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            statusDialog,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0369A1),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            buildTextFieldAgendaDashboard(
                              controller: agendaTituloController,
                              label: 'Título',
                              hint: 'Ex.: Reunião de alinhamento',
                            ),
                            const SizedBox(height: 16),
                            buildTextFieldAgendaDashboard(
                              controller: agendaDescricaoController,
                              label: 'Descrição',
                              hint: 'Descreva o compromisso',
                              maxLines: 4,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: buildTextFieldAgendaDashboard(
                                    controller: agendaDataController,
                                    label: 'Data',
                                    hint: 'Ex.: 08/05/2026',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: buildTextFieldAgendaDashboard(
                                    controller: agendaHoraInicioController,
                                    label: 'Hora início',
                                    hint: 'Ex.: 09:00',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: buildTextFieldAgendaDashboard(
                                    controller: agendaHoraFimController,
                                    label: 'Hora fim',
                                    hint: 'Ex.: 10:00',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: statusDialog,
                              decoration: buildInputDecorationAgendaDashboard(
                                label: 'Status',
                                hint: 'Selecione o status',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Planejada',
                                  child: Text('Planejada'),
                                ),
                                DropdownMenuItem(
                                  value: 'Em andamento',
                                  child: Text('Em andamento'),
                                ),
                                DropdownMenuItem(
                                  value: 'Concluída',
                                  child: Text('Concluída'),
                                ),
                                DropdownMenuItem(
                                  value: 'Cancelada',
                                  child: Text('Cancelada'),
                                ),
                              ],
                              onChanged: (value) {
                                dialogSetState(() {
                                  statusDialog = value ?? 'Planejada';
                                  agendaStatusSelecionado = value ?? 'Planejada';
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            buildTextFieldAgendaDashboard(
                              controller: agendaObservacoesController,
                              label: 'Observações',
                              hint: 'Anotações rápidas',
                              maxLines: 3,
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
                          label: const Text('Fechar'),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (agendaDashboardSelecionada == null) return;

                            if (agendaTituloController.text.trim().isEmpty ||
                                agendaDataController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Título e data são obrigatórios.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            try {
                              final atualizado = agendaDashboardSelecionada!.copyWith(
                                titulo: agendaTituloController.text.trim(),
                                descricao: agendaDescricaoController.text.trim(),
                                observacoes: agendaObservacoesController.text.trim(),
                                data: agendaDataController.text.trim(),
                                horaInicio: agendaHoraInicioController.text.trim().isEmpty
                                    ? null
                                    : agendaHoraInicioController.text.trim(),
                                horaFim: agendaHoraFimController.text.trim().isEmpty
                                    ? null
                                    : agendaHoraFimController.text.trim(),
                                status: agendaStatusSelecionado,
                                cor: agendaCorSelecionada,
                                updatedAt: DateTime.now().toIso8601String(),
                              );

                              await agendaManualRepository.atualizar(atualizado);
                              await carregarIndicadoresDashboard();

                              if (!mounted) return;
                              Navigator.of(dialogContext).pop();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Agenda atualizada com sucesso!'),
                                  backgroundColor: Color(0xFF059669),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro ao atualizar agenda: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Salvar alterações'),
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

  Future<void> abrirDialogVisualizarTarefaDashboard(dynamic itemTarefa) async {
    final tarefa = itemTarefa.tarefa;
    final clienteNome = itemTarefa.clienteNome ?? 'Sem cliente';

    String valorOuTraco(String? valor) {
      if (valor == null || valor.trim().isEmpty) return '-';
      return valor.trim();
    }

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: 680,
            constraints: const BoxConstraints(
              maxWidth: 680,
              maxHeight: 620,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.task_alt_outlined,
                        color: Color(0xFF6D28D9),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detalhes da tarefa',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Visualização da tarefa carregada no dashboard.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        buildCampoVisualizacaoDashboard('Título', valorOuTraco(tarefa.titulo)),
                        const SizedBox(height: 16),
                        buildCampoVisualizacaoDashboard('Cliente', valorOuTraco(clienteNome)),
                        const SizedBox(height: 16),
                        buildCampoVisualizacaoDashboard('Data', valorOuTraco(tarefa.data)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: buildCampoVisualizacaoDashboard(
                                'Hora início',
                                valorOuTraco(tarefa.horaInicio?.toString()),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: buildCampoVisualizacaoDashboard(
                                'Hora fim',
                                valorOuTraco(tarefa.horaFim?.toString()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        buildCampoVisualizacaoDashboard('Status', valorOuTraco(tarefa.status)),
                        const SizedBox(height: 16),
                        buildCampoVisualizacaoDashboard(
                          'Descrição',
                          valorOuTraco(tarefa.descricao?.toString()),
                        ),
                        const SizedBox(height: 16),
                        buildCampoVisualizacaoDashboard(
                          'Observações',
                          valorOuTraco(tarefa.observacoes?.toString()),
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
                      label: const Text('Fechar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _totalChamados() {
    return chamadosDashboard.length;
  }

  int _totalAbertos() {
    return chamadosDashboard
        .where((chamado) => chamado.status.toLowerCase() == 'aberto')
        .length;
  }

  int _totalFechados() {
    return chamadosDashboard
        .where((chamado) => chamado.status.toLowerCase() == 'fechado')
        .length;
  }

  int _totalEmAnalise() {
    return chamadosDashboard
        .where((chamado) => chamado.meuStatus.toLowerCase() == 'em análise')
        .length;
  }

  int _totalDesenvolvimento() {
    return chamadosDashboard
        .where((chamado) => chamado.meuStatus.toLowerCase() == 'desenvolvimento')
        .length;
  }

  int _totalChamadosGrid() {
    return _montarResumoPorClienteMeuStatus().fold(
      0,
          (soma, linha) => soma + ((linha['total'] as int?) ?? 0),
    );
  }

  int _totalFechadosGrid() {
    return _montarResumoPorClienteMeuStatus().fold(
      0,
          (soma, linha) => soma + ((linha['fechado'] as int?) ?? 0),
    );
  }

  int _totalChamadosEmAbertoCard() {
    return _totalChamadosGrid() - _totalFechadosGrid();
  }

  int get totalCompromissosAmanha =>
      agendasAmanhaDetalhadas.length + tarefasAmanhaDetalhadas.length;

  int get totalCompromissosHoje =>
      agendasHojeDetalhadas.length + tarefasDoDiaDetalhadas.length;

  List<Map<String, dynamic>> _montarResumoPorClienteMeuStatus() {
    final Map<String, Map<String, int>> agrupado = {};

    for (final chamado in chamadosDashboard) {
      final cliente = (chamado.cliente.isEmpty ? 'Sem cliente' : chamado.cliente).trim();

      final entrada = agrupado.putIfAbsent(cliente, () {
        return {
          'total': 0,
          'emAnalise': 0,
          'desenvolvimento': 0,
          'testes': 0,
          'atualizacoes': 0,
          'fechado': 0,
        };
      });

      entrada['total'] = (entrada['total'] ?? 0) + 1;

      final meuStatus = chamado.meuStatus.toLowerCase().trim();

      if (meuStatus == 'em análise' || meuStatus == 'em analise') {
        entrada['emAnalise'] = (entrada['emAnalise'] ?? 0) + 1;
      } else if (meuStatus == 'desenvolvimento') {
        entrada['desenvolvimento'] = (entrada['desenvolvimento'] ?? 0) + 1;
      } else if (meuStatus == 'teste base m&o' ||
          meuStatus == 'testes cliente') {
        entrada['testes'] = (entrada['testes'] ?? 0) + 1;
      } else if (meuStatus == 'atualização sistema' ||
          meuStatus == 'atualizacao sistema' ||
          meuStatus == 'atualização sprint' ||
          meuStatus == 'atualizacao sprint' ||
          meuStatus == 'atualização base cliente' ||
          meuStatus == 'atualizacao base cliente') {
        entrada['atualizacoes'] = (entrada['atualizacoes'] ?? 0) + 1;
      } else if (meuStatus == 'fechado') {
        entrada['fechado'] = (entrada['fechado'] ?? 0) + 1;
      }
    }

    final linhas = agrupado.entries.map((entry) {
      final cliente = entry.key;
      final valores = entry.value;

      return {
        'cliente': cliente,
        'total': valores['total'] ?? 0,
        'emAnalise': valores['emAnalise'] ?? 0,
        'desenvolvimento': valores['desenvolvimento'] ?? 0,
        'testes': valores['testes'] ?? 0,
        'atualizacoes': valores['atualizacoes'] ?? 0,
        'fechado': valores['fechado'] ?? 0,
      };
    }).toList();

    linhas.sort((a, b) => a['cliente']
        .toString()
        .toLowerCase()
        .compareTo(b['cliente'].toString().toLowerCase()));

    return linhas;
  }

  String _normalizarTexto(String valor) {
    return valor
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
  }

  List<Chamado> _filtrarChamadosRelatorio({
    required String cliente,
    required String tipo,
  }) {
    final clienteFiltro = _normalizarTexto(cliente);
    final tipoFiltro = _normalizarTexto(tipo);

    return chamadosDashboard.where((chamado) {
      final clienteChamado = _normalizarTexto(chamado.cliente);
      final meuStatus = _normalizarTexto(chamado.meuStatus);

      if (clienteChamado != clienteFiltro) {
        return false;
      }

      switch (tipoFiltro) {
        case 'total':
          return true;

        case 'em analise':
          return meuStatus == 'em analise';

        case 'desenvolvimento':
          return meuStatus == 'desenvolvimento';

        case 'testes':
          return meuStatus == 'teste base m&o' ||
              meuStatus == 'testes cliente';

        case 'atualizacoes':
          return meuStatus == 'atualizacao sistema' ||
              meuStatus == 'atualizacao sprint' ||
              meuStatus == 'atualizacao base cliente';

        case 'fechado':
          return meuStatus == 'fechado';

        default:
          return false;
      }
    }).toList();
  }

  List<Map<String, dynamic>> get _dashboardChamadosPorClienteMeuStatus {
    return _montarResumoPorClienteMeuStatus();
  }

  @override
  void initState() {
    super.initState();
    _carregarChamadosDashboard();
    carregarIndicadoresDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          AppMenu(
            selectedItem: selectedMenu,
            isCollapsed: menuRecolhido,
            onToggleCollapse: () {
              setState(() {
                menuRecolhido = !menuRecolhido;
              });
            },
            onItemSelected: (value) {
              setState(() {
                selectedMenu = value;
              });
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    agendaTituloController.dispose();
    agendaDescricaoController.dispose();
    agendaObservacoesController.dispose();
    agendaDataController.dispose();
    agendaHoraInicioController.dispose();
    agendaHoraFimController.dispose();
    super.dispose();
  }

  Widget buildCampoVisualizacaoDashboard(String label, String? valor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            (valor == null || valor.trim().isEmpty) ? '-' : valor.trim(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (selectedMenu) {
      case 'chamados':
        return ChamadosPage(
          onChamadosAlterados: _carregarChamadosDashboard,
        );
      case 'tarefas':
        return TarefasPage(
          onTarefasAlteradas: () async {
            await carregarIndicadoresDashboard();
            if (!mounted) return;
            setState(() {
              dashboardCardSelecionado = 'tarefas';
            });
          },
        );

      case 'cronograma':
        return const CronogramaProjetoPage();

      case 'agenda':
        return const AgendaPage();

      case 'timeline':
        return const TimelinePage();

      case 'clientes':
        return const ClientesPage();

      case 'sipoc':
        return const SipocPage();

      case 'dashboard':
      default:
        if (carregandoDashboardReal) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bem-vindo ao Sistema de Consultoria da Enterdoc',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Painel inicial do sistema de gestão de consultoria e processos.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              setState(() {
                                dashboardCardSelecionado = 'chamados_mo';
                              });
                            },
                            child: _DashboardResumoCard(
                              title: 'Chamados M&O',
                              total: _totalChamadosEmAbertoCard().toString(),
                              subtitulo: 'Chamados em aberto para acompanhamento',
                              icon: Icons.assignment,
                              color: const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // ==== BLOCO 1 – NOVO CARD TAREFAS ====
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              setState(() {
                                dashboardCardSelecionado = 'tarefas';
                              });
                            },
                            child: _DashboardResumoCard(
                              title: 'Tarefas',
                              total: totalTarefasDia.toString(),
                              subtitulo: 'Tarefas do dia: $totalTarefasDia | Semana: $totalTarefasSemana',
                              icon: Icons.task_alt,
                              color: const Color(0xFF059669),
                            ),
                          ),
                        ),
                        // ==== FIM DO BLOCO 1 ====
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => setState(() => dashboardCardSelecionado = 'projetos'),
                            child: _DashboardResumoCard(
                              title: 'Projetos',
                              total: totalProjetosAtivos.toString(),
                              subtitulo: 'Clique para visualizar os detalhes abaixo',
                              icon: Icons.folder_open,
                              color: const Color(0xFF7C3AED),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const SizedBox(width: 16),
                        // ==== BLOCO 2 – NOVO CARD AGENDAS ====
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              setState(() {
                                dashboardCardSelecionado = 'agendas';
                              });
                            },
                            child: _DashboardResumoCard(
                              title: 'Agendas',
                              total: totalAgendasDia.toString(),
                              subtitulo: 'Clique para visualizar os detalhes abaixo',
                              icon: Icons.event_available,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                        // ==== FIM DO BLOCO 2 ====
                      ],
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),
                    if (dashboardCardSelecionado == 'chamados_mo')
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.insights_outlined,
                                  color: Color(0xFF374151),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Resumo de Chamados M&O por cliente',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'Visão geral',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4B5563),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Cada linha representa um cliente. Em seguida, vamos ligar os números aos relatórios clicáveis.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      color: const Color(0xFFF9FAFB),
                                      child: const Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'Cliente',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF374151),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Total',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF374151),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Em análise',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF374151),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Desenv.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF374151),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Testes',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF374151),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Atualizações',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF374151),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Fechado',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF374151),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ..._dashboardChamadosPorClienteMeuStatus.map((item) {
                                      final total = item['total'] as int? ?? 0;
                                      final emAnalise = item['emAnalise'] as int? ?? 0;
                                      final desenvolvimento = item['desenvolvimento'] as int? ?? 0;
                                      final testes = item['testes'] as int? ?? 0;
                                      final atualizacoes = item['atualizacoes'] as int? ?? 0;
                                      final fechado = item['fechado'] as int? ?? 0;

                                      return _DashboardLinhaCliente(
                                        cliente: item['cliente'].toString(),
                                        total: total.toString(),
                                        abertos: emAnalise.toString(),
                                        fechados: desenvolvimento.toString(),
                                        emAnalise: testes.toString(),
                                        desenvolvimento: atualizacoes.toString(),
                                        fechado: fechado.toString(),
                                        onTapNumero: (tipo) {
                                          _abrirRelatorioReal(
                                            cliente: item['cliente'].toString(),
                                            tipo: tipo,
                                          );
                                        },
                                      );
                                    }).toList(),
                                    _DashboardLinhaCliente(
                                      cliente: 'Total',
                                      total: chamadosDashboard.length.toString(),
                                      abertos: _montarResumoPorClienteMeuStatus()
                                          .fold<int>(0, (soma, linha) => soma + (linha['emAnalise'] as int? ?? 0))
                                          .toString(),
                                      fechados: _montarResumoPorClienteMeuStatus()
                                          .fold<int>(0, (soma, linha) => soma + (linha['desenvolvimento'] as int? ?? 0))
                                          .toString(),
                                      emAnalise: _montarResumoPorClienteMeuStatus()
                                          .fold<int>(0, (soma, linha) => soma + (linha['testes'] as int? ?? 0))
                                          .toString(),
                                      desenvolvimento: _montarResumoPorClienteMeuStatus()
                                          .fold<int>(0, (soma, linha) => soma + (linha['atualizacoes'] as int? ?? 0))
                                          .toString(),
                                      fechado: _montarResumoPorClienteMeuStatus()
                                          .fold<int>(0, (soma, linha) => soma + (linha['fechado'] as int? ?? 0))
                                          .toString(),
                                      destaqueTotal: true,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (dashboardCardSelecionado == 'tarefas')
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.task_alt,
                                  color: Color(0xFF059669),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Resumo de Tarefas',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'Visão rápida',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF065F46),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Acompanhe o volume de tarefas previstas para hoje e o total acumulado na semana.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0FDF4),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: const Color(0xFFD1FAE5),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Hoje',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF047857),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          totalTarefasDia.toString(),
                                          style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        const Text(
                                          'Tarefas planejadas para o dia atual.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Semana',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF374151),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          totalTarefasSemana.toString(),
                                          style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        const Text(
                                          'Total de tarefas encontradas na semana corrente.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Icon(
                                  Icons.view_list_outlined,
                                  size: 18,
                                  color: Color(0xFF374151),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Tarefas do dia',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${tarefasDoDiaDetalhadas.length} item(ns)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4B5563),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (tarefasDoDiaDetalhadas.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: const Text(
                                  'Nenhuma tarefa cadastrada para hoje.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              )
                            else
                              Column(
                                children: tarefasDoDiaDetalhadas.map((item) {
                                  final tarefa = item.tarefa;
                                  final clienteNome = item.clienteNome ?? 'Sem cliente';
                                  final horaInicio = tarefa.horaInicio.toString().trim().isEmpty
                                      ? '--:--'
                                      : tarefa.horaInicio.toString().trim();
                                  final horaFim = tarefa.horaFim.toString().trim().isEmpty
                                      ? '--:--'
                                      : tarefa.horaFim.toString().trim();

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => abrirDialogVisualizarTarefaDashboard(item),
                                    child: Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFB),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(0xFFE5E7EB),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFECFDF5),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.task_alt,
                                              color: Color(0xFF059669),
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  tarefa.titulo,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF111827),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  clienteNome,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(999),
                                                        border: Border.all(
                                                          color: const Color(0xFFE5E7EB),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Data: ${tarefa.data}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: Color(0xFF374151),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(999),
                                                        border: Border.all(
                                                          color: const Color(0xFFE5E7EB),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        '$horaInicio - $horaFim',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: Color(0xFF374151),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFEEF2FF),
                                                        borderRadius: BorderRadius.circular(999),
                                                      ),
                                                      child: Text(
                                                        tarefa.status,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w700,
                                                          color: Color(0xFF4338CA),
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
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      )
                      else if (dashboardCardSelecionado == 'projetos')
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.folder_open,
                                    color: Color(0xFF7C3AED),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Projetos ativos no cronograma',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F3FF),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'Ativos',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6D28D9),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Total de projetos ativos identificados: $totalProjetosAtivos.',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (projetosAtivosPorEmpresa.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: const Text(
                                    'Nenhum projeto ativo encontrado no cronograma.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                )
                              else
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                          color: const Color(0xFFF9FAFB),
                                          child: const Row(
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Text(
                                                  'Projeto',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF374151),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'Total',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF374151),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ...projetosAtivosPorEmpresa.map((item) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              border: Border(
                                                top: BorderSide(
                                                  color: Color(0xFFE5E7EB),
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Text(
                                                    item['empresa'].toString(),
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFF374151),
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    item['total'].toString(),
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF7C3AED),
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                        else if (dashboardCardSelecionado == 'agendas')
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.event_available,
                                      color: Color(0xFFF59E0B),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Resumo de agendas',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFBEB),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: const Text(
                                        'Compromissos manuais',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF92400E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Visualize os compromissos programados para hoje e amanhã.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFFBEB),
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(
                                            color: const Color(0xFFFDE68A),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Hoje',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF92400E),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              totalCompromissosHoje.toString(),
                                              style: const TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF111827),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            const Text(
                                              'Compromissos cadastrados para hoje.',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF9FAFB),
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(
                                            color: const Color(0xFFE5E7EB),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Amanhã',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF374151),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              totalCompromissosAmanha.toString(),
                                              style: const TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF111827),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            const Text(
                                              'Compromissos previstos para o próximo dia.',
                                              style: TextStyle(
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
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.today_outlined,
                                      size: 18,
                                      color: Color(0xFF374151),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Agendas de hoje',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        '${agendasHojeDetalhadas.length} item(ns)',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF4B5563),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                if (agendasHojeDetalhadas.isEmpty)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: const Text(
                                      'Nenhuma agenda cadastrada para hoje.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  )
                                else
                                  Column(
                                    children: agendasHojeDetalhadas.map((agenda) {
                                      final horaInicio = (agenda.horaInicio ?? '').toString().trim().isEmpty
                                          ? '--:--'
                                          : agenda.horaInicio.toString().trim();
                                      final horaFim = (agenda.horaFim ?? '').toString().trim().isEmpty
                                          ? '--:--'
                                          : agenda.horaFim.toString().trim();

                                      return InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: () => abrirDialogEditarAgendaDashboard(agenda),
                                        child: Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(bottom: 12),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFFBEB),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: const Color(0xFFFDE68A),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 42,
                                                height: 42,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFEF3C7),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: const Icon(
                                                  Icons.event_note_outlined,
                                                  color: Color(0xFFD97706),
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      agenda.titulo,
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w700,
                                                        color: Color(0xFF111827),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      (agenda.descricao ?? '').toString().trim().isEmpty
                                                          ? 'Sem descrição'
                                                          : agenda.descricao.toString().trim(),
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Color(0xFF6B7280),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Wrap(
                                                      spacing: 8,
                                                      runSpacing: 8,
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(999),
                                                            border: Border.all(
                                                              color: const Color(0xFFE5E7EB),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            'Data: ${agenda.data}',
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w600,
                                                              color: Color(0xFF374151),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(999),
                                                            border: Border.all(
                                                              color: const Color(0xFFE5E7EB),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            '$horaInicio - $horaFim',
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w600,
                                                              color: Color(0xFF374151),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFFFEF3C7),
                                                            borderRadius: BorderRadius.circular(999),
                                                          ),
                                                          child: Text(
                                                            agenda.status,
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w700,
                                                              color: Color(0xFFB45309),
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
                                      );
                                    }).toList(),
                                  ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.update_outlined,
                                      size: 18,
                                      color: Color(0xFF374151),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Agendas de amanhã',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        '${agendasAmanhaDetalhadas.length + tarefasAmanhaDetalhadas.length} item(ns)',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF4B5563),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                if (agendasAmanhaDetalhadas.isEmpty && tarefasAmanhaDetalhadas.isEmpty)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: const Text(
                                      'Nenhuma agenda cadastrada para amanhã.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  )
                                else
                                  Column(
                                    children: [
                                      ...agendasAmanhaDetalhadas.map((agenda) {
                                        final horaInicio = (agenda.horaInicio ?? '').toString().trim().isEmpty
                                            ? '--:--'
                                            : agenda.horaInicio.toString().trim();
                                        final horaFim = (agenda.horaFim ?? '').toString().trim().isEmpty
                                            ? '--:--'
                                            : agenda.horaFim.toString().trim();

                                        return InkWell(
                                          borderRadius: BorderRadius.circular(16),
                                          onTap: () => abrirDialogEditarAgendaDashboard(agenda),
                                          child: Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.only(bottom: 12),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFFBEB),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: const Color(0xFFFDE68A)),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 42,
                                                  height: 42,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFEF3C7),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: const Icon(
                                                    Icons.event_note_outlined,
                                                    color: Color(0xFFD97706),
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 14),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        agenda.titulo,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w700,
                                                          color: Color(0xFF111827),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        agenda.descricao?.toString().trim().isEmpty ?? true
                                                            ? 'Sem descrição'
                                                            : agenda.descricao.toString().trim(),
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          color: Color(0xFF6B7280),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Wrap(
                                                        spacing: 8,
                                                        runSpacing: 8,
                                                        children: [
                                                          _buildChipAgenda('Data: ${agenda.data}'),
                                                          _buildChipAgenda('$horaInicio - $horaFim'),
                                                          _buildChipAgenda(agenda.status, destaque: true),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                      ...tarefasAmanhaDetalhadas.map((item) {
                                        final tarefa = item.tarefa;
                                        final clienteNome = item.clienteNome ?? 'Sem cliente';
                                        final horaInicio = tarefa.horaInicio.toString().trim().isEmpty
                                            ? '--:--'
                                            : tarefa.horaInicio.toString().trim();
                                        final horaFim = tarefa.horaFim.toString().trim().isEmpty
                                            ? '--:--'
                                            : tarefa.horaFim.toString().trim();

                                        return InkWell(
                                          borderRadius: BorderRadius.circular(16),
                                          onTap: () => abrirDialogVisualizarTarefaDashboard(item),
                                          child: Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.only(bottom: 12),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF0FDF4),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: const Color(0xFFD1FAE5)),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 42,
                                                  height: 42,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFDCFCE7),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: const Icon(
                                                    Icons.task_alt,
                                                    color: Color(0xFF059669),
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 14),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        tarefa.titulo,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w700,
                                                          color: Color(0xFF111827),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        clienteNome,
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          color: Color(0xFF6B7280),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Wrap(
                                                        spacing: 8,
                                                        runSpacing: 8,
                                                        children: [
                                                          _buildChipAgenda('Data: ${tarefa.data}'),
                                                          _buildChipAgenda('$horaInicio - $horaFim'),
                                                          _buildChipAgenda(tarefa.status, destaque: true),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  )
                              ],
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Color(0xFF374151),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Módulo em construção',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Este módulo ainda será configurado. Selecione "Chamados M&O" para ver o detalhamento por cliente.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        );
    }
  }

  List<Map<String, String>> _gerarRelatorioFake({
    required String cliente,
    required String tipo,
    required int quantidade,
  }) {
    return List.generate(quantidade, (index) {
      return {
        'numero': 'CH-${1000 + index}',
        'cliente': cliente,
        'assunto': 'Ajuste no processo ${index + 1}',
        'tipoMelhoria': tipo,
        'descricao': 'Detalhamento do chamado ${index + 1}',
        'ro': 'RO-${200 + index}',
        'tipo': 'Melhoria',
        'meuStatus': tipo == 'Fechados' ? 'Fechado' : 'Em análise',
        'dataAbertura': '18/04/2026',
        'prazoEntrega': '25/04/2026',
        'numeroRo': 'RO-${200 + index}',
        'statusSistema': tipo == 'Fechados' ? 'Concluído' : 'Em andamento',
        'statusChamado': tipo == 'Fechados' ? 'Fechado' : 'Aberto',
        'tipoLiberacao': 'Sprint',
        'anotacoes': 'Registro gerado para visualização do dashboard',
      };
    });
  }

  Future<void> _abrirRelatorioReal({
    required String cliente,
    required String tipo,
  }) async {
    final relatorio = _filtrarChamadosRelatorio(
      cliente: cliente,
      tipo: tipo,
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 1200,
            constraints: const BoxConstraints(
              maxWidth: 1200,
              maxHeight: 760,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.assignment, color: Color(0xFFDC2626)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Relatório de $tipo - $cliente',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    Text(
                      '${relatorio.length} registros',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: relatorio.isEmpty
                      ? const Center(
                    child: Text(
                      'Nenhum registro encontrado.',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  )
                      : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFFF3F4F6),
                        ),
                        columns: const [
                          DataColumn(label: Text('Número do Chamado')),
                          DataColumn(label: Text('Cliente')),
                          DataColumn(label: Text('Solicitante')),
                          DataColumn(label: Text('Assunto')),
                          DataColumn(label: Text('Categoria')),
                          DataColumn(label: Text('Status Sistema')),
                          DataColumn(label: Text('Serviço')),
                          DataColumn(label: Text('Data abertura')),
                          DataColumn(label: Text('Última atualização')),
                          DataColumn(label: Text('Agente atual')),
                          DataColumn(label: Text('Equipe atual')),
                          DataColumn(label: Text('Meu Status')),
                          DataColumn(label: Text('Anotações')),
                          DataColumn(label: Text('Anexos')),
                        ],
                        rows: relatorio.map((chamado) {
                          return DataRow(
                            cells: [
                              DataCell(Text(chamado.ticket)),
                              DataCell(Text(chamado.cliente)),
                              DataCell(Text(chamado.solicitante)),
                              DataCell(Text(chamado.assunto)),
                              DataCell(Text(chamado.categoria)),
                              DataCell(Text(chamado.status)),
                              DataCell(Text(chamado.servico)),
                              DataCell(Text(chamado.dataAbertura)),
                              DataCell(Text(chamado.ultimaAtualizacao)),
                              DataCell(Text(chamado.agenteAtual)),
                              DataCell(Text(chamado.equipeAtual)),
                              DataCell(Text(chamado.meuStatus)),
                              DataCell(Text(chamado.anotacoes)),
                              DataCell(
                                Text(
                                  chamado.anexos.isEmpty
                                      ? ''
                                      : chamado.anexos.join(', '),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close),
                      label: const Text('Fechar'),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _exportarRelatorioRealExcel(
                          cliente: cliente,
                          tipo: tipo,
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Exportar Excel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportarRelatorioRealExcel({
    required String cliente,
    required String tipo,
  }) async {
    try {
      final relatorio = _filtrarChamadosRelatorio(
        cliente: cliente,
        tipo: tipo,
      );

      final excel = Excel.createExcel();
      final Sheet sheet = excel['Relatorio'];

      final cabecalhos = [
        'Numero do Chamado',
        'Cliente',
        'Solicitante',
        'Assunto',
        'Categoria',
        'Status Sistema',
        'Serviço',
        'Data abertura',
        'Última atualização',
        'Agente atual',
        'Equipe atual',
        'Meu Status',
        'Anotações',
        'Anexos',
      ];

      for (var i = 0; i < cabecalhos.length; i++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .value = TextCellValue(cabecalhos[i]);
      }

      for (var i = 0; i < relatorio.length; i++) {
        final chamado = relatorio[i];

        final linha = [
          chamado.ticket,
          chamado.cliente,
          chamado.solicitante,
          chamado.assunto,
          chamado.categoria,
          chamado.status,
          chamado.servico,
          chamado.dataAbertura,
          chamado.ultimaAtualizacao,
          chamado.agenteAtual,
          chamado.equipeAtual,
          chamado.meuStatus,
          chamado.anotacoes,
          chamado.anexos.join(', '),
        ];

        for (var j = 0; j < linha.length; j++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
              .value = TextCellValue(linha[j]);
        }
      }

      final bytes = excel.encode();
      if (bytes == null) {
        throw Exception('Não foi possível gerar o arquivo Excel.');
      }

      final nomeArquivo =
          'relatorio_${cliente.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}_${tipo.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      String caminhoBase;

      if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'];

        if (userProfile == null || userProfile.isEmpty) {
          throw Exception('Não foi possível localizar a pasta do usuário no Windows.');
        }

        final desktopPath = '$userProfile\\Desktop';
        final desktopDir = Directory(desktopPath);

        if (!desktopDir.existsSync()) {
          throw Exception('A pasta Desktop não foi encontrada: $desktopPath');
        }

        caminhoBase = desktopPath;
      } else {
        final diretorio = await getApplicationDocumentsDirectory();
        caminhoBase = diretorio.path;
      }

      final arquivo = File('$caminhoBase\\$nomeArquivo');
      await arquivo.writeAsBytes(bytes, flush: true);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel exportado com sucesso: ${arquivo.path}'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao exportar Excel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}



class _DashboardResumoCard extends StatelessWidget {
  final String title;
  final String total;
  final String subtitulo;
  final IconData icon;
  final Color color;

  const _DashboardResumoCard({
    required this.title,
    required this.total,
    required this.subtitulo,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Text(
            total,
            style: const TextStyle(
              fontSize: 32,
              height: 1,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitulo,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              height: 1.35,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DashboardLinhaCliente extends StatelessWidget {
  final String cliente;
  final String total;
  final String abertos;
  final String fechados;
  final String emAnalise;
  final String desenvolvimento;
  final String fechado;
  final bool destaqueTotal;
  final void Function(String tipo)? onTapNumero;

  const _DashboardLinhaCliente({
    required this.cliente,
    required this.total,
    required this.abertos,
    required this.fechados,
    required this.emAnalise,
    required this.desenvolvimento,
    required this.fechado,
    this.destaqueTotal = false,
    this.onTapNumero,
  });

  Widget _buildNumero(String valor, String tipo) {
    final clicavel = !destaqueTotal && onTapNumero != null;

    if (!clicavel) {
      return Text(
        valor,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: destaqueTotal
              ? const Color(0xFF111827)
              : const Color(0xFF2563EB),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      );
    }

    return InkWell(
      onTap: () => onTapNumero!(tipo),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          valor,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.bold,
            fontSize: 13,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: destaqueTotal ? const Color(0xFFF9FAFB) : Colors.white,
        border: const Border(
          top: BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              cliente,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: destaqueTotal
                    ? const Color(0xFF111827)
                    : const Color(0xFF374151),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(child: _buildNumero(total, 'total')),
          Expanded(child: _buildNumero(abertos, 'em analise')),
          Expanded(child: _buildNumero(fechados, 'desenvolvimento')),
          Expanded(child: _buildNumero(emAnalise, 'testes')),
          Expanded(child: _buildNumero(desenvolvimento, 'atualizacoes')),
          Expanded(child: _buildNumero(fechado, 'fechado')),
        ],
      ),
    );
  }
}