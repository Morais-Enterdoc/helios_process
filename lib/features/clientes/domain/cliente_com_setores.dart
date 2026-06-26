import 'cliente.dart';
import 'setor.dart';

class ClienteComSetores {
  final Cliente cliente;
  final List<Setor> setores;

  const ClienteComSetores({
    required this.cliente,
    required this.setores,
  });
}