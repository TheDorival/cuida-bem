import 'package:flutter/foundation.dart';
import '../models/relatorio.dart';
import '../services/relatorio_service.dart';

/// Controller de Relatorios de Evolucao (UC007).
class RelatorioProvider extends ChangeNotifier {
  final RelatorioService service;
  RelatorioProvider(this.service);

  List<Relatorio> relatorios = [];
  bool carregando = false;
  String? erro;

  Future<void> carregar(String grupoId) async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      relatorios = await service.listar(grupoId);
    } catch (e) {
      erro = e.toString();
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<Relatorio?> gerar(String grupoId, DateTime inicio, DateTime fim, List<String> categorias) async {
    try {
      final r = await service.gerar(grupoId, inicio, fim, categorias);
      await carregar(grupoId);
      return r;
    } catch (e) {
      erro = e.toString();
      notifyListeners();
      return null;
    }
  }
}
