import 'package:flutter/material.dart';

/// Identidade visual do CuidaBem: emblema com icone de cuidado + marca.
class LogoCuidaBem extends StatelessWidget {
  final double tamanho;
  final bool comTexto;
  final bool claro; // versao para fundos escuros/coloridos

  const LogoCuidaBem({super.key, this.tamanho = 72, this.comTexto = true, this.claro = false});

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    final corTexto = claro ? Colors.white : cor.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: tamanho,
          height: tamanho,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D6B), Color(0xFF49B194)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(tamanho * 0.30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D6B).withValues(alpha: 0.30),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(Icons.volunteer_activism, color: Colors.white, size: tamanho * 0.52),
        ),
        if (comTexto) ...[
          SizedBox(height: tamanho * 0.16),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: 'Cuida',
                style: TextStyle(fontSize: tamanho * 0.34, fontWeight: FontWeight.w800, color: corTexto),
              ),
              TextSpan(
                text: 'Bem',
                style: TextStyle(fontSize: tamanho * 0.34, fontWeight: FontWeight.w300, color: corTexto),
              ),
            ]),
          ),
        ],
      ],
    );
  }
}
