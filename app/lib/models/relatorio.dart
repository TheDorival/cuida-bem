/// Modelo de Relatorio de Evolucao (UC007).
class Relatorio {
  final String id;
  final String grupoId;
  final DateTime periodoInicio;
  final DateTime periodoFim;
  final List<String> categorias;
  final String? urlPdf;
  final int totalEntradas;
  final int versao;

  Relatorio({
    required this.id,
    required this.grupoId,
    required this.periodoInicio,
    required this.periodoFim,
    required this.categorias,
    required this.urlPdf,
    required this.totalEntradas,
    required this.versao,
  });

  factory Relatorio.fromJson(Map<String, dynamic> j) => Relatorio(
        id: j['id'],
        grupoId: j['grupoId'] ?? '',
        periodoInicio: DateTime.tryParse(j['periodoInicio']?.toString() ?? '') ?? DateTime.now(),
        periodoFim: DateTime.tryParse(j['periodoFim']?.toString() ?? '') ?? DateTime.now(),
        categorias: ((j['categorias'] ?? []) as List).map((e) => e.toString()).toList(),
        urlPdf: j['urlPdf'],
        totalEntradas: j['totalEntradas'] ?? 0,
        versao: j['versao'] ?? 1,
      );
}
