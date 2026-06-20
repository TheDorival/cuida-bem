import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';

/// Tela de acesso (UC001): login e cadastro via Firebase Auth.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _cadastro = false;
  bool _carregando = false;

  Future<void> _submeter() async {
    setState(() => _carregando = true);
    final session = context.read<SessionProvider>();
    final ok = _cadastro
        ? await session.cadastrar(_nome.text.trim(), _email.text.trim(), _senha.text)
        : await session.entrar(_email.text.trim(), _senha.text);
    if (!mounted) return;
    setState(() => _carregando = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(session.erro ?? 'Falha ao entrar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite, size: 72, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text('CuidaBem', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              if (_cadastro)
                TextField(
                  controller: _nome,
                  decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
                ),
              if (_cadastro) const SizedBox(height: 12),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _senha,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _carregando ? null : _submeter,
                child: _carregando
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_cadastro ? 'Cadastrar' : 'Entrar'),
              ),
              TextButton(
                onPressed: () => setState(() => _cadastro = !_cadastro),
                child: Text(_cadastro ? 'Ja tenho conta' : 'Criar conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
