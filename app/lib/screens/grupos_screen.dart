import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grupo_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/estado_vazio.dart';
import '../widgets/visao_estado.dart';
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

  Future<void> _sair() async {
    await context.read<SessionProvider>().sair();
    if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
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
          const SizedBox(height: 12),
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
      appBar: AppBar(
        title: const Text('Meus grupos'),
        actions: [
          IconButton(onPressed: _sair, icon: const Icon(Icons.logout), tooltip: 'Sair'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novoGrupo,
        icon: const Icon(Icons.add),
        label: const Text('Novo grupo'),
      ),
      body: prov.carregando
          ? const Carregando()
          : prov.erro != null
              ? ErroView(mensagem: prov.erro!, aoTentar: () => prov.carregar())
              : prov.grupos.isEmpty
                  ? EstadoVazio(
                      icone: Icons.groups,
                      titulo: 'Nenhum grupo ainda',
                      descricao: 'Crie um grupo de cuidado para organizar rotinas, diario e relatorios do idoso.',
                      acaoRotulo: 'Criar grupo',
                      aoTocar: _novoGrupo,
                    )
                  : RefreshIndicator(
                      onRefresh: () => prov.carregar(),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: prov.grupos.map((g) {
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: const Icon(Icons.elderly),
                              ),
                              title: Text(g.nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text('Idoso: ${g.nomeIdoso}  -  ${g.membros.length} membro(s)'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                context.read<GrupoProvider>().selecionar(g);
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => GrupoHomeScreen(grupo: g)),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
    );
  }
}
