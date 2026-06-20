import 'api_client.dart';
import '../models/grupo.dart';

/// Servico do cliente para o UC002.
class GrupoService {
  final ApiClient api;
  GrupoService(this.api);

  Future<List<Grupo>> listar() async {
    final data = await api.get('/grupos') as List;
    return data.map((g) => Grupo.fromJson(g as Map<String, dynamic>)).toList();
  }

  Future<Grupo> criar(String nome, String nomeIdoso) async {
    final data = await api.post('/grupos', {'nome': nome, 'nomeIdoso': nomeIdoso});
    return Grupo.fromJson(data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> convidar(String grupoId, {String? email, String? perfil}) async {
    final data = await api.post('/grupos/$grupoId/convites', {
      if (email != null) 'email': email,
      if (perfil != null) 'perfil': perfil,
    });
    return data as Map<String, dynamic>;
  }

  Future<Grupo> aceitarConvite(String token) async {
    final data = await api.post('/grupos/convites/$token/aceitar');
    return Grupo.fromJson(data as Map<String, dynamic>);
  }

  Future<void> removerMembro(String grupoId, String usuarioId) =>
      api.delete('/grupos/$grupoId/membros/$usuarioId');
}
