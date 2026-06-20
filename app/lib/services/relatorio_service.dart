import 'api_client.dart';
import '../models/relatorio.dart';

/// Servico do cliente para o UC007.
class RelatorioService {
  final ApiClient api;
  RelatorioService(this.api);

  Future<List<Relatorio>> listar(String grupoId) async {
    final data = await api.get('/grupos/$grupoId/relatorios') as List;
    return data.map((r) => Relatorio.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<Relatorio> gerar(String grupoId, DateTime inicio, DateTime fim, List<String> categorias) async {
    final data = await api.post('/grupos/$grupoId/relatorios', {
      'periodoInicio': inicio.toIso8601String(),
      'periodoFim': fim.toIso8601String(),
      'categorias': categorias,
    });
    return Relatorio.fromJson(data as Map<String, dynamic>);
  }
}
