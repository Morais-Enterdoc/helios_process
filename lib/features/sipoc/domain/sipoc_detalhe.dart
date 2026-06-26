import 'sipoc.dart';

class SipocDetalhe {
  final Sipoc sipoc;
  final String clienteNome;
  final String clienteLogoPath;
  final String setorNome;

  const SipocDetalhe({
    required this.sipoc,
    required this.clienteNome,
    required this.clienteLogoPath,
    required this.setorNome,
  });

  factory SipocDetalhe.fromMap(Map<String, dynamic> map) {
    return SipocDetalhe(
      sipoc: Sipoc.fromMap(map),
      clienteNome: map['cliente_nome']?.toString() ?? 'Cliente não encontrado',
      clienteLogoPath: map['cliente_logo_path']?.toString() ?? '',
      setorNome: map['setor_nome']?.toString() ?? 'Setor não encontrado',
    );
  }
}