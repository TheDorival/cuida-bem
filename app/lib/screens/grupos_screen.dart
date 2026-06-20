import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grupo_provider.dart';
import 'grupo_home_screen.dart';

/// Lista de grupos do usuario e criacao de novo grupo (UC002).
class GruposScreen extends StatefulWidget {
  const GruposScreen({super.key});
  @override
  State<GruposScreen> createState() => _GruposScreenState();
}

class _GruposScreenState extends State<GruposScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<GrupoProvider>().carregar());
  }

  Future<void> _novoGrupo() async {
    final nome = TextEditingController();
    final idoso = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Novo grupo de cuidado'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nome, decoration: const InputDecoration(labelText: 'Nome do grupo')),
          TextField(controller: idoso, decoration: const InputDecoration(labelText: 'Nome do idoso')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Criar')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<GrupoProvider>().criar(nome.text.trim(), idoso.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<GrupoProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Meus grupos')),
      floatingActionButton: FloatingActionButton(onPressed: _novoGrupo, child: const Icon(Icons.add)),
      body: prov.carregando
          ? const Center(child: CircularProgressIndicator())
          : prov.grupos.isEmpty
              ? const Center(child: Text('Nenhum grupo. Toque em + para criar.'))
              : ListView(
                  children: prov.grupos
                      .map((g) => ListTile(
                            leading: const Icon(Icons.groups),
                            title: Text(g.nome),
                            subtitle: Text('Idoso: ${g.nomeIdoso}  -  ${g.membros.length} membro(s)'),
                            onTap: () {
                              prov.selecionar(g);
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => GrupoHomeScreen(grupo: g)),
                              );
                            },
                          ))
                      .toList(),
                ),
    );
  }
}
