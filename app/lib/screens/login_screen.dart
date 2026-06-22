import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_mode.dart';
import '../providers/session_provider.dart';
import '../widgets/logo.dart';

/// Tela de acesso (UC001): apresentacao em carrossel (boas-vindas + funcionalidades)
/// e, ao concluir ou pular, o formulario de login/cadastro via Firebase Auth.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _mostrarOnboarding = true;
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _cadastro = false;
  bool _carregando = false;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  String? _validarEmail(String? v) {
    final email = (v ?? '').trim();
    if (email.isEmpty) return 'Informe seu e-mail';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(email)) return 'E-mail invalido (ex.: nome@email.com)';
    return null;
  }

  String? _validarSenha(String? v) {
    final senha = v ?? '';
    if (senha.isEmpty) return 'Informe a senha';
    if (_cadastro && senha.length < 6) return 'A senha deve ter ao menos 6 caracteres';
    return null;
  }

  Future<void> _submeter() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _carregando = true);
    final session = context.read<SessionProvider>();
    final ok = _cadastro
        ? await session.cadastrar(_nome.text.trim(), _email.text.trim(), _senha.text)
        : await session.entrar(_email.text.trim(), _senha.text);
    if (!mounted) return;
    setState(() => _carregando = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(session.erro ?? 'Falha ao entrar')));
    }
  }

  Future<void> _recuperarSenha() async {
    final email = TextEditingController(text: _email.text.trim());
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Recuperar senha'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Informe seu e-mail. Enviaremos um link para redefinir a senha.'),
          const SizedBox(height: 12),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.mail_outline)),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Enviar')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final session = context.read<SessionProvider>();
    final sucesso = await session.recuperarSenha(email.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(sucesso
          ? 'Enviamos um link de redefinicao para o seu e-mail.'
          : (session.erro ?? 'Nao foi possivel enviar o e-mail')),
    ));
  }

  @override
  Widget build(BuildContext context) {
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
          child: _mostrarOnboarding
              ? _Onboarding(aoConcluir: () => setState(() => _mostrarOnboarding = false))
              : _formulario(context),
        ),
      ),
    );
  }

  Widget _formulario(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            children: [
              const LogoCuidaBem(tamanho: 80),
              const SizedBox(height: 12),
              Text(
                'Cuide de quem voce ama, em conjunto',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cor.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _cadastro ? 'Criar sua conta' : 'Entrar',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      if (_cadastro) ...[
                        TextFormField(
                          controller: _nome,
                          textInputAction: TextInputAction.next,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null,
                          decoration: const InputDecoration(labelText: 'Nome', prefixIcon: Icon(Icons.person_outline)),
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validarEmail,
                        decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.mail_outline)),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _senha,
                        obscureText: true,
                        onFieldSubmitted: (_) => _submeter(),
                        validator: _validarSenha,
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
                      if (!_cadastro)
                        TextButton(
                          onPressed: _carregando ? null : _recuperarSenha,
                          child: const Text('Esqueci minha senha'),
                        ),
                      if (kDemoMode)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cor.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Modo demonstracao: use um e-mail valido e qualquer senha.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('IFAL - Sistemas de Informacao',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cor.outline)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modelo de um slide de funcionalidade.
class _ItemSlide {
  final IconData icone;
  final String titulo;
  final String descricao;
  const _ItemSlide(this.icone, this.titulo, this.descricao);
}

const _slides = <_ItemSlide>[
  _ItemSlide(Icons.notifications_active, 'Rotinas e lembretes',
      'Cadastre rotinas de medicacao, alimentacao e higiene e receba alertas automaticos nos horarios certos.'),
  _ItemSlide(Icons.menu_book, 'Diario compartilhado',
      'Registre a saude do idoso e mantenha toda a familia informada em tempo real.'),
  _ItemSlide(Icons.insights, 'Relatorios de evolucao',
      'Gere relatorios em PDF da evolucao para compartilhar com profissionais de saude.'),
];

/// Carrossel de apresentacao (boas-vindas + funcionalidades) com indicador de
/// progresso, botao pular e transicao em fade + zoom suave.
class _Onboarding extends StatefulWidget {
  final VoidCallback aoConcluir;
  const _Onboarding({required this.aoConcluir});
  @override
  State<_Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<_Onboarding> {
  final _controle = PageController();
  int _pagina = 0;

  int get _total => _slides.length + 1; // boas-vindas + funcionalidades

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  void _proximo() {
    if (_pagina < _total - 1) {
      _controle.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    } else {
      widget.aoConcluir();
    }
  }

  // Aplica fade + leve zoom conforme a distancia do slide ao centro.
  Widget _animado(int index, Widget filho) {
    return AnimatedBuilder(
      animation: _controle,
      child: filho,
      builder: (context, child) {
        double delta;
        if (_controle.hasClients && _controle.position.haveDimensions) {
          delta = (_controle.page ?? _pagina.toDouble()) - index;
        } else {
          delta = (_pagina - index).toDouble();
        }
        final dist = delta.abs().clamp(0.0, 1.0);
        final opacidade = (1 - dist).clamp(0.0, 1.0);
        final escala = 0.82 + 0.18 * opacidade;
        return Opacity(opacity: opacidade, child: Transform.scale(scale: escala, child: child));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    final ultima = _pagina == _total - 1;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
          child: Row(
            children: [
              const LogoCuidaBem(tamanho: 32, comTexto: false),
              const SizedBox(width: 10),
              Text('CuidaBem', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cor.primary)),
              const Spacer(),
              TextButton(onPressed: widget.aoConcluir, child: const Text('Pular')),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _controle,
            itemCount: _total,
            onPageChanged: (i) => setState(() => _pagina = i),
            itemBuilder: (_, i) {
              final conteudo = i == 0 ? _boasVindas(context) : _slideView(context, _slides[i - 1]);
              return _animado(i, conteudo);
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_total, (i) {
            final ativo = i == _pagina;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: ativo ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: ativo ? cor.primary : cor.primary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _proximo,
              child: Text(ultima ? 'Comecar' : 'Proximo'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _boasVindas(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LogoCuidaBem(tamanho: 104),
          const SizedBox(height: 28),
          Text('Bem-vindo!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Organize o cuidado do idoso em familia, num so lugar.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: cor.onSurfaceVariant, height: 1.4)),
        ],
      ),
    );
  }

  Widget _slideView(BuildContext context, _ItemSlide s) {
    final cor = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(color: cor.primaryContainer, shape: BoxShape.circle),
            child: Icon(s.icone, size: 64, color: cor.onPrimaryContainer),
          ),
          const SizedBox(height: 36),
          Text(s.titulo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Text(s.descricao,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: cor.onSurfaceVariant, height: 1.4)),
        ],
      ),
    );
  }
}
