/// Modelo de Entrada do Diario de Saude (UC004).
class EntradaDiario {
  final String id;
  final String grupoId;
  final String categoria;
  final String descricao;
  final bool importante;
  final String? autorNome;
  final DateTime criadaEm;

  EntradaDiario({
    required this.id,
    required this.grupoId,
    required this.categoria,
    required this.descricao,
    required this.importante,
    required this.autorNome,
    required this.criadaEm,
  });

  factory EntradaDiario.fromJson(Map<String, dynamic> j) => EntradaDiario(
        id: j['id'],
        grupoId: j['grupoId'] ?? '',
        categoria: j['categoria'] ?? '',
        descricao: j['descricao'] ?? '',
        importante: j['importante'] ?? false,
        autorNome: j['autorNome'],
        criadaEm: DateTime.tryParse(j['criadaEm']?.toString() ?? '') ?? DateTime.now(),
      );
}
