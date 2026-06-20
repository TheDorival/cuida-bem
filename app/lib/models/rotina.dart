/// Modelo de Rotina de Cuidado (UC003).
class Rotina {
  final String id;
  final String grupoId;
  final String tipo;
  final String descricao;
  final String horario;
  final String frequencia;
  final String status;
  final bool ativa;

  Rotina({
    required this.id,
    required this.grupoId,
    required this.tipo,
    required this.descricao,
    required this.horario,
    required this.frequencia,
    required this.status,
    required this.ativa,
  });

  factory Rotina.fromJson(Map<String, dynamic> j) => Rotina(
        id: j['id'],
        grupoId: j['grupoId'] ?? '',
        tipo: j['tipo'] ?? '',
        descricao: j['descricao'] ?? '',
        horario: j['horario'] ?? '',
        frequencia: j['frequencia'] ?? '',
        status: j['status'] ?? 'PENDENTE',
        ativa: j['ativa'] ?? true,
      );
}
