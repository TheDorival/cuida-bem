import 'api_client.dart';
import '../models/entrada_diario.dart';

/// Servico do cliente para o UC004.
class DiarioService {
  final ApiClient api;
  DiarioService(this.api);

  Future<List<EntradaDiario>> listar(String grupoId, {List<String>? categorias}) async {
    final q = (categorias != null && categorias.isNotEmpty) ? '?categorias=${categorias.join(',')}' : '';
    final data = await api.get('/grupos/$grupoId/diario$q') as List;
    return data.map((e) => EntradaDiario.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<EntradaDiario> registrar(String grupoId, Map<String, dynamic> dados) async {
    final data = await api.post('/grupos/$grupoId/diario', dados);
    return EntradaDiario.fromJson(data as Map<String, dynamic>);
  }
}
