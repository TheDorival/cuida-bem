import 'package:flutter/material.dart';

/// Estado vazio amigavel e acessivel, com icone grande e acao opcional.
class EstadoVazio extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String? descricao;
  final String? acaoRotulo;
  final VoidCallback? aoTocar;

  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    this.descricao,
    this.acaoRotulo,
    this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: cor.primaryContainer,
              child: Icon(icone, size: 44, color: cor.onPrimaryContainer),
            ),
            const SizedBox(height: 16),
            Text(titulo, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            if (descricao != null) ...[
              const SizedBox(height: 8),
              Text(descricao!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            ],
            if (acaoRotulo != null && aoTocar != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(onPressed: aoTocar, icon: const Icon(Icons.add), label: Text(acaoRotulo!)),
            ],
          ],
        ),
      ),
    );
  }
}
