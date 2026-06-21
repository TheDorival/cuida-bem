import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/app_mode.dart';
import 'config/theme.dart';
import 'providers/session_provider.dart';
import 'providers/grupo_provider.dart';
import 'providers/rotina_provider.dart';
import 'providers/diario_provider.dart';
import 'providers/relatorio_provider.dart';
import 'screens/login_screen.dart';
import 'screens/grupos_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  late final SessionProvider session;
  if (kDemoMode) {
    // Modo demonstracao: sem Firebase e sem back-end.
    session = SessionProvider(demo: true);
  } else {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    session = SessionProvider();
    await session.restaurar();
  }

  runApp(CuidaBemApp(session: session));
}

/// Aplicativo CuidaBem 1.0 - camada View/Controller do cliente (MVC).
class CuidaBemApp extends StatelessWidget {
  final SessionProvider session;
  const CuidaBemApp({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: session),
        ChangeNotifierProvider(create: (_) => GrupoProvider(session.grupos)),
        ChangeNotifierProvider(create: (_) => RotinaProvider(session.rotinas)),
        ChangeNotifierProvider(create: (_) => DiarioProvider(session.diario)),
        ChangeNotifierProvider(create: (_) => RelatorioProvider(session.relatorios)),
      ],
      child: MaterialApp(
        title: 'CuidaBem',
        debugShowCheckedModeBanner: false,
        theme: CuidaBemTheme.light,
        home: const _Gate(),
      ),
    );
  }
}

/// Direciona para login ou painel conforme o estado de autenticacao.
class _Gate extends StatelessWidget {
  const _Gate();
  @override
  Widget build(BuildContext context) {
    final autenticado = context.watch<SessionProvider>().autenticado;
    return autenticado ? const GruposScreen() : const LoginScreen();
  }
}
