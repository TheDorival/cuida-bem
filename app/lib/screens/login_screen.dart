import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import 'grupos_screen.dart';

/// Tela de acesso (UC001). Em desenvolvimento, informe o id do usuario como token.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = TextEditingController();

  void _entrar() {
    final token = _controller.text.trim();
    if (token.isEmpty) return;
    context.read<SessionProvider>().entrar(token);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GruposScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite, size: 72, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text('CuidaBem', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Token de acesso',
                  border: OutlineInputBorder(),
                  helperText: 'Dev: informe o id do usuario',
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _entrar,
                child: const Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
