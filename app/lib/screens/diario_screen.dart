import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/grupo.dart';
import '../models/enums.dart';
import '../providers/diario_provider.dart';

/// Tela do Diario de Saude (UC004).
class DiarioScreen extends StatefulWidget {
  final Grupo grupo;
  const DiarioScreen({super.key, required this.grupo});
  @override
  State<DiarioScreen> createState() => _DiarioScreenState();
}

class _DiarioScreenState extends State<DiarioScreen> {
  final _fmt = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<DiarioProvider>().carregar(widget.grupo.id),
    );
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
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButton<CategoriaDiario>(
              value: categoria,
              isExpanded: true,
              items: CategoriaDiario.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(enumParaApi(c))))
                  .toList(),
              onChanged: (v) => setLocal(() => categoria = v!),
            ),
            TextField(
              controller: descricao,
              maxLength: 500,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descricao'),
            ),
            SwitchListTile(
              value: importante,
              onChanged: (v) => setLocal(() => importante = v),
              title: const Text('Marcar como importante'),
            ),
          ]),
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
        final erro = context.read<DiarioProvider>().erro ?? 'Falha ao registrar';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DiarioProvider>();
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _nova, child: const Icon(Icons.add)),
      body: prov.carregando
          ? const Center(child: CircularProgressIndicator())
          : prov.entradas.isEmpty
              ? const Center(child: Text('Diario vazio.'))
              : ListView(
                  children: prov.entradas.map((e) {
                    return ListTile(
                      leading: Icon(e.importante ? Icons.priority_high : Icons.notes,
                          color: e.importante ? Colors.orange : null),
                      title: Text(e.descricao),
                      subtitle: Text('${e.categoria} - ${_fmt.format(e.criadaEm)} - ${e.autorNome ?? ''}'),
                    );
                  }).toList(),
                ),
    );
  }
}
