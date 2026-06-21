import 'package:flutter/material.dart';

/// Aviso de que ha falha de conexao, exibido acima dos dados ja carregados
/// (resiliencia offline de leitura - FE02).
class BannerConexao extends StatelessWidget {
  final VoidCallback? aoTentar;
  const BannerConexao({super.key, this.aoTentar});

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    return Material(
      color: cor.errorContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          children: [
            Icon(Icons.cloud_off, size: 18, color: cor.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Sem conexao - exibindo dados salvos',
                  style: TextStyle(color: cor.onErrorContainer, fontSize: 13)),
            ),
            if (aoTentar != null)
              TextButton(onPressed: aoTentar, child: const Text('Atualizar')),
          ],
        ),
      ),
    );
  }
}
