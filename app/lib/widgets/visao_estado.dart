import 'package:flutter/material.dart';

/// Indicador de carregamento centralizado.
class Carregando extends StatelessWidget {
  const Carregando({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator());
}

/// Exibicao de erro com opcao de tentar novamente.
class ErroView extends StatelessWidget {
  final String mensagem;
  final VoidCallback? aoTentar;
  const ErroView({super.key, required this.mensagem, this.aoTentar});

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: cor.error),
            const SizedBox(height: 12),
            Text(mensagem, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            if (aoTentar != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(onPressed: aoTentar, icon: const Icon(Icons.refresh), label: const Text('Tentar novamente')),
            ],
          ],
        ),
      ),
    );
  }
}
