import 'package:flutter/material.dart';
import '../models/grupo.dart';
import 'rotinas_screen.dart';
import 'diario_screen.dart';
import 'relatorios_screen.dart';

/// Painel do grupo com navegacao entre Rotinas (UC003), Diario (UC004) e Relatorios (UC007).
class GrupoHomeScreen extends StatefulWidget {
  final Grupo grupo;
  const GrupoHomeScreen({super.key, required this.grupo});
  @override
  State<GrupoHomeScreen> createState() => _GrupoHomeScreenState();
}

class _GrupoHomeScreenState extends State<GrupoHomeScreen> {
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    final telas = [
      RotinasScreen(grupo: widget.grupo),
      DiarioScreen(grupo: widget.grupo),
      RelatoriosScreen(grupo: widget.grupo),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(widget.grupo.nome)),
      body: telas[_indice],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Rotinas'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Diario'),
          NavigationDestination(icon: Icon(Icons.picture_as_pdf), label: 'Relatorios'),
        ],
      ),
    );
  }
}
