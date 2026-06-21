import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/rotulos.dart';
import '../models/grupo.dart';
import '../models/enums.dart';
import '../providers/rotina_provider.dart';
import '../widgets/estado_vazio.dart';
import '../widgets/visao_estado.dart';

/// Tela de Rotinas de Cuidado (UC003), com filtro por tipo (FA01).
class RotinasScreen extends StatefulWidget {
  final Grupo grupo;
  const RotinasScreen({super.key, required this.grupo});
  @override
  State<RotinasScreen> createState() => _RotinasScreenState();
}

class _RotinasScreenState extends State<RotinasScreen> {
  String? _tipoFiltro;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<RotinaProvider>().carregar(widget.grupo.id));
  }

  Future<void> _nova() async {
    final descricao = TextEditingController();
    final horario = TextEditingController(text: '08:00');
    TipoRotina tipo = TipoRotina.medicacao;
    FrequenciaRotina freq = FrequenciaRotina.diaria;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Nova rotina'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<TipoRotina>(
                value: tipo,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: TipoRotina.values
                    .map((t) => DropdownMenuItem(value: t, child: Text(visualTipo(enumParaApi(t)).rotulo)))
                    .toList(),
                onChanged: (v) => setLocal(() => tipo = v!),
              ),
              const SizedBox(height: 12),
              TextField(controller: descricao, decoration: const InputDecoration(labelText: 'Descricao')),
              const SizedBox(height: 12),
              TextField(controller: horario, decoration: const InputDecoration(labelText: 'Horario (HH:MM)')),
              const SizedBox(height: 12),
              DropdownButtonFormField<FrequenciaRotina>(
                value: freq,
                decoration: const InputDecoration(labelText: 'Frequencia'),
                items: FrequenciaRotina.values
                    .map((f) => DropdownMenuItem(value: f, child: Text(frequencias[enumParaApi(f)] ?? '')))
                    .toList(),
                onChanged: (v) => setLocal(() => freq = v!),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salvar')),
          ],
        ),
      ),
    );

    if (ok == true && mounted) {
      final sucesso = await context.read<RotinaProvider>().criar(widget.grupo.id, {
        'tipo': enumParaApi(tipo),
        'descricao': descricao.text.trim(),
        'horario': horario.text.trim(),
        'frequencia': enumParaApi(freq),
      });
      if (!sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<RotinaProvider>().erro ?? 'Falha ao criar rotina')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<RotinaProvider>();
    final lista = _tipoFiltro == null ? prov.rotinas : prov.rotinas.where((r) => r.tipo == _tipoFiltro).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nova,
        icon: const Icon(Icons.add),
        label: const Text('Nova rotina'),
      ),
      body: Column(
        children: [
          _filtroTipos(),
          Expanded(
            child: prov.carregando
                ? const Carregando()
                : prov.erro != null
                    ? ErroView(mensagem: prov.erro!, aoTentar: () => prov.carregar(widget.grupo.id))
                    : lista.isEmpty
                        ? EstadoVazio(
                            icone: Icons.checklist,
                            titulo: 'Nenhuma rotina',
                            descricao: 'Cadastre rotinas de medicacao, alimentacao e higiene para receber lembretes.',
                            acaoRotulo: 'Nova rotina',
                            aoTocar: _nova,
                          )
                        : ListView(children: lista.map(_card).toList()),
          ),
        ],
      ),
    );
  }

  Widget _filtroTipos() {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _chip('Todas', _tipoFiltro == null, () => setState(() => _tipoFiltro = null)),
          ...tiposRotina.entries.map((e) => _chip(e.value.rotulo, _tipoFiltro == e.key,
              () => setState(() => _tipoFiltro = e.key))),
        ],
      ),
    );
  }

  Widget _chip(String rotulo, bool ativo, VoidCallback aoTocar) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(label: Text(rotulo), selected: ativo, onSelected: (_) => aoTocar()),
    );
  }

  Widget _card(dynamic r) {
    final vt = visualTipo(r.tipo);
    final vs = visualStatus(r.status);
    final concluida = r.status == 'CONCLUIDA';
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: vt.cor.withValues(alpha: 0.15), child: Icon(vt.icone, color: vt.cor)),
        title: Text(r.descricao),
        subtitle: Text('${vt.rotulo} - ${r.horario} - ${frequencias[r.frequencia] ?? r.frequencia}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(vs.icone, color: vs.cor, size: 20),
            if (!concluida)
              IconButton(
                icon: const Icon(Icons.done, color: Color(0xFF2E9E5B)),
                tooltip: 'Concluir',
                onPressed: () => context.read<RotinaProvider>().concluir(widget.grupo.id, r.id),
              ),
          ],
        ),
      ),
    );
  }
}
