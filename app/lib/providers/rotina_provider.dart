import 'package:flutter/foundation.dart';
import '../models/rotina.dart';
import '../services/rotina_service.dart';

/// Controller de Rotinas (UC003).
class RotinaProvider extends ChangeNotifier {
  final RotinaService service;
  RotinaProvider(this.service);

  List<Rotina> rotinas = [];
  bool carregando = false;
  String? erro;

  Future<void> carregar(String grupoId) async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      rotinas = await service.listar(grupoId, apenasAtivas: true);
    } catch (e) {
      erro = e.toString();
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> criar(String grupoId, Map<String, dynamic> dados) async {
    try {
      await service.criar(grupoId, dados);
      await carregar(grupoId);
      return true;
    } catch (e) {
      erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> editar(String grupoId, String rotinaId, Map<String, dynamic> dados) async {
    try {
      await service.editar(grupoId, rotinaId, dados);
      await carregar(grupoId);
      return true;
    } catch (e) {
      erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> concluir(String grupoId, String rotinaId) async {
    try {
    