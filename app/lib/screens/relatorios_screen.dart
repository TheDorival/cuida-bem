import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/grupo.dart';
import '../providers/relatorio_provider.dart';

/// Tela de Relatorios de Evolucao (UC007).
class RelatoriosScreen extends StatefulWidget {
  final Grupo grupo;
  const RelatoriosScreen({super.key, required this.grupo});
  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  final _fmt = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<RelatorioProvider>().carregar(widget.grupo.id),
    );
  }

  Future<void> _gerar() async {
    final agora = DateTime.now();
    final intervalo = await showDateRangePicker(
      context: context,
      firstDate: DateTime(agora.year - 2),
      lastDate: agora,
      initialDateRange: DateTimeRange(start: agora.subtract(const Duration(days: 30)), end: agora),
    );
    if (intervalo == null || !mounted) return;

    final r = await context.read<RelatorioProvider>().gerar(
          widget.grupo.id,
          intervalo.start,
          intervalo.end,
          const [],
        );
    if (!mounted) return;
    final msg = r != null
        ? 'Relatorio v${r.versao} gerado (${r.totalEntradas} registros)'
        : (context.read<RelatorioProvider>().erro ?? 'Falha ao gerar relatorio');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<RelatorioProvider>();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _gerar,
        icon: const Icon(Icons.add),
        label: const Text('Gerar'),
      ),
      body: prov.carregando
          ? const Center(child: CircularProgressIndicator())
          : prov.relatorios.isEmpty
              ? const Center(child: Text('Nenhum relatorio gerado.'))
              : ListView(
                  children: prov.relatorios.map((r) {
                    return ListTile(
                      leading: const Icon(Icons.picture_as_pdf),
                      title: Text('${_fmt.format(r.periodoInicio)} a ${_fmt.format(r.periodoFim)}'),
                      subtitle: Text('Versao ${r.versao} - ${r.totalEntradas} registros'),
                      trailing: const Icon(Icons.download),
                    );
                  }).toList(),
                ),
    );
  }
}
