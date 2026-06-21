import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/grupo.dart';
import '../providers/session_provider.dart';
import 'dashboard_screen.dart';
import 'membros_screen.dart';
import 'rotinas_screen.dart';
import 'diario_screen.dart';
import 'relatorios_screen.dart';

/// Painel do grupo: Inicio (dashboard), Rotinas (UC003), Diario (UC004) e
/// Relatorios (UC007), com acoes de membros e sair na barra superior.
class GrupoHomeScreen extends StatefulWidget {
  final Grupo grupo;
  const GrupoHomeScreen({super.key, required this.grupo});
  @override
  State<GrupoHomeScreen> createState() => _GrupoHomeScreenState();
}

class _GrupoHomeScreenState extends State<GrupoHomeScreen> {
  int _indice = 0;

  static const _titulos = ['Inicio', 'Rotinas', 'Diario', 'Relatorios'];

  Future<void> _sair() async {
    await context.read<SessionProvider>().sair();
    if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final telas = [
      DashboardScreen(grupo: widget.grupo, aoIrPara: (i) => setState(() => _indice = i)),
      RotinasScreen(grupo: widget.grupo),
      DiarioScreen(grupo: widget.grupo),
      RelatoriosScreen(grupo: widget.grupo),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.grupo.nome} - ${_titulos[_indice]}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'sair') _sair();
              if (v == 'membros') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => MembrosScreen(grupoId: widget.grupo.id)),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'membros', child: Row(children: [Icon(Icons.groups), SizedBox(width: 8), Text('Membros')])),
              PopupMenuItem(value: 'sair', child: Row(children: [Icon(Icons.logout), SizedBox(width: 8), Text('Sair')])),
            ],
          ),
        ],
      ),
      body: telas[_indice],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.checklist_outlined), selectedIcon: Icon(Icons.checklist), label: 'Rotinas'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Diario'),
          NavigationDestination(icon: Icon(Icons.picture_as_pdf_outlined), selectedIcon: Icon(Icons.picture_as_pdf), label: 'Relatorios'),
        ],
      ),
    );
  }
}
