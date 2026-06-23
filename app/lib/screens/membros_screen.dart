import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/rotulos.dart';
import '../models/grupo.dart';
import '../providers/grupo_provider.dart';
import '../providers/session_provider.dart';

/// Gestao de membros e convites do grupo (UC002).
class MembrosScreen extends StatelessWidget {
  final String grupoId;
  const MembrosScreen({super.key, required this.grupoId});

  @override
  Widget build(BuildContext context) {
    final grupoProv = context.watch<GrupoProvider>();
    final session = context.read<SessionProvider>();
    final grupo = grupoProv.grupos.firstWhere(
      (g) => g.id == grupoId,
      orElse: () => grupoProv.selecionado!,
    );
    final ehPrincipal = grupo.cuidadorPrincipalId == session.usuarioId;

    return Scaffold(
      appBar: AppBar(title: const Text('Membros do grupo')),
      floatingActionButton: ehPrincipal
          ? FloatingActionButton.extended(
              onPressed: () => _convidar(context, grupo),
              icon: const Icon(Icons.person_add),
              label: const Text('Convidar'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (!ehPrincipal)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Apenas o Cuidador Principal pode convidar ou remover membros (RN002).'),
            ),
          ...grupo.membros.map((m) {
            final principal = m.usuarioId == grupo.cuidadorPrincipalId;
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(principal ? Icons.shield : Icons.person,
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
                title: Text(perfis[m.perfil] ?? m.perfil),
                subtitle: Text(principal ? 'Cuidador principal do grupo' : 'ID: ${m.usuarioId}'),
                trailing: (ehPrincipal && !principal)
                    ? IconButton(
                        icon: const Icon(Icons.person_remove, color: Color(0xFFD9534F)),
                        tooltip: 'Remover',
                        onPressed: () => _remover(context, grupo, m),
                      )
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _convidar(BuildContext context, Grupo grupo) async {
    final email = TextEditingController();
    String perfil = 'CUIDADOR_AUXILIAR';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Convidar membro'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail do convidado (opcional)',
                helperText: 'Apenas para sua organizacao; o codigo e enviado por voce.',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: perfil,
              isExpanded: true,
              items: perfis.entries
                  .where((e) => e.key != 'CUIDADOR_PRINCIPAL')
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setLocal(() => perfil = v!),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Gerar convite')),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;

    final convite = await context.read<GrupoProvider>().convidar(grupo.id, email: email.text.trim(), perfil: perfil);
    if (!context.mounted) return;
    if (convite != null) {
      _mostrarCodigo(context, (convite['token'] ?? '').toString(), perfis[perfil] ?? perfil);
    } else {
      final erro = context.read<GrupoProvider>().erro ?? 'Falha ao convidar';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
    }
  }

  // Mostra o codigo do convite com botao de copiar e instrucoes de uso.
  void _mostrarCodigo(BuildContext context, String codigo, String perfilRotulo) {
    showDialog(
      context: context,
      builder: (dctx) => AlertDialog(
        title: const Text('Convite gerado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Envie este codigo para a pessoa (WhatsApp, mensagem...). '
              'Ela deve entrar na conta dela, tocar em "Entrar com convite" e colar o codigo.',
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(dctx).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SelectableText(
                codigo,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Perfil: $perfilRotulo  •  valido por 7 dias',
              style: Theme.of(dctx).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Fechar')),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: codigo));
              if (dctx.mounted) {
                ScaffoldMessenger.of(dctx).showSnackBar(
                  const SnackBar(content: Text('Codigo copiado')),
                );
              }
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copiar codigo'),
          ),
        ],
      ),
    );
  }

  Future<void> _remover(BuildContext context, Grupo grupo, Membro membro) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover membro'),
        content: const Text('O membro perdera acesso ao grupo, mas seu historico e mantido (RN008). Confirmar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remover')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final sucesso = await context.read<GrupoProvider>().removerMembro(grupo.id, membro.usuarioId);
    if (context.mounted && !sucesso) {
      final erro = context.read<GrupoProvider>().erro ?? 'Falha ao remover';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
    }
  }
}
