import 'package:flutter/material.dart';

/// Rotulos, icones e cores amigaveis (pt-BR) para os valores de dominio.
class Visual {
  final String rotulo;
  final IconData icone;
  final Color cor;
  const Visual(this.rotulo, this.icone, this.cor);
}

const Map<String, Visual> categorias = {
  'SAUDE': Visual('Saude', Icons.favorite, Color(0xFFE05B5B)),
  'MEDICACAO': Visual('Medicacao', Icons.medication, Color(0xFF3E78C8)),
  'ALIMENTACAO': Visual('Alimentacao', Icons.restaurant, Color(0xFFE0852E)),
  'HUMOR': Visual('Humor', Icons.mood, Color(0xFF8A5FC8)),
  'OCORRENCIA': Visual('Ocorrencia', Icons.report_problem, Color(0xFFD9A407)),
  'OUTRO': Visual('Outro', Icons.notes, Color(0xFF6B7280)),
};

const Map<String, Visual> tiposRotina = {
  'MEDICACAO': Visual('Medicacao', Icons.medication, Color(0xFF3E78C8)),
  'ALIMENTACAO': Visual('Alimentacao', Icons.restaurant, Color(0xFFE0852E)),
  'HIGIENE': Visual('Higiene', Icons.clean_hands, Color(0xFF2E9E8F)),
  'OUTRO': Visual('Outro', Icons.checklist, Color(0xFF6B7280)),
};

const Map<String, Visual> statusRotina = {
  'PENDENTE': Visual('Pendente', Icons.schedule, Color(0xFFE0852E)),
  'CONCLUIDA': Visual('Concluida', Icons.check_circle, Color(0xFF2E9E5B)),
  'DESATIVADA': Visual('Desativada', Icons.block, Color(0xFF9AA0A6)),
};

const Map<String, String> frequencias = {
  'DIARIA': 'Diaria',
  'SEMANAL': 'Semanal',
  'MENSAL': 'Mensal',
  'UNICA': 'Unica',
};

const Map<String, String> perfis = {
  'CUIDADOR_PRINCIPAL': 'Cuidador principal',
  'CUIDADOR_AUXILIAR': 'Cuidador auxiliar',
  'FAMILIAR': 'Familiar',
  'PROFISSIONAL_SAUDE': 'Profissional de saude',
};

Visual visualCategoria(String c) => categorias[c] ?? categorias['OUTRO']!;
Visual visualTipo(String t) => tiposRotina[t] ?? tiposRotina['OUTRO']!;
Visual visualStatus(String s) => statusRotina[s] ?? statusRotina['PENDENTE']!;
