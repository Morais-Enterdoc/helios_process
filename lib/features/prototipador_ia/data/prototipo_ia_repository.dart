import '../domain/prototipo_ia.dart';

class PrototipoIaRepository {
  final List<PrototipoIa> _prototipos = [];

  List<PrototipoIa> listarTodos() {
    return List.unmodifiable(_prototipos);
  }

  PrototipoIa? buscarPorId(String id) {
    try {
      return _prototipos.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  void salvar(PrototipoIa prototipo) {
    final index = _prototipos.indexWhere((item) => item.id == prototipo.id);

    if (index >= 0) {
      _prototipos[index] = prototipo;
    } else {
      _prototipos.add(prototipo);
    }
  }

  void removerPorId(String id) {
    _prototipos.removeWhere((item) => item.id == id);
  }

  void limparTudo() {
    _prototipos.clear();
  }
}