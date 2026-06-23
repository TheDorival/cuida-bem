import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_mode.dart';
import '../providers/session_provider.dart';
import '../providers/tema_provider.dart';

/// Tela de perfil/conta: editar nome, trocar senha, tema, sair e excluir conta.
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final tema = context.watch<TemaProvider>();
    final cor = Theme.of(context).colorScheme;
    final nome = session.nomeUsuario;
    final inicial = nome.trim().isNotEmpty ? nome.trim()[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Minha conta')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: cor.primaryContainer,
                    child: Text(inicial,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cor.onPrimaryContainer)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        if (session.emailUsuario.isNotEmpty)
                          Text(session.emailUsuario, style: TextStyle(color: cor.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar nome'),
            onTap: () => _editarNome(context),
          ),
          if (!kDemoMode)
            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: const Text('Trocar senha'),
              onTap: () => _trocarSenha(context),
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('Tema', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          RadioListTile<ThemeMode>(
            secondary: const Icon(Icons.light_mode),
            title: const Text('Claro'),
            value: ThemeMode.light,
            groupValue: tema.modo,
            onChanged: (m) => context.read<TemaProvider>().definir(m!),
          ),
          RadioListTile<ThemeMode>(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Escuro'),
            value: ThemeMode.dark,
            groupValue: tema.modo,
            onChanged: (m) => context.read<TemaProvider>().definir(m!),
          ),
          RadioListTile<ThemeMode>(
            secondary: const Icon(Icons.brightness_auto),
            title: const Text('De acordo com o sistema'),
            value: ThemeMode.system,
            groupValue: tema.modo,
            onChanged: (m) => context.read<TemaProvider>().definir(m!),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () => _sair(context),
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: cor.error),
            title: Text('Excluir conta', style: TextStyle(color: cor.error)),
            onTap: () => _excluir(context),
          ),
        ],
      ),
    );
  }

  Future<void> _editarNome(BuildContext context) async {
    final session = context.read<SessionProvider>();
    final nome = TextEditingController(text: session.nomeUsuario);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar nome'),
        content: TextField(controller: nome, decoration: const InputDecoration(labelText: 'Nome')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salvar')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final sucesso = await session.atualizarNome(nome.text.trim());
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(sucesso ? 'Nome atualizado' : (session.erro ?? 'Falha ao atualizar'))),
    );
  }

  Future<void> _trocarSenha(BuildContext context) async {
    final session = context.read<SessionProvider>();
    final senha = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Trocar senha'),
        content: TextField(
          controller: senha,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Nova senha (min. 6 caracteres)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salvar')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    if (senha.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A senha deve ter ao menos 6 caracteres')),
      );
      return;
    }
    final sucesso = await session.atualizarSenha(senha.text);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(sucesso ? 'Senha alterada' : (session.erro ?? 'Falha ao alterar senha'))),
    );
  }

  Future<void> _sair(BuildContext context) async {
    await context.read<SessionProvider>().sair();
    if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _excluir(BuildContext context) async {
    final session = context.read<SessionProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text('Esta acao e permanente e remove o seu acesso. Deseja continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final sucesso = await session.excluirConta();
    if (!context.mounted) return;
    if (sucesso) {
      Navigator.of(context).popUntil((r) => r.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(session.erro ?? 'Falha ao excluir conta')),
      );
    }
  }
}
