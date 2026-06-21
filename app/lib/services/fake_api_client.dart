import 'api_client.dart';

/// Cliente de API falso para o modo demonstracao: responde com dados em memoria,
/// imitando os endpoints do back-end, sem rede. O estado persiste durante a sessao.
class FakeApiClient extends ApiClient {
  int _seq = 100;
  String _novoId(String p) => '${p}_${_seq++}';

  final List<Map<String, dynamic>> _grupos = [];
  final Map<String, List<Map<String, dynamic>>> _rotinas = {};
  final Map<String, List<Map<String, dynamic>>> _diario = {};
  final Map<String, List<Map<String, dynamic>>> _relatorios = {};

  FakeApiClient() {
    _semear();
  }

  void _semear() {
    _grupos.add({
      'id': 'grp_demo',
      'nome': 'Familia Silva',
      'nomeIdoso': 'Seu Jose',
      'cuidadorPrincipalId': 'demo-user',
      'membros': [
        {'usuarioId': 'demo-user', 'perfil': 'CUIDADOR_PRINCIPAL'},
        {'usuarioId': 'aux-1', 'perfil': 'CUIDADOR_AUXILIAR'},
      ],
    });
    _rotinas['grp_demo'] = [
      _rotina('grp_demo', 'MEDICACAO', 'Tomar Losartana', '08:00', 'DIARIA', 'PENDENTE'),
      _rotina('grp_demo', 'ALIMENTACAO', 'Cafe da manha', '07:30', 'DIARIA', 'CONCLUIDA'),
      _rotina('grp_demo', 'HIGIENE', 'Banho', '19:00', 'DIARIA', 'PENDENTE'),
    ];
    _diario['grp_demo'] = [
      _entrada('grp_demo', 'SAUDE', 'Pressao 12x8, estavel.', false,
          DateTime.now().subtract(const Duration(days: 1))),
      _entrada('grp_demo', 'OCORRENCIA', 'Pequena queda, sem ferimentos.', true, DateTime.now()),
    ];
    _relatorios['grp_demo'] = [];
  }

  Map<String, dynamic> _rotina(String g, String tipo, String desc, String hora, String freq, String status) =>
      {
        'id': _novoId('rot'),
        'grupoId': g,
        'tipo': tipo,
        'descricao': desc,
        'horario': hora,
        'frequencia': freq,
        'status': status,
        'ativa': true,
      };

  Map<String, dynamic> _entrada(String g, String cat, String desc, bool imp, DateTime quando) => {
        'id': _novoId('dia'),
        'grupoId': g,
        'categoria': cat,
        'descricao': desc,
        'importante': imp,
        'autorNome': 'Ana (demo)',
        'criadaEm': quando.toIso8601String(),
      };

  Future<T> _resp<T>(T valor) =>
      Future.delayed(const Duration(milliseconds: 120), () => valor);

  List<String> _segmentos(String path) =>
      path.replaceFirst(RegExp(r'^/'), '').split('?').first.split('/');

  @override
  Future<dynamic> get(String path) async {
    final s = _segmentos(path);
    if (s.length == 1 && s[0] == 'grupos') return _resp(_grupos);
    if (s.length >= 3 && s[0] == 'grupos') {
      final gid = s[1];
      switch (s[2]) {
        case 'rotinas':
          return _resp(_rotinas[gid] ?? []);
        case 'diario':
          return _resp(_diario[gid] ?? []);
        case 'relatorios':
          return _resp(_relatorios[gid] ?? []);
      }
    }
    return _resp([]);
  }

  @override
  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    final b = body ?? {};
    final s = _segmentos(path);

    if (s.length == 1 && s[0] == 'grupos') {
      final g = {
        'id': _novoId('grp'),
        'nome': b['nome'] ?? 'Novo grupo',
        'nomeIdoso': b['nomeIdoso'] ?? '',
        'cuidadorPrincipalId': 'demo-user',
        'membros': [
          {'usuarioId': 'demo-user', 'perfil': 'CUIDADOR_PRINCIPAL'},
        ],
      };
      _grupos.add(g);
      _rotinas[g['id'] as String] = [];
      _diario[g['id'] as String] = [];
      _relatorios[g['id'] as String] = [];
      return _resp(g);
    }

    if (s.length >= 3 && s[0] == 'grupos') {
      final gid = s[1];
      // grupos/:id/convites
      if (s[2] == 'convites' && s.length == 3) {
        final token = _novoId('cv');
        return _resp({'token': token, 'link': 'demo://convite/$token', 'email': b['email']});
      }
      // grupos/:id/rotinas
      if (s[2] == 'rotinas' && s.length == 3) {
        final r = _rotina(gid, b['tipo'] ?? 'OUTRO', b['descricao'] ?? '', b['horario'] ?? '08:00',
            b['frequencia'] ?? 'DIARIA', 'PENDENTE');
        (_rotinas[gid] ??= []).add(r);
        return _resp({'rotina': r, 'alertaAgendado': true});
      }
      // grupos/:id/rotinas/:rid/(concluir|desativar)
      if (s[2] == 'rotinas' && s.length == 5) {
        final r = (_rotinas[gid] ?? []).firstWhere((x) => x['id'] == s[3], orElse: () => {});
        if (r.isNotEmpty) {
          if (s[4] == 'concluir') r['status'] = 'CONCLUIDA';
          if (s[4] == 'desativar') {
            r['ativa'] = false;
            r['status'] = 'DESATIVADA';
          }
        }
        return _resp(r);
      }
      // grupos/:id/diario
      if (s[2] == 'diario' && s.length == 3) {
        final e = _entrada(gid, b['categoria'] ?? 'OUTRO', b['descricao'] ?? '',
            b['importante'] == true, DateTime.now());
        (_diario[gid] ??= []).add(e);
        return _resp(e);
      }
      // grupos/:id/relatorios
      if (s[2] == 'relatorios' && s.length == 3) {
        final lista = _diario[gid] ?? [];
        final rel = {
          'id': _novoId('rel'),
          'grupoId': gid,
          'periodoInicio': b['periodoInicio'],
          'periodoFim': b['periodoFim'],
          'categorias': b['categorias'] ?? [],
          'urlPdf': 'demo://relatorio.pdf',
          'totalEntradas': lista.length,
          'versao': (_relatorios[gid] ?? []).length + 1,
        };
        (_relatorios[gid] ??= []).insert(0, rel);
        return _resp(rel);
      }
    }
    return _resp({});
  }

  @override
  Future<dynamic> patch(String path, [Map<String, dynamic>? body]) async => _resp({});

  @override
  Future<dynamic> delete(String path) async {
    final s = _segmentos(path);
    // grupos/:id/membros/:usuarioId
    if (s.length == 4 && s[0] == 'grupos' && s[2] == 'membros') {
      final g = _grupos.firstWhere((x) => x['id'] == s[1], orElse: () => {});
      if (g.isNotEmpty) {
        (g['membros'] as List).removeWhere((m) => m['usuarioId'] == s[3]);
      }
      return _resp(g);
    }
    return _resp({});
  }
}
