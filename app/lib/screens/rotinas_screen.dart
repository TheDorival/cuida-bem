import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/rotulos.dart';
import '../models/grupo.dart';
import '../models/enums.dart';
import '../providers/rotina_provider.dart';
import '../widgets/estado_vazio.dart';
import '../widgets/visao_estado.dart';
import '../widgets/faixa_resumo.dart';
import '../widgets/banner_conexao.dart';

/// Tela de Rotinas de Cuidado (UC003): cadastrar, editar, concluir e desativar.
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

  // Formulario unico para criar (FA padrao) e editar (FA01) rotina.
  Future<void> _form({dynamic existente}) async {
    final editando = existente != null;
    final descricao = TextEditingController(text: editando ? existente.descricao : '');
    final horario = TextEditingController(text: editando ? existente.horario : '08:00');
    TipoRotina tipo = editando ? enumDaApi(TipoRotina.values, existente.tipo) : TipoRotina.medicacao;
    FrequenciaRotina freq =
        editando ? enumDaApi(FrequenciaRotina.values, existente.frequencia) : FrequenciaRotina.diaria;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(editando ? 'Editar rotina' : 'Nova rotina'),
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
      final dados = {
        'tipo': enumParaApi(tipo),
        'descricao': descricao.text.trim(),
        'horario': horario.text.trim(),
        'frequencia': enumParaApi(freq),
      };
      final prov = context.read<RotinaProvider>();
      final sucesso = editando
          ? await prov.editar(widget.grupo.id, existente.id, dados)
          : await prov.criar(widget.grupo.id, dados);
      if (!sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(prov.erro ?? 'Falha ao salvar rotina')));
      }
    }
  }

  Future<void> _desativar(dynamic r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Desativar rotina'),
        content: const Text('Os alertas futuros serao cancelados, mas o historico de conclusoes e mantido. Confirmar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Desativar')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<RotinaProvider>().desativar(widget.grupo.id, r.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<RotinaProvider>();
    final lista = _tipoFiltro == null ? prov.rotinas : prov.rotinas.where((r) => r.tipo == _tipoFiltro).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _form(),
        icon: const Icon(Icons.add),
        label: const Text('Nova rotina'),
      ),
      body: Column(
        children: [
          if (context.watch<RotinaProvider>().erro != null && context.watch<RotinaProvider>().rotinas.isNotEmpty)
            BannerConexao(aoTentar: () => context.read<RotinaProvider>().carregar(widget.grupo.id)),
          FaixaResumo(itens: [
            ItemResumo(
                icone: Icons.schedule,
                cor: const Color(0xFFE0852E),
                valor: '${prov.rotinas.where((r) => r.status == "PENDENTE").length}',
                rotulo: 'pendentes'),
            ItemResumo(
                icone: Icons.check_circle,
                cor: const Color(0xFF2E9E5B),
                valor: '${prov.rotinas.where((r) => r.status == "CONCLUIDA").length}',
                rotulo: 'concluidas'),
          ]),
          _filtroTipos(),
          Expanded(
            child: prov.carregando
                ? const Carregando()
                : (prov.erro != null && lista.isEmpty)
                    ? ErroView(mensagem: prov.erro!, aoTentar: () => prov.carregar(widget.grupo.id))
                    : lista.isEmpty
                        ? EstadoVazio(
                            icone: Icons.checklist,
                            titulo: 'Nenhuma rotina',
                            descricao: 'Cadastre rotinas de medicacao, alimentacao e higiene para receber lembretes.',
                            acaoRotulo: 'Nova rotina',
                            aoTocar: () => _form(),
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
          ...tiposRotina.entries
              .map((e) => _chip(e.value.rotulo, _tipoFiltro == e.key, () => setState(() => _tipoFiltro = e.key))),
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
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'editar') _form(existente: r);
                if (v == 'desativar') _desativar(r);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'editar', child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('Editar')])),
                PopupMenuItem(
                    value: 'desativar', child: Row(children: [Icon(Icons.block), SizedBox(width: 8), Text('Desativar')])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
