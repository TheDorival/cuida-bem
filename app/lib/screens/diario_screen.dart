import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/rotulos.dart';
import '../models/grupo.dart';
import '../models/enums.dart';
import '../providers/diario_provider.dart';
import '../widgets/estado_vazio.dart';
import '../widgets/visao_estado.dart';
import '../widgets/faixa_resumo.dart';
import '../widgets/banner_conexao.dart';

/// Tela do Diario de Saude (UC004), com filtros por categoria e periodo (FA01/RF005).
class DiarioScreen extends StatefulWidget {
  final Grupo grupo;
  const DiarioScreen({super.key, required this.grupo});
  @override
  State<DiarioScreen> createState() => _DiarioScreenState();
}

class _DiarioScreenState extends State<DiarioScreen> {
  final _fmt = DateFormat('dd/MM/yyyy HH:mm');
  final Set<String> _categorias = {};
  DateTimeRange? _periodo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _aplicar());
  }

  void _aplicar() {
    context.read<DiarioProvider>().carregar(
          widget.grupo.id,
          categorias: _categorias.toList(),
          inicio: _periodo?.start,
          fim: _periodo?.end,
        );
  }

  Future<void> _selecionarPeriodo() async {
    final agora = DateTime.now();
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(agora.year - 2),
      lastDate: agora,
      initialDateRange: _periodo,
    );
    if (r != null) {
      setState(() => _periodo = r);
      _aplicar();
    }
  }

  Future<void> _nova() async {
    final descricao = TextEditingController();
    CategoriaDiario categoria = CategoriaDiario.saude;
    bool importante = false;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Nova entrada'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<CategoriaDiario>(
                value: categoria,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: CategoriaDiario.values
                    .map((c) => DropdownMenuItem(value: c, child: Text(visualCategoria(enumParaApi(c)).rotulo)))
                    .toList(),
                onChanged: (v) => setLocal(() => categoria = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descricao,
                maxLength: 500,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Descricao'),
              ),
              SwitchListTile(
                value: importante,
                onChanged: (v) => setLocal(() => importante = v),
                title: const Text('Importante'),
                subtitle: const Text('Notifica todos os membros'),
                contentPadding: EdgeInsets.zero,
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
      final sucesso = await context.read<DiarioProvider>().registrar(widget.grupo.id, {
        'categoria': enumParaApi(categoria),
        'descricao': descricao.text.trim(),
        'importante': importante,
      });
      if (!sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<DiarioProvider>().erro ?? 'Falha ao registrar')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DiarioProvider>();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nova,
        icon: const Icon(Icons.add),
        label: const Text('Nova entrada'),
      ),
      body: Column(
        children: [
          if (context.watch<DiarioProvider>().erro != null && context.watch<DiarioProvider>().entradas.isNotEmpty)
            BannerConexao(aoTentar: _aplicar),
          FaixaResumo(itens: [
            ItemResumo(
                icone: Icons.menu_book,
                cor: const Color(0xFF2E7D6B),
                valor: '${prov.entradas.length}',
                rotulo: 'registros'),
            ItemResumo(
                icone: Icons.priority_high,
                cor: const Color(0xFFD9A407),
                valor: '${prov.entradas.where((e) => e.importante).length}',
                rotulo: 'importantes'),
          ]),
          _filtros(),
          Expanded(
            child: prov.carregando
                ? const Carregando()
                : (prov.erro != null && prov.entradas.isEmpty)
                    ? ErroView(mensagem: prov.erro!, aoTentar: _aplicar)
                    : prov.entradas.isEmpty
                        ? EstadoVazio(
                            icone: Icons.menu_book,
                            titulo: 'Diario vazio',
                            descricao: 'Registre saude, humor, alimentacao e ocorrencias do dia a dia.',
                            acaoRotulo: 'Nova entrada',
                            aoTocar: _nova,
                          )
                        : ListView(children: prov.entradas.reversed.map(_card).toList()),
          ),
        ],
      ),
    );
  }

  Widget _filtros() {
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: categorias.entries.map((e) {
              final ativo = _categorias.contains(e.key);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  avatar: Icon(e.value.icone, size: 18, color: e.value.cor),
                  label: Text(e.value.rotulo),
                  selected: ativo,
                  onSelected: (v) {
                    setState(() => v ? _categorias.add(e.key) : _categorias.remove(e.key));
                    _aplicar();
                  },
                ),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selecionarPeriodo,
                  icon: const Icon(Icons.date_range),
                  label: Text(_periodo == null
                      ? 'Filtrar por periodo'
                      : '${DateFormat('dd/MM').format(_periodo!.start)} - ${DateFormat('dd/MM').format(_periodo!.end)}'),
                ),
              ),
              if (_periodo != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() => _periodo = null);
                    _aplicar();
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card(dynamic e) {
    final v = visualCategoria(e.categoria);
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: v.cor.withValues(alpha: 0.15), child: Icon(v.icone, color: v.cor)),
        title: Text(e.descricao),
        subtitle: Text('${v.rotulo} - ${_fmt.format(e.criadaEm)} - ${e.autorNome ?? ''}'),
        trailing: e.importante ? const Icon(Icons.priority_high, color: Color(0xFFD9A407)) : null,
        isThreeLine: true,
      ),
    );
  }
}
