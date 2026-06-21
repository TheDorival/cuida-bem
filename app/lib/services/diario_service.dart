import 'api_client.dart';
import '../models/entrada_diario.dart';

/// Servico do cliente para o UC004.
class DiarioService {
  final ApiClient api;
  DiarioService(this.api);

  Future<List<EntradaDiario>> listar(String grupoId,
      {List<String>? categorias, DateTime? dataInicio, DateTime? dataFim}) async {
    final params = <String>[];
    if (categorias != null && categorias.isNotEmpty) params.add('categorias=${categorias.join(',')}');
    if (dataInicio != null) params.add('dataInicio=${dataInicio.toIso8601String()}');
    if (dataFim != null) params.add('dataFim=${dataFim.toIso8601String()}');
    final q = params.isEmpty ? '' : '?${params.join('&')}';
    final data = await api.get('/grupos/$grupoId/diario$q') as List;
    return data.map((e) => EntradaDiario.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<EntradaDiario> registrar(String grupoId, Map<String, dynamic> dados) async {
    final data = await api.post('/grupos/$grupoId/diario', dados);
    return EntradaDiario.fromJson(data as Map<String, dynamic>);
  }
}
