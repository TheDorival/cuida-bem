import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/rotulos.dart';
import '../models/grupo.dart';
import '../providers/rotina_provider.dart';
import '../providers/diario_provider.dart';
import '../widgets/visao_estado.dart';

/// Tela inicial do grupo com resumo do dia (rotinas pendentes, diario recente).
class DashboardScreen extends StatefulWidget {
  final Grupo grupo;
  final void Function(int destino) aoIrPara;
  const DashboardScreen({super.key, required this.grupo, required this.aoIrPara});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _hora = DateFormat('HH:mm');
  final _data = DateFormat('dd/MM HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() async {
    await context.read<RotinaProvider>().carregar(widget.grupo.id);
    if (mounted) await context.read<DiarioProvider>().carregar(widget.grupo.id);
  }

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    final rotinaProv = context.watch<RotinaProvider>();
    final diarioProv = context.watch<DiarioProvider>();

    final rotinas = rotinaProv.rotinas;
    final pendentes = rotinas.where((r) => r.status == 'PENDENTE').toList();
    final concluidas = rotinas.where((r) => r.status == 'CONCLUIDA').length;
    final recentes = diarioProv.entradas.reversed.take(3).toList();

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // Cabecalho de boas-vindas
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cor.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: cor.primary,
                  child: const Icon(Icons.elderly, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cuidando de', style: TextStyle(color: cor.onPrimaryContainer)),
                      Text(widget.grupo.nomeIdoso,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: cor.onPrimaryContainer, fontWeight: FontWeight.bold)),
                      Text(widget.grupo.nome, style: TextStyle(color: cor.onPrimaryContainer)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Resumo em numeros
          Row(
            children: [
              _resumo(context, '${pendentes.length}', 'Pendentes', Icons.schedule, const Color(0xFFE0852E)),
              _resumo(context, '$concluidas', 'Concluidas', Icons.check_circle, const Color(0xFF2E9E5B)),
              _resumo(context, '${widget.grupo.membros.length}', 'Membros', Icons.groups, cor.primary),
            ],
          ),

          // Rotinas de hoje
          _tituloSecao(context, 'Rotinas de hoje', 'Ver todas', () => widget.aoIrPara(1)),
          if (rotinaProv.carregando)
            const Padding(padding: EdgeInsets.all(24), child: Carregando())
          else if (pendentes.isEmpty)
            _vazioInline(context, 'Tudo em dia! Nenhuma rotina pendente.')
          else
            ...pendentes.take(3).map((r) {
              final v = visualTipo(r.tipo);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: v.cor.withValues(alpha: 0.15), child: Icon(v.icone, color: v.cor)),
                  title: Text(r.descricao),
                  subtitle: Text('${v.rotulo} - ${r.horario}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.done, color: Color(0xFF2E9E5B)),
                    tooltip: 'Concluir',
                    onPressed: () => context.read<RotinaProvider>().concluir(widget.grupo.id, r.id),
                  ),
                ),
              );
            }),

          // Diario recente
          _tituloSecao(context, 'Diario recente', 'Ver tudo', () => widget.aoIrPara(2)),
          if (recentes.isEmpty)
            _vazioInline(context, 'Sem registros recentes no diario.')
          else
            ...recentes.map((e) {
              final v = visualCategoria(e.categoria);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: v.cor.withValues(alpha: 0.15), child: Icon(v.icone, color: v.cor)),
                  title: Text(e.descricao, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${v.rotulo} - ${_data.format(e.criadaEm)}'),
                  trailing: e.importante ? const Icon(Icons.priority_high, color: Color(0xFFD9A407)) : null,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _resumo(BuildContext context, String valor, String rotulo, IconData icone, Color cor) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icone, color: cor),
              const SizedBox(height: 6),
              Text(valor, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              Text(rotulo, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tituloSecao(BuildContext context, String titulo, String acao, VoidCallback aoTocar) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          TextButton(onPressed: aoTocar, child: Text(acao)),
        ],
      ),
    );
  }

  Widget _vazioInline(BuildContext context, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(texto, style: TextStyle(color: Theme.of(context).colorScheme.outline)),
    );
  }
}
