import 'package:flutter/material.dart';

import '../data/agenda_manual_repository.dart';
import '../domain/agenda_manual.dart';
import '../../tarefas/data/tarefa_repository.dart';
import '../../tarefas/domain/tarefa_detalhe.dart';
import '../../cronograma/data/cronograma_repository.dart';
import '../../cronograma/domain/cronograma_models.dart';
import '../../clientes/data/cliente_repository.dart';
import '../../clientes/domain/cliente.dart';



class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  DateTime semanaBase = DateTime.now();
  final AgendaManualRepository agendaManualRepository = AgendaManualRepository();
  final TarefaRepository tarefaRepository = TarefaRepository();
  final CronogramaRepository cronogramaRepository = CronogramaRepository();
  List<Map<String, dynamic>> itensAgendaSemana = [];
  final ClienteRepository clienteRepository = ClienteRepository();
  Map<int, Cliente> clientesRecorrentesSemana = {};


  final TextEditingController tituloController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController observacoesController = TextEditingController();

  final TextEditingController dataController = TextEditingController();
  final TextEditingController horaInicioController = TextEditingController();
  final TextEditingController horaFimController = TextEditingController();
  final TextEditingController vinculoIdController = TextEditingController();

  String statusSelecionado = 'Planejada';
  String corSelecionada = '#DBEAFE';
  bool carregandoAgenda = false;

  AgendaManual? agendaSelecionada;

  @override
  void initState() {
    super.initState();
    carregarAgendaSemana();
  }

  DateTime get inicioDaSemana {
    final data = DateTime(semanaBase.year, semanaBase.month, semanaBase.day);
    final diferenca = data.weekday - DateTime.monday;
    return data.subtract(Duration(days: diferenca));
  }

  String tipoVinculoSelecionado = 'geral';
  int? vinculoIdSelecionado;


  List<DateTime> get diasDaSemana {
    return List.generate(7, (index) {
      return inicioDaSemana.add(Duration(days: index));
    });
  }

  List<String> get horarios {
    return List.generate(15, (index) {
      final hora = 7 + index;
      return '${hora.toString().padLeft(2, '0')}:00';
    });
  }

  String formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  String _formatarDataParaFormulario(String valor) {
    final texto = valor.trim();
    if (texto.isEmpty) return '';

    final dataIso = DateTime.tryParse(texto);
    if (dataIso != null) {
      return formatarData(dataIso);
    }

    final dataBr = parseDataBrString(texto);
    if (dataBr != null) {
      return formatarData(dataBr);
    }

    return texto;
  }

  final List<Map<String, String>> coresAgendaDisponiveis = const [
    {'label': 'Azul', 'valor': '#DBEAFE'},
    {'label': 'Verde', 'valor': '#DCFCE7'},
    {'label': 'Amarelo', 'valor': '#FEF3C7'},
    {'label': 'Vermelho', 'valor': '#FEE2E2'},
    {'label': 'Roxo', 'valor': '#EDE9FE'},
    {'label': 'Cinza', 'valor': '#E5E7EB'},
  ];


  DateTime? parseDataBrString(String valor) {
    try {
      final texto = valor.trim();
      if (texto.isEmpty) return null;

      final normalizado = texto.replaceAll('-', '/');
      final partes = normalizado.split('/');
      if (partes.length != 3) return null;

      final dia = int.tryParse(partes[0]);
      final mes = int.tryParse(partes[1]);
      final ano = int.tryParse(partes[2]);

      if (dia == null || mes == null || ano == null) return null;

      final data = DateTime(ano, mes, dia);

      if (data.year != ano || data.month != mes || data.day != dia) {
        return null;
      }

      return data;
    } catch (_) {
      return null;
    }
  }

  String _formatarDataBanco(DateTime data) {
    final ano = data.year.toString().padLeft(4, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final dia = data.day.toString().padLeft(2, '0');
    return '$ano-$mes-$dia';
  }

  DateTime? _parseDataAgendaItem(String valor) {
    final texto = valor.trim();
    if (texto.isEmpty) return null;

    final dataIso = DateTime.tryParse(texto);
    if (dataIso != null) {
      return DateTime(dataIso.year, dataIso.month, dataIso.day);
    }

    final dataBr = parseDataBrString(texto);
    if (dataBr != null) {
      return DateTime(dataBr.year, dataBr.month, dataBr.day);
    }

    return null;
  }

  bool _horaValida(String valor) {
    final texto = valor.trim();
    if (texto.isEmpty) return true;

    final partes = texto.split(':');
    if (partes.length != 2) return false;

    final hora = int.tryParse(partes[0]);
    final minuto = int.tryParse(partes[1]);

    if (hora == null || minuto == null) return false;
    if (hora < 0 || hora > 23) return false;
    if (minuto < 0 || minuto > 59) return false;

    return true;
  }



  Map<String, Color> _coresStatusAgenda(String status) {
    switch (status) {
      case 'Em andamento':
        return {
          'fundo': const Color(0xFFFEF3C7),
          'texto': const Color(0xFFB45309),
        };
      case 'Concluída':
        return {
          'fundo': const Color(0xFFD1FAE5),
          'texto': const Color(0xFF047857),
        };
      case 'Cancelada':
        return {
          'fundo': const Color(0xFFFEE2E2),
          'texto': const Color(0xFFB91C1C),
        };
      case 'Planejada':
      default:
        return {
          'fundo': const Color(0xFFDBEAFE),
          'texto': const Color(0xFF1D4ED8),
        };
    }

  }

  Color corHexParaColor(String? hex, {Color fallback = const Color(0xFFDBEAFE)}) {
    if (hex == null || hex.trim().isEmpty) return fallback;

    var valor = hex.trim().replaceAll('#', '').toUpperCase();

    if (valor.length == 6) {
      valor = 'FF$valor';
    }

    if (valor.length != 8) return fallback;

    try {
      return Color(int.parse(valor, radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  bool _tarefaDeveEntrarNaAgenda(TarefaDetalhe item) {
    final origemTipo = (item.tarefa.origemTipo ?? '').trim().toLowerCase();

    if (origemTipo == 'cronograma') {
      return item.tarefa.origemId != null;
    }

    if (origemTipo == 'chamado') {
      return (item.tarefa.chamadoRef ?? '').trim().isNotEmpty;
    }

    return false;
  }

   Future<void> carregarClientesRecorrentesSemana() async {
    final clientes = await clienteRepository.listarClientes();
    final Map<int, Cliente> mapa = {};

    for (final cliente in clientes) {
      for (final dia in cliente.diasAtendimentoList) {
        mapa[dia] = cliente;
      }
    }

    clientesRecorrentesSemana = mapa;
  }

  String _subtituloTarefaAgenda(TarefaDetalhe item) {
    final origemTipo = (item.tarefa.origemTipo ?? '').trim().toLowerCase();

    if (origemTipo == 'cronograma') {
      final projeto = (item.tarefa.projetoRef ?? '').trim();
      if (projeto.isNotEmpty) return projeto;
      return item.clienteNome ?? 'Cronograma';
    }

    if (origemTipo == 'chamado') {
      final chamado = (item.tarefa.chamadoRef ?? '').trim();
      if (chamado.isNotEmpty) return 'Chamado $chamado';
      return item.clienteNome ?? 'Chamado';
    }

    return item.clienteNome ?? 'Sem cliente';
  }

  Future<void> abrirDialogEditarAgenda(AgendaManual item) async {
    agendaSelecionada = item;

    tituloController.text = item.titulo;
    descricaoController.text = item.descricao;
    observacoesController.text = item.observacoes;
    dataController.text = _formatarDataParaFormulario(item.data);
    horaInicioController.text = item.horaInicio ?? '';
    horaFimController.text = item.horaFim ?? '';
    statusSelecionado = item.status;
    corSelecionada = item.cor ?? '#DBEAFE';
    tipoVinculoSelecionado = item.tipoVinculo;
    vinculoIdSelecionado = item.vinculoId;
    vinculoIdController.text = item.vinculoId?.toString() ?? '';

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        String statusDialog = statusSelecionado;

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
                            children: const [
                              Text(
                                'Editar agenda',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
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
                            _buildTextFieldAgenda(
                              controller: tituloController,
                              label: 'Título',
                              hint: 'Ex: Reunião de alinhamento',
                            ),
                            const SizedBox(height: 16),
                            _buildTextFieldAgenda(
                              controller: descricaoController,
                              label: 'Descrição',
                              hint: 'Descreva o compromisso',
                              maxLines: 4,
                              required: false,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextFieldAgenda(
                                    controller: dataController,
                                    label: 'Data',
                                    hint: 'Ex: 08/05/2026',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextFieldAgenda(
                                    controller: horaInicioController,
                                    label: 'Hora início',
                                    hint: 'Ex: 09:00',
                                    required: false,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextFieldAgenda(
                                    controller: horaFimController,
                                    label: 'Hora fim',
                                    hint: 'Ex: 10:00',
                                    required: false,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField(
                              value: statusDialog,
                              decoration: _buildInputDecorationAgenda(
                                label: 'Status',
                                hint: 'Selecione o status',
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Planejada', child: Text('Planejada')),
                                DropdownMenuItem(value: 'Em andamento', child: Text('Em andamento')),
                                DropdownMenuItem(value: 'Concluída', child: Text('Concluída')),
                                DropdownMenuItem(value: 'Cancelada', child: Text('Cancelada')),
                              ],
                              onChanged: (value) {
                                dialogSetState(() {
                                  statusDialog = value ?? 'Planejada';
                                });
                                statusSelecionado = value ?? 'Planejada';
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildSeletorCorAgenda(dialogSetState),
                            const SizedBox(height: 16),
                            _buildTextFieldAgenda(
                              controller: observacoesController,
                              label: 'Observações',
                              hint: 'Anotações rápidas',
                              required: false,
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
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            Navigator.of(dialogContext).pop();
                            await excluirAgendaManual(item);
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Excluir'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(color: Color(0xFFDC2626)),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (agendaSelecionada == null) return;

                            final titulo = tituloController.text.trim();
                            final dataTexto = dataController.text.trim();
                            final horaInicio = horaInicioController.text.trim();
                            final horaFim = horaFimController.text.trim();

                            if (titulo.isEmpty || dataTexto.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Título e data são obrigatórios.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final data = parseDataBrString(dataTexto);
                            if (data == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Data inválida. Use o formato DD/MM/AAAA.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (!_horaValida(horaInicio) || !_horaValida(horaFim)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Hora inválida. Use o formato HH:MM.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            try {
                              final atualizado = agendaSelecionada!.copyWith(
                                titulo: titulo,
                                descricao: descricaoController.text.trim(),
                                observacoes: observacoesController.text.trim(),
                                data: _formatarDataBanco(data),
                                horaInicio: horaInicio.isEmpty ? null : horaInicio,
                                horaFim: horaFim.isEmpty ? null : horaFim,
                                status: statusSelecionado,
                                cor: corSelecionada,
                                updatedAt: DateTime.now().toIso8601String(),
                              );

                              await agendaManualRepository.atualizar(atualizado);
                              await carregarAgendaSemana();


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

  Future<void> abrirDialogVisualizarTarefa(dynamic itemTarefa) async {
    final tarefa = itemTarefa.tarefa;
    final clienteNome = itemTarefa.clienteNome ?? 'Sem cliente';

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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
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
                            'Visualização da tarefa carregada na agenda semanal.',
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
                        _buildCampoVisualizacao(
                          'Título',
                          tarefa.titulo,
                        ),
                        const SizedBox(height: 16),
                        _buildCampoVisualizacao(
                          'Cliente',
                          clienteNome,
                        ),
                        const SizedBox(height: 16),
                        _buildCampoVisualizacao(
                          'Data',
                          tarefa.data,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildCampoVisualizacao(
                                'Hora início',
                                tarefa.horaInicio,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildCampoVisualizacao(
                                'Hora fim',
                                tarefa.horaFim,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCampoVisualizacao(
                          'Status',
                          tarefa.status,
                        ),
                        const SizedBox(height: 16),
                        _buildCampoVisualizacao(
                          'Descrição',
                          (tarefa.descricao ?? '').toString().isEmpty
                              ? '-'
                              : tarefa.descricao,
                        ),
                        const SizedBox(height: 16),
                        _buildCampoVisualizacao(
                          'Observações',
                          (tarefa.observacoes ?? '').toString().isEmpty
                              ? '-'
                              : tarefa.observacoes,
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

  Future<bool> salvarAgendaManual() async {
    final titulo = tituloController.text.trim();
    final dataTexto = dataController.text.trim();
    final horaInicio = horaInicioController.text.trim();
    final horaFim = horaFimController.text.trim();

    if (titulo.isEmpty || dataTexto.isEmpty) {
      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Título e data são obrigatórios.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final data = parseDataBrString(dataTexto);
    if (data == null) {
      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data inválida. Use o formato DD/MM/AAAA.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (!_horaValida(horaInicio) || !_horaValida(horaFim)) {
      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hora inválida. Use o formato HH:MM.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    try {
      final agora = DateTime.now().toIso8601String();

      final agenda = AgendaManual(
        id: agendaSelecionada?.id,
        titulo: tituloController.text.trim(),
        descricao: descricaoController.text.trim(),
        observacoes: observacoesController.text.trim(),
        data: _formatarDataBanco(data),
        horaInicio: horaInicioController.text.trim().isEmpty
            ? null
            : horaInicioController.text.trim(),
        horaFim: horaFimController.text.trim().isEmpty
            ? null
            : horaFimController.text.trim(),
        status: statusSelecionado,
        cor: corSelecionada,
        tipoVinculo: tipoVinculoSelecionado,
        vinculoId: tipoVinculoSelecionado == 'geral'
            ? null
            : int.tryParse(vinculoIdController.text.trim()),
        createdAt: agendaSelecionada?.createdAt ?? DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      await agendaManualRepository.inserir(agenda);
      await carregarAgendaSemana();

      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agenda salva com sucesso!'),
          backgroundColor: Color(0xFF059669),
        ),
      );

      return true;
    } catch (e) {
      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar agenda: $e'),
          backgroundColor: Colors.red,
        ),
      );

      return false;
    }
  }

  Future<void> abrirDialogNovaAgenda() async {
    limparFormularioAgenda();

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        String statusDialog = statusSelecionado;

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
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.calendar_month_outlined,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Nova agenda',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Cadastre um compromisso manual na agenda semanal.',
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
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            statusDialog,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1D4ED8),
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
                            _buildTextFieldAgenda(
                              controller: tituloController,
                              label: 'Título',
                              hint: 'Ex: Reunião de alinhamento',
                            ),
                            const SizedBox(height: 16),
                            _buildTextFieldAgenda(
                              controller: descricaoController,
                              label: 'Descrição',
                              hint: 'Descreva o compromisso',
                              maxLines: 4,
                              required: false,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextFieldAgenda(
                                    controller: dataController,
                                    label: 'Data',
                                    hint: 'Ex: 08/05/2026',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextFieldAgenda(
                                    controller: horaInicioController,
                                    label: 'Hora início',
                                    hint: 'Ex: 09:00',
                                    required: false,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextFieldAgenda(
                                    controller: horaFimController,
                                    label: 'Hora fim',
                                    hint: 'Ex: 10:00',
                                    required: false,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: statusDialog,
                              decoration: _buildInputDecorationAgenda(
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
                                });
                                statusSelecionado = value ?? 'Planejada';
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: tipoVinculoSelecionado,
                              decoration: _buildInputDecorationAgenda(
                                label: 'Vínculo',
                                hint: 'Selecione o tipo de vínculo',
                              ),
                              items: const [
                                DropdownMenuItem(value: 'geral', child: Text('Geral')),
                                DropdownMenuItem(value: 'projeto', child: Text('Projeto')),
                                DropdownMenuItem(value: 'chamado', child: Text('Chamado')),
                              ],
                              onChanged: (value) {
                                dialogSetState(() {
                                  tipoVinculoSelecionado = value ?? 'geral';
                                  if (tipoVinculoSelecionado == 'geral') {
                                    vinculoIdSelecionado = null;
                                    vinculoIdController.clear();
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextFieldAgenda(
                              controller: vinculoIdController,
                              label: 'ID do vínculo',
                              hint: 'Ex: id do projeto ou id do chamado',
                              required: tipoVinculoSelecionado != 'geral',
                              onChanged: (valor) {
                                vinculoIdSelecionado = int.tryParse(valor.trim());
                              },
                            ),

                            const SizedBox(height: 16),
                            _buildSeletorCorAgenda(dialogSetState),
                            const SizedBox(height: 16),
                            _buildTextFieldAgenda(
                              controller: observacoesController,
                              label: 'Observações',
                              hint: 'Anotações rápidas',
                              required: false,
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
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            dialogSetState(() {
                              limparFormularioAgenda();
                              statusDialog = 'Planejada';
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Limpar'),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final salvou = await salvarAgendaManual();

                            if (!mounted) return;
                            if (!salvou) return;

                            Navigator.of(dialogContext).pop();
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Salvar agenda'),
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

  InputDecoration _buildInputDecorationAgenda({
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

  Widget _buildCampoVisualizacao(String label, String? valor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
            (valor ?? '').trim().isEmpty ? '-' : valor!.trim(),
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

  Widget _buildSeletorCorAgenda(StateSetter dialogSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Cor da agenda',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: coresAgendaDisponiveis.map((item) {
            final valor = item['valor']!;
            final selecionada = corSelecionada == valor;
            final cor = corHexParaColor(valor);

            return InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () {
                dialogSetState(() {
                  corSelecionada = valor;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selecionada
                        ? const Color(0xFF111827)
                        : cor.withOpacity(0.95),
                    width: selecionada ? 1.6 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: cor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.9)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item['label']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextFieldAgenda({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    bool required = true,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: _buildInputDecorationAgenda(
        label: label,
        hint: hint,
      ),
    );
  }

  Future<void> excluirAgendaManual(AgendaManual item) async {
    if (item.id == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir agenda'),
          content: Text(
            'Deseja realmente excluir o compromisso "${item.titulo}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
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
      await agendaManualRepository.excluir(item.id!);
      await carregarAgendaSemana();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agenda excluída com sucesso!'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir agenda: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> carregarAgendaSemana() async {
    setState(() {
      carregandoAgenda = true;
    });

    try {
      await carregarClientesRecorrentesSemana();

      final inicio = inicioDaSemana;
      final fim = inicio.add(const Duration(days: 6));

      final List<Map<String, dynamic>> itens = [];

      final agendas = await agendaManualRepository.listarPorPeriodo(
        dataInicial: _formatarDataBanco(inicio),
        dataFinal: _formatarDataBanco(fim),
      );

      for (final item in agendas) {
        final data = _parseDataAgendaItem(item.data);
        if (data == null) continue;

        final dataNormalizada = DateTime(data.year, data.month, data.day);
        final cores = _coresStatusAgenda(item.status);

        itens.add({
          'tipo': 'agenda_manual',
          'origem': 'manual',
          'id': item.id,
          'dia': dataNormalizada,
          'hora': item.horaInicio ?? '',
          'horaFim': item.horaFim ?? '',
          'titulo': item.titulo,
          'descricao': item.descricao,
          'observacoes': item.observacoes,
          'status': item.status,
          'cor': cores['fundo'],
          'corTexto': cores['texto'],
          'objeto': item,
        });
      }

      final tarefas = await tarefaRepository.listarTarefasComCliente();

      final tarefasFiltradas = tarefas.where((item) {
        if (!_tarefaDeveEntrarNaAgenda(item)) return false;

        final data = parseDataBrString(item.tarefa.data);
        if (data == null) return false;

        final dataNormalizada = DateTime(data.year, data.month, data.day);
        final inicioNormalizado = DateTime(inicio.year, inicio.month, inicio.day);
        final fimNormalizado = DateTime(fim.year, fim.month, fim.day);

        return !dataNormalizada.isBefore(inicioNormalizado) &&
            !dataNormalizada.isAfter(fimNormalizado);
      });

      for (final item in tarefasFiltradas) {
        final status = item.tarefa.status.trim().toLowerCase();
        if (status == 'concluída' || status == 'concluida') continue;

        final data = parseDataBrString(item.tarefa.data);
        if (data == null) continue;

        final corCliente = corHexParaColor(
          item.clienteCor,
          fallback: const Color(0xFF2563EB),
        );

        itens.add({
          'tipo': 'tarefa',
          'origem': 'tarefa',
          'dia': data,
          'hora': item.tarefa.horaInicio.trim().isEmpty ? '07:00' : item.tarefa.horaInicio.trim(),
          'titulo': item.tarefa.titulo,
          'subtitulo': _subtituloTarefaAgenda(item),
          'status': item.tarefa.status,
          'clienteNome': item.clienteNome,
          'clienteLogoPath': item.clienteLogoPath,
          'clienteCor': item.clienteCor,
          'cor': corCliente.withOpacity(0.28),
          'corTexto': corCliente.withOpacity(0.95),
          'objeto': item,
        });
      }

      final cronogramas = await cronogramaRepository.listarCronogramas();
      print('cronogramas carregados: ${cronogramas.length}');

      for (final projeto in cronogramas) {
        for (final item in projeto.itens) {
          if (item.status.trim().toLowerCase() == 'concluída' ||
              item.status.trim().toLowerCase() == 'concluida') {
            continue;
          }

          if (item.dataInicio == null) continue;

          final data = DateTime(
            item.dataInicio!.year,
            item.dataInicio!.month,
            item.dataInicio!.day,
          );

          final inicioNormalizado = DateTime(
            inicio.year,
            inicio.month,
            inicio.day,
          );

          final fimNormalizado = DateTime(
            fim.year,
            fim.month,
            fim.day,
          );

          final dentroDaSemana =
              !data.isBefore(inicioNormalizado) &&
                  !data.isAfter(fimNormalizado);

          if (!dentroDaSemana) continue;

          final corClienteCronograma = corHexParaColor(
            projeto.clienteCor,
            fallback: const Color(0xFFFDE68A),
          );

          itens.add({
            'tipo': 'cronograma',
            'origem': 'cronograma',
            'dia': data,
            'hora': 'ALLDAY',
            'titulo': item.atividade,
            'subtitulo': projeto.clienteNome ?? projeto.nomeProjeto,
            'status': item.status,
            'clienteNome': projeto.clienteNome,
            'clienteLogoPath': projeto.clienteLogoPath,
            'clienteCor': projeto.clienteCor,
            'cor': corClienteCronograma.withOpacity(0.28),
            'corTexto': corClienteCronograma.withOpacity(0.95),
            'objeto': item,
          });
        }
      }

      itens.sort((a, b) {
        final diaA = a['dia'] as DateTime;
        final diaB = b['dia'] as DateTime;
        final comparacaoData = diaA.compareTo(diaB);
        if (comparacaoData != 0) return comparacaoData;

        final horaA = (a['hora'] ?? '').toString();
        final horaB = (b['hora'] ?? '').toString();
        return horaA.compareTo(horaB);
      });

      if (!mounted) return;

      setState(() {
        itensAgendaSemana = itens;
        carregandoAgenda = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregandoAgenda = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar agenda: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _nomeDiaSemana(DateTime data) {
    const dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return dias[data.weekday - 1];
  }

  String _faixaSemana() {
    final inicio = inicioDaSemana;
    final fim = inicio.add(const Duration(days: 6));
    return '${inicio.day.toString().padLeft(2, '0')}/${inicio.month.toString().padLeft(2, '0')} '
        'até ${fim.day.toString().padLeft(2, '0')}/${fim.month.toString().padLeft(2, '0')}';
  }

  void _irSemanaAnterior() {
    setState(() {
      semanaBase = semanaBase.subtract(const Duration(days: 7));
    });

    carregarAgendaSemana();
  }

  void limparFormularioAgenda() {
    tituloController.clear();
    descricaoController.clear();
    observacoesController.clear();
    dataController.clear();
    horaInicioController.clear();
    horaFimController.clear();
    vinculoIdController.clear();
    statusSelecionado = 'Planejada';
    corSelecionada = '#DBEAFE';
    tipoVinculoSelecionado = 'geral';
    vinculoIdSelecionado = null;
  }



  void _irProximaSemana() {
    setState(() {
      semanaBase = semanaBase.add(const Duration(days: 7));
    });

    carregarAgendaSemana();
  }

  /*
  List<Map<String, dynamic>> _compromissosMockados(List<DateTime> dias) {
    return [
      {
        'dia': dias[0],
        'hora': '09:00',
        'titulo': 'Reunião interna',
        'cliente': 'Enterdoc',
        'cor': const Color(0xFFDBEAFE),
        'corTexto': const Color(0xFF1D4ED8),
      },
      {
        'dia': dias[1],
        'hora': '14:00',
        'titulo': 'Alinhamento cliente',
        'cliente': 'Cliente Exemplo 01',
        'cor': const Color(0xFFDCFCE7),
        'corTexto': const Color(0xFF166534),
      },
      {
        'dia': dias[3],
        'hora': '11:00',
        'titulo': 'Execução tarefa crítica',
        'cliente': 'Cliente Exemplo 02',
        'cor': const Color(0xFFFEE2E2),
        'corTexto': const Color(0xFFB91C1C),
      },
      {
        'dia': dias[4],
        'hora': '16:00',
        'titulo': 'Revisão semanal',
        'cliente': 'M&O',
        'cor': const Color(0xFFEDE9FE),
        'corTexto': const Color(0xFF6D28D9),
      },
    ];
  }*/

  List<Map<String, dynamic>> _buscarCompromissos(
      DateTime dia,
      String horario,
      List<Map<String, dynamic>> compromissos,
      ) {
    return compromissos.where((item) {
      final itemDia = item['dia'] as DateTime;
      final itemHora = (item['hora'] ?? '').toString();

      return itemDia.year == dia.year &&
          itemDia.month == dia.month &&
          itemDia.day == dia.day &&
          itemHora == horario;
    }).toList();
  }

  int _quantidadeCompromissosNoHorario(
      String horario,
      List<DateTime> dias,
      List<Map<String, dynamic>> compromissos,
      ) {
    int maiorQuantidade = 0;

    for (final dia in dias) {
      final quantidade = _buscarCompromissos(dia, horario, compromissos).length;
      if (quantidade > maiorQuantidade) {
        maiorQuantidade = quantidade;
      }
    }

    return maiorQuantidade;
  }

  @override
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    observacoesController.dispose();
    dataController.dispose();
    horaInicioController.dispose();
    horaFimController.dispose();
    vinculoIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dias = diasDaSemana;
    final compromissos = itensAgendaSemana;

    List<Map<String, dynamic>> compromissosTopo(DateTime dia) {
      return compromissos.where((item) {
        final itemDia = item['dia'] as DateTime;
        final itemHora = item['hora']?.toString();
        final itemTipo = item['tipo']?.toString();

        final ehTopo = itemHora == 'ALLDAY' || itemTipo == 'cronograma';

        return itemDia.year == dia.year &&
            itemDia.month == dia.month &&
            itemDia.day == dia.day &&
            ehTopo;
      }).toList();
    }

    List<Map<String, dynamic>> compromissosDoHorario(
        DateTime dia,
        String horario,
        ) {
      return compromissos.where((item) {
        final itemDia = item['dia'] as DateTime;
        final itemHora = item['hora']?.toString();
        final itemTipo = item['tipo']?.toString();

        if (itemTipo == 'cronograma') return false;
        if (itemHora == 'ALLDAY') return false;

        return itemDia.year == dia.year &&
            itemDia.month == dia.month &&
            itemDia.day == dia.day &&
            itemHora == horario;
      }).toList();
    }

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: Color(0xFF12324A),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Visão semanal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _faixaSemana(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _irSemanaAnterior,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Anterior'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: abrirDialogNovaAgenda,
                  icon: const Icon(Icons.add),
                  label: const Text('Nova agenda'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF12324A),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _irProximaSemana,
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('Próxima'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF12324A),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: carregandoAgenda
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 80,
                          child: Text(
                            'Hora',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                        ...dias.map(
                              (dia) {
                            final clienteDoDia = clientesRecorrentesSemana[dia.weekday];
                            final corCliente = corHexParaColor(
                              clienteDoDia?.corAgenda,
                              fallback: const Color(0xFFF9FAFB),
                            );

                            final fundoCabecalho = clienteDoDia != null
                                ? corCliente.withOpacity(0.30)
                                : const Color(0xFFF9FAFB);

                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                decoration: BoxDecoration(
                                  color: fundoCabecalho,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: clienteDoDia != null
                                        ? corCliente.withOpacity(0.65)
                                        : const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      _nomeDiaSemana(dia),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${dia.day.toString().padLeft(2, '0')}/${dia.month.toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      clienteDoDia?.nome ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: clienteDoDia != null
                                            ? const Color(0xFF1F2937)
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFFBEB),
                      border: Border(
                        top: BorderSide(color: Color(0xFFFDE68A)),
                        bottom: BorderSide(color: Color(0xFFFDE68A)),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 80,
                          child: Padding(
                            padding: EdgeInsets.only(left: 12, top: 8),
                            child: Text(
                              'Dia',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ),
                        ...List.generate(7, (diaIndex) {
                          final dia = dias[diaIndex];
                          final itensTopo = compromissosTopo(dia);
                          final fimDeSemana =
                              dia.weekday == DateTime.saturday ||
                                  dia.weekday == DateTime.sunday;

                          final clienteDoDia = clientesRecorrentesSemana[dia.weekday];
                          final corCliente = corHexParaColor(
                            clienteDoDia?.corAgenda,
                            fallback: const Color(0xFFFDE68A),
                          );

                          return Expanded(
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 68),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: clienteDoDia != null
                                    ? corCliente.withOpacity(0.22)
                                    : fimDeSemana
                                    ? const Color(0xFFFFFCF2)
                                    : const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: clienteDoDia != null
                                      ? corCliente.withOpacity(0.75)
                                      : const Color(0xFFFDE68A),
                                ),
                              ),
                              child: itensTopo.isEmpty
                                  ? const SizedBox.shrink()
                                  : Column(
                                children: itensTopo.map((compromisso) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () async {},
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF3C7),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: const Color(0xFFF59E0B).withOpacity(0.25),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              (compromisso['titulo'] ?? '').toString(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF92400E),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              (compromisso['subtitulo'] ?? '').toString(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                height: 1.1,
                                                color: Color(0xFFB45309),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.separated(
                      itemCount: horarios.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: Color(0xFFE5E7EB),
                      ),
                      itemBuilder: (context, index) {
                        final horario = horarios[index];

                        final quantidadeNoHorario = _quantidadeCompromissosNoHorario(
                          horario,
                          dias,
                          compromissos.where((item) {
                            return (item['hora'] ?? '').toString() != 'ALLDAY';
                          }).toList(),
                        );

                        final alturaLinha = quantidadeNoHorario <= 1
                            ? 96.0
                            : 96.0 + (quantidadeNoHorario - 1) * 56.0;

                        return SizedBox(
                          height: alturaLinha,
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  horario,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              ...List.generate(7, (diaIndex) {
                                final dia = dias[diaIndex];
                                final fimDeSemana =
                                    dia.weekday == DateTime.saturday ||
                                        dia.weekday == DateTime.sunday;

                                final clienteDoDia = clientesRecorrentesSemana[dia.weekday];
                                final corClienteDia = corHexParaColor(
                                  clienteDoDia?.corAgenda,
                                  fallback: const Color(0xFFDBEAFE),
                                );

                                final compromissosSlot = compromissosDoHorario(
                                  dia,
                                  horario,
                                );

                                return Expanded(
                                  child: Container(
                                    height: double.infinity,
                                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: clienteDoDia != null
                                            ? corClienteDia.withOpacity(0.16)
                                            : fimDeSemana
                                            ? const Color(0xFFF9FAFB)
                                            : const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: clienteDoDia != null
                                              ? corClienteDia.withOpacity(0.50)
                                              : const Color(0xFFE5E7EB),
                                        ),
                                      ),
                                      child: compromissosSlot.isEmpty
                                          ? const SizedBox.expand()
                                          : Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Column(
                                          children: compromissosSlot.map((compromisso) {
                                            final corBase = compromisso['corTexto'] as Color? ?? const Color(0xFF2563EB);
                                            final corFundo = Color.alphaBlend(
                                              corBase.withOpacity(0.10),
                                              Colors.white,
                                            );
                                            final corBorda = corBase.withOpacity(0.22);

                                            const corTitulo = Color(0xFF0F172A);
                                            const corSubtitulo = Color(0xFF475569);

                                            final clienteNome = (compromisso['clienteNome'] ?? '').toString().trim();
                                            final subtitulo = (compromisso['subtitulo'] ?? '').toString().trim();
                                            final titulo = (compromisso['titulo'] ?? 'Sem título').toString().trim();
                                            final clienteLogoPath =
                                            (compromisso['clienteLogoPath'] ?? '').toString().trim();

                                            final linhaTopo = clienteNome.isNotEmpty ? clienteNome : '';

                                            final subtituloNormalizado = subtitulo.trim();
                                            final clienteNormalizado = clienteNome.trim();

                                            final linhaSecundaria = subtituloNormalizado.isNotEmpty &&
                                                subtituloNormalizado.toLowerCase() != clienteNormalizado.toLowerCase()
                                                ? subtituloNormalizado
                                                : '';

                                            return Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 1),
                                                child: InkWell(
                                                  borderRadius: BorderRadius.circular(10),
                                                  onTap: () async {
                                                    final tipo = compromisso['tipo'];

                                                    if (tipo == 'agenda_manual') {
                                                      final agenda = compromisso['objeto'] as AgendaManual;
                                                      await abrirDialogEditarAgenda(agenda);
                                                      return;
                                                    }

                                                    if (tipo == 'tarefa') {
                                                      await abrirDialogVisualizarTarefa(compromisso['objeto']);
                                                      return;
                                                    }
                                                  },
                                                  child: Container(
                                                    width: double.infinity,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: corFundo,
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(color: corBorda),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.04),
                                                          blurRadius: 8,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: ClipRect(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.max,
                                                        children: [
                                                          if (linhaTopo.isNotEmpty || clienteLogoPath.isNotEmpty)
                                                            Row(
                                                              children: [
                                                                if (clienteLogoPath.isNotEmpty)
                                                                  Container(
                                                                    width: 12,
                                                                    height: 12,
                                                                    clipBehavior: Clip.antiAlias,
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.white,
                                                                      borderRadius: BorderRadius.circular(3),
                                                                    ),
                                                                    child: Image.asset(
                                                                      clienteLogoPath,
                                                                      fit: BoxFit.contain,
                                                                      errorBuilder: (_, __, ___) => const Icon(
                                                                        Icons.business,
                                                                        size: 9,
                                                                        color: Color(0xFF64748B),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                if (clienteLogoPath.isNotEmpty) const SizedBox(width: 4),
                                                                Expanded(
                                                                  child: Text(
                                                                    linhaTopo,
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: const TextStyle(
                                                                      fontSize: 8,
                                                                      fontWeight: FontWeight.w700,
                                                                      color: Color(0xFF64748B),
                                                                      height: 1.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          if (linhaTopo.isNotEmpty || clienteLogoPath.isNotEmpty)
                                                            const SizedBox(height: 3),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Text(
                                                                  titulo,
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: const TextStyle(
                                                                    fontSize: 10,
                                                                    fontWeight: FontWeight.w700,
                                                                    color: corTitulo,
                                                                    height: 1.0,
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 2),
                                                                if (linhaSecundaria.isNotEmpty) ...[
                                                                  const SizedBox(height: 2),
                                                                  Text(
                                                                    linhaSecundaria,
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: const TextStyle(
                                                                      fontSize: 8.5,
                                                                      fontWeight: FontWeight.w600,
                                                                      color: corSubtitulo,
                                                                      height: 1.0,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
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
}