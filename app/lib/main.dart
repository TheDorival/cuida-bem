import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/session_provider.dart';
import 'providers/grupo_provider.dart';
import 'providers/rotina_provider.dart';
import 'providers/diario_provider.dart';
import 'providers/relatorio_provider.dart';
import 'screens/login_screen.dart';

void main() => runApp(const CuidaBemApp());

/// Aplicativo CuidaBem 1.0 - camada View/Controller do cliente (MVC).
class CuidaBemApp extends StatelessWidget {
  const CuidaBemApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionProvider();
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
        home: const LoginScreen(),
      ),
    );
  }
}
