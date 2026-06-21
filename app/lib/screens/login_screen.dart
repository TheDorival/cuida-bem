import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_mode.dart';
import '../providers/session_provider.dart';
import '../widgets/logo.dart';

/// Tela de acesso (UC001): apresentacao do app + login e cadastro via Firebase Auth.
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
    final cor = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF3F0), Color(0xFFF6F8F7)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const LogoCuidaBem(tamanho: 84),
                    const SizedBox(height: 14),
                    Text(
                      'Cuide de quem voce ama, em conjunto',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cor.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    _destaques(context),
                    const SizedBox(height: 24),
                    _cartaoFormulario(context),
                    const SizedBox(height: 20),
                    Text(
                      'IFAL - Sistemas de Informacao',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cor.outline),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _destaques(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        _Destaque(icone: Icons.notifications_active, rotulo: 'Lembretes\nde rotina'),
        _Destaque(icone: Icons.menu_book, rotulo: 'Diario\ncompartilhado'),
        _Destaque(icone: Icons.insights, rotulo: 'Relatorios\nde evolucao'),
      ],
    );
  }

  Widget _cartaoFormulario(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _cadastro ? 'Criar sua conta' : 'Entrar',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            if (_cadastro) ...[
              TextField(
                controller: _nome,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Nome', prefixIcon: Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.mail_outline)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _senha,
              obscureText: true,
              onSubmitted: (_) => _submeter(),
              decoration: const InputDecoration(labelText: 'Senha', prefixIcon: Icon(Icons.lock_outline)),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _carregando ? null : _submeter,
              child: _carregando
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_cadastro ? 'Cadastrar' : 'Entrar'),
            ),
            TextButton(
              onPressed: _carregando ? null : () => setState(() => _cadastro = !_cadastro),
              child: Text(_cadastro ? 'Ja tenho conta - entrar' : 'Nao tem conta? Cadastre-se'),
            ),
            if (kDemoMode)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Modo demonstracao: use qualquer e-mail e senha para entrar.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Destaque extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  const _Destaque({required this.icone, required this.rotulo});

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    return Column(
      children: [
        CircleAvatar(radius: 26, backgroundColor: cor.primaryContainer, child: Icon(icone, color: cor.onPrimaryContainer)),
        const SizedBox(height: 8),
        Text(rotulo, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
