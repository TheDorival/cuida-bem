import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/rotulos.dart';
import '../models/grupo.dart';
import '../providers/relatorio_provider.dart';
import '../widgets/estado_vazio.dart';
import '../widgets/visao_estado.dart';

/// Tela de Relatorios de Evolucao (UC007), com selecao de periodo e categorias (FA01).
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
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<RelatorioProvider>().carregar(widget.grupo.id));
  }

  Future<void> _gerar() async {
    final agora = DateTime.now();
    DateTimeRange periodo = DateTimeRange(start: agora.subtract(const Duration(days: 30)), end: agora);
    final Set<String> selecionadas = {};

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gerar relatorio', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final r = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(agora.year - 2),
                    lastDate: agora,
                    initialDateRange: periodo,
                  );
                  if (r != null) setLocal(() => periodo = r);
                },
                icon: const Icon(Icons.date_range),
                label: Text('${_fmt.format(periodo.start)} a ${_fmt.format(periodo.end)}'),
              ),
              const SizedBox(height: 16),
              const Text('Categorias (opcional)'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: categorias.entries.map((e) {
                  final ativo = selecionadas.contains(e.key);
                  return FilterChip(
                    label: Text(e.value.rotulo),
                    selected: ativo,
                    onSelected: (v) => setLocal(() => v ? selecionadas.add(e.key) : selecionadas.remove(e.key)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Gerar PDF'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (ok != true || !mounted) return;
    final r = await context.read<RelatorioProvider>().gerar(
          widget.grupo.id, periodo.start, periodo.end, selecionadas.toList(),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(r != null
          ? 'Relatorio v${r.versao} gerado (${r.totalEntradas} registros)'
          : (context.read<RelatorioProvider>().erro ?? 'Falha ao gerar relatorio')),
    ));
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
          ? const Carregando()
          : prov.erro != null
              ? ErroView(mensagem: prov.erro!, aoTentar: () => prov.carregar(widget.grupo.id))
              : prov.relatorios.isEmpty
                  ? EstadoVazio(
                      icone: Icons.picture_as_pdf,
                      titulo: 'Nenhum relatorio',
                      descricao: 'Gere um PDF da evolucao do idoso para compartilhar com profissionais de saude.',
                      acaoRotulo: 'Gerar relatorio',
                      aoTocar: _gerar,
                    )
                  : ListView(
                      children: prov.relatorios.map((r) {
                        final cats = r.categorias.isEmpty
                            ? 'Todas as categorias'
                            : r.categorias.map((c) => visualCategoria(c).rotulo).join(', ');
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: const Icon(Icons.picture_as_pdf),
                            ),
                            title: Text('${_fmt.format(r.periodoInicio)} a ${_fmt.format(r.periodoFim)}'),
                            subtitle: Text('Versao ${r.versao} - ${r.totalEntradas} registros\n$cats'),
                            isThreeLine: true,
                            trailing: const Icon(Icons.download),
                          ),
                        );
                      }).toList(),
                    ),
    );
  }
}
