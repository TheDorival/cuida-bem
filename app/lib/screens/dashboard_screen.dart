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
  final _dataHora = DateFormat('dd/MM HH:mm');
  final _hoje = DateFormat("EEEE, d 'de' MMMM", 'pt_BR');

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
        padding: const EdgeInsets.only(top: 16, bottom: 28),
        children: [
          _hero(context),
          const SizedBox(height: 8),
          Row(
            children: [
              _metrica(context, '${pendentes.length}', 'Pendentes', Icons.schedule, const Color(0xFFE0852E)),
              _metrica(context, '$concluidas', 'Concluidas', Icons.check_circle, const Color(0xFF2E9E5B)),
              _metrica(context, '${widget.grupo.membros.length}', 'Membros', Icons.groups, cor.primary),
            ],
          ),
          _acoesRapidas(context),
          _tituloSecao(context, Icons.checklist, 'Rotinas de hoje', 'Ver todas', () => widget.aoIrPara(1)),
          if (rotinaProv.carregando)
            const Padding(padding: EdgeInsets.all(24), child: Carregando())
          else if (pendentes.isEmpty)
            _vazioInline(context, Icons.task_alt, 'Tudo em dia! Nenhuma rotina pendente.')
          else
            ...pendentes.take(3).map((r) {
              final v = visualTipo(r.tipo);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: v.cor.withValues(alpha: 0.15), child: Icon(v.icone, color: v.cor)),
                  title: Text(r.descricao),
                  subtitle: Text('${v.rotulo} - ${r.horario}'),
                  trailing: IconButton.filledTonal(
                    icon: const Icon(Icons.done),
                    tooltip: 'Concluir',
                    onPressed: () => context.read<RotinaProvider>().concluir(widget.grupo.id, r.id),
                  ),
                ),
              );
            }),
          _tituloSecao(context, Icons.menu_book, 'Diario recente', 'Ver tudo', () => widget.aoIrPara(2)),
          if (recentes.isEmpty)
            _vazioInline(context, Icons.edit_note, 'Sem registros recentes no diario.')
          else
            ...recentes.map((e) {
              final v = visualCategoria(e.categoria);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: v.cor.withValues(alpha: 0.15), child: Icon(v.icone, color: v.cor)),
                  title: Text(e.descricao, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${v.rotulo} - ${_dataHora.format(e.criadaEm)}'),
                  trailing: e.importante ? const Icon(Icons.priority_high, color: Color(0xFFD9A407)) : null,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    String data;
    try {
      data = _hoje.format(DateTime.now());
    } catch (_) {
      data = DateFormat('dd/MM/yyyy').format(DateTime.now());
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D6B), Color(0xFF49B194)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.elderly, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cuidando de', style: TextStyle(color: cor.onSurfaceVariant, fontSize: 13)),
                  Text(widget.grupo.nomeIdoso,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(data, style: TextStyle(color: cor.onSurfaceVariant, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _acoesRapidas(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _atalho(context, Icons.add_task, 'Nova\nrotina', () => widget.aoIrPara(1)),
          const SizedBox(width: 10),
          _atalho(context, Icons.note_add, 'Nova\nentrada', () => widget.aoIrPara(2)),
          const SizedBox(width: 10),
          _atalho(context, Icons.picture_as_pdf, 'Gerar\nrelatorio', () => widget.aoIrPara(3)),
        ],
      ),
    );
  }

  Widget _atalho(BuildContext context, IconData icone, String rotulo, VoidCallback aoTocar) {
    final cor = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: cor.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icone, color: cor.onPrimaryContainer),
              const SizedBox(height: 6),
              Text(rotulo,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cor.onPrimaryContainer, fontSize: 12, height: 1.2, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metrica(BuildContext context, String valor, String rotulo, IconData icone, Color cor) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icone, color: cor),
              const SizedBox(height: 6),
              Text(valor, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(rotulo, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tituloSecao(BuildContext context, IconData icone, String titulo, String acao, VoidCallback aoTocar) {
    final cor = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Icon(icone, size: 20, color: cor.primary),
            const SizedBox(width: 8),
            Text(titulo, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          ]),
          TextButton(onPressed: aoTocar, child: Text(acao)),
        ],
      ),
    );
  }

  Widget _vazioInline(BuildContext context, IconData icone, String texto) {
    final cor = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cor.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Icon(icone, color: cor.outline),
        const SizedBox(width: 10),
        Expanded(child: Text(texto, style: TextStyle(color: cor.onSurfaceVariant))),
      ]),
    );
  }
}
