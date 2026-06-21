import 'package:flutter_test/flutter_test.dart';

import 'package:cuida_bem/services/fake_api_client.dart';

void main() {
  test('FakeApiClient lista grupos de demonstracao', () async {
    final api = FakeApiClient();
    final grupos = await api.get('/grupos') as List;
    expect(grupos, isNotEmpty);
    expect(grupos.first['nome'], 'Familia Silva');
  });

  test('FakeApiClient cria rotina e ela aparece na listagem', () async {
    final api = FakeApiClient();
    await api.post('/grupos/grp_demo/rotinas',
        {'tipo': 'MEDICACAO', 'descricao': 'Dipirona', 'horario': '12:00', 'frequencia': 'DIARIA'});
    final rotinas = await api.get('/grupos/grp_demo/rotinas') as List;
    expect(rotinas.any((r) => r['descricao'] == 'Dipirona'), isTrue);
  });
}
