import 'package:flutter/foundation.dart';
import '../models/entrada_diario.dart';
import '../services/diario_service.dart';

/// Controller do Diario de Saude (UC004).
class DiarioProvider extends ChangeNotifier {
  final DiarioService service;
  DiarioProvider(this.service);

  List<EntradaDiario> entradas = [];
  bool carregando = false;
  String? erro;

  Future<void> carregar(String grupoId, {List<String>? categorias}) async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      entradas = await service.listar(grupoId, categorias: categorias);
    } catch (e) {
      erro = e.toString();
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> registrar(String grupoId, Map<String, dynamic> dados) async {
    try {
      await service.registrar(grupoId, dados);
      await carregar(grupoId);
      return true;
    } catch (e) {
      erro = e.toString();
      notifyListeners();
      return false;
    }
  }
}
