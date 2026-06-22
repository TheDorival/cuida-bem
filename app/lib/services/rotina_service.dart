import 'api_client.dart';
import '../models/rotina.dart';

/// Servico do cliente para o UC003.
class RotinaService {
  final ApiClient api;
  RotinaService(this.api);

  Future<List<Rotina>> listar(String grupoId, {bool apenasAtivas = false}) async {
    final data = await api.get('/grupos/$grupoId/rotinas${apenasAtivas ? '?ativas=true' : ''}') as List;
    return data.map((r) => Rotina.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<Rotina> criar(String grupoId, Map<String, dynamic> dados) async {
    final data = await api.post('/grupos/$grupoId/rotinas', dados);
    return Rotina.fromJson((data as Map<String, dynamic>)['rotina'] as Map<String, dynamic>);
  }

  Future<Rotina> editar(String grupoId, String rotinaId, Map<String, dynamic> dados) async {
    final data = await api.patch('/grupos/$grupoId/rotinas/$rotinaId', dados);
    return Rotina.fromJson(data as Map<String, dynamic>);
  }

  Future<Rotina> concluir(String grupoId, String rotinaId) async {
    final data = await api.post('/grupos/$grupoId/rotinas/$rotinaId/concluir');
    return Rotina.fromJson(data as Map<String, dynamic>);
  }

  Future<Rotina> desativar(String grupoId, String rotinaId) async {
    final data = await api.post('/grupos/$grupoId/rotinas/$rotinaId/desativar');
    return Rotina.fromJson(data as Map<String, dynamic>);
  }
}
