/// Modelo de Grupo de Cuidado (UC002).
class Membro {
  final String usuarioId;
  final String perfil;
  Membro({required this.usuarioId, required this.perfil});

  factory Membro.fromJson(Map<String, dynamic> j) =>
      Membro(usuarioId: j['usuarioId'], perfil: j['perfil'] ?? '');
}

class Grupo {
  final String id;
  final String nome;
  final String nomeIdoso;
  final String cuidadorPrincipalId;
  final List<Membro> membros;

  Grupo({
    required this.id,
    required this.nome,
    required this.nomeIdoso,
    required this.cuidadorPrincipalId,
    required this.membros,
  });

  factory Grupo.fromJson(Map<String, dynamic> j) => Grupo(
        id: j['id'],
        nome: j['nome'] ?? '',
        nomeIdoso: j['nomeIdoso'] ?? '',
        cuidadorPrincipalId: j['cuidadorPrincipalId'] ?? '',
        membros: ((j['membros'] ?? []) as List)
            .map((m) => Membro.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
}
