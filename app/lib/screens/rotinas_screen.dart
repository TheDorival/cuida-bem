import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/grupo.dart';
import '../models/enums.dart';
import '../providers/rotina_provider.dart';

/// Tela de Rotinas de Cuidado (UC003).
class RotinasScreen extends StatefulWidget {
  final Grupo grupo;
  const RotinasScreen({super.key, required this.grupo});
  @override
  State<RotinasScreen> createState() => _RotinasScreenState();
}

class _RotinasScreenState extends State<RotinasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<RotinaProvider>().carregar(widget.grupo.id),
    );
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
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButton<TipoRotina>(
              value: tipo,
              isExpanded: true,
              items: TipoRotina.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(enumParaApi(t))))
                  .toList(),
              onChanged: (v) => setLocal(() => tipo = v!),
            ),
            TextField(controller: descricao, decoration: const InputDecoration(labelText: 'Descricao')),
            TextField(controller: horario, decoration: const InputDecoration(labelText: 'Horario (HH:MM)')),
            DropdownButton<FrequenciaRotina>(
              value: freq,
              isExpanded: true,
              items: FrequenciaRotina.values
                  .map((f) => DropdownMenuItem(value: f, child: Text(enumParaApi(f))))
                  .toList(),
              onChanged: (v) => setLocal(() => freq = v!),
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
      final sucesso = await context.read<RotinaProvider>().criar(widget.grupo.id, {
        'tipo': enumParaApi(tipo),
        'descricao': descricao.text.trim(),
        'horario': horario.text.trim(),
        'frequencia': enumParaApi(freq),
      });
      if (!sucesso && mounted) {
        final erro = context.read<RotinaProvider>().erro ?? 'Falha ao criar rotina';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<RotinaProvider>();
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _nova, child: const Icon(Icons.add)),
      body: prov.carregando
          ? const Center(child: CircularProgressIndicator())
          : prov.rotinas.isEmpty
              ? const Center(child: Text('Nenhuma rotina cadastrada.'))
              : ListView(
                  children: prov.rotinas.map((r) {
                    final concluida = r.status == 'CONCLUIDA';
                    return ListTile(
                      leading: Icon(concluida ? Icons.check_circle : Icons.schedule,
                          color: concluida ? Colors.green : null),
                      title: Text(r.descricao),
                      subtitle: Text('${r.tipo} - ${r.horario} - ${r.frequencia}'),
                      trailing: concluida
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.done),
                              tooltip: 'Concluir',
                              onPressed: () => prov.concluir(widget.grupo.id, r.id),
                            ),
                    );
                  }).toList(),
                ),
    );
  }
}
