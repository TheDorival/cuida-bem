import 'package:flutter/foundation.dart';
import '../models/grupo.dart';
import '../services/grupo_service.dart';

/// Controller de Grupos (UC002).
class GrupoProvider extends ChangeNotifier {
  final GrupoService service;
  GrupoProvider(this.service);

  List<Grupo> grupos = [];
  Grupo? selecionado;
  bool carregando = false;
  String? erro;

  Future<void> carregar() async {
    _inicio();
    try {
      grupos = await service.listar();
    } catch (e) {
      erro = e.toString();
    } finally {
      _fim();
    }
  }

  void selecionar(Grupo g) {
    selecionado = g;
    notifyListeners();
  }

  Future<bool> criar(String nome, String nomeIdoso) async {
    _inicio();
    try {
      final g = await service.criar(nome, nomeIdoso);
      grupos = [...grupos, g];
      return true;
    } catch (e) {
      erro = e.toString();
      return false;
    } finally {
      _fim();
    }
  }

  Future<Map<String, dynamic>?> convidar(String grupoId, {String? email, String? perfil}) async {
    try {
      return await service.convidar(grupoId, email: email, perfil: perfil);
    } catch (e) {
      erro = e.toString();
      notifyListeners();
      return null;
    }
  }

  void _inicio() {
    carregando = true;
    erro = null;
    notifyListeners();
  }

  void _fim() {
    carregando = false;
    notifyListeners();
  }
}
