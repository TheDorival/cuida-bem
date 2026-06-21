import 'package:flutter/material.dart';

/// Item de uma faixa de resumo (icone + valor + rotulo).
class ItemResumo {
  final IconData icone;
  final Color cor;
  final String valor;
  final String rotulo;
  const ItemResumo({required this.icone, required this.cor, required this.valor, required this.rotulo});
}

/// Faixa horizontal de resumo exibida no topo das telas, dando contexto rapido.
class FaixaResumo extends StatelessWidget {
  final List<ItemResumo> itens;
  const FaixaResumo({super.key, required this.itens});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Row(
        children: itens
            .map((i) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: i.cor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(i.icone, color: i.cor, size: 20),
                        const SizedBox(width: 8),
                        Text(i.valor, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: i.cor)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(i.rotulo,
                              style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
