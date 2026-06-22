import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'config/app_mode.dart';
import 'config/theme.dart';
import 'providers/tema_provider.dart';
import 'providers/session_provider.dart';
import 'providers/grupo_provider.dart';
import 'providers/rotina_provider.dart';
import 'providers/diario_provider.dart';
import 'providers/relatorio_provider.dart';
import 'screens/login_screen.dart';
import 'screens/grupos_screen.dart';

// Handler de mensagens FCM recebidas com o app em segundo plano (UC006).
@pragma('vm:entry-point')
Future<void> _fcmSegundoPlano(RemoteMessage message) async {
  // O sistema exibe a notificacao automaticamente; nada a fazer aqui.
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  late final SessionProvider session;
  if (kDemoMode) {
    // Modo demonstracao: sem Firebase e sem back-end.
    session = SessionProvider(demo: true);
  } else {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(_fcmSegundoPlano);
    session = SessionProvider();
    await session.restaurar();
  }

  final tema = TemaProvider();
  await tema.carregar();

  runApp(CuidaBemApp(session: session, tema: tema));
}

/// Aplicativo CuidaBem 1.0 - camada View/Controller do cliente (MVC).
class CuidaBemApp extends StatelessWidget {
  final SessionProvider session;
  final TemaProvider tema;
  const CuidaBemApp({super.key, required this.session, required this.tema});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: session),
        ChangeNotifierProvider.value(value: tema),
        ChangeNotifierProvider.value(value: session.fila),
        ChangeNotifierProvider(create: (_) => GrupoProvider(session.grupos)),
        ChangeNotifierProvider(create: (_) => RotinaProvider(session.rotinas)),
        ChangeNotifierProvider(create: (_) => DiarioProvider(session.diario)),
        ChangeNotifierProvider(create: (_) => RelatorioProvider(session.relatorios)),
      ],
      child: Consumer<TemaProvider>(
        builder: (context, tema, _) => MaterialApp(
          title: 'CuidaBem',
          debugShowCheckedModeBanner: false,
          theme: CuidaBemTheme.light,
          darkTheme: CuidaBemTheme.dark,
          themeMode: tema.modo,
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(
                textScaler: mq.textScaler.clamp(minScaleFactor: 1.05, maxScaleFactor: 1.4),
              ),
              child: child!,
            );
          },
          home: const _Gate(),
        ),
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
