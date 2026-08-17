/* ================================================================== *
 *  MODELOS — as "fichas" de dados que o app usa
 * ================================================================== */

/// Um pedido/entrega
class Pedido {
  final String id;
  final String endereco;
  final String bairro;
  final String km;
  final int itens;
  final String pagamento;

  /// quanto o entregador ganha nessa corrida
  final double valor;

  // ---- dados usados na tela de detalhes ----
  final String cliente;
  final String complemento;
  final String observacao;

  /// quanto ele precisa receber do cliente (0 se já está pago)
  final double aReceber;

  /// para quanto o cliente vai pagar (0 se não precisa de troco)
  final double trocoPara;

  const Pedido({
    required this.id,
    required this.endereco,
    required this.bairro,
    required this.km,
    required this.itens,
    required this.pagamento,
    required this.valor,
    this.cliente = '',
    this.complemento = '',
    this.observacao = '',
    this.aReceber = 0,
    this.trocoPara = 0,
  });

  String get valorFormatado => _reais(valor);
  String get valorCurto => 'R\$ ${valor.toStringAsFixed(0)}';
  double get kmNumero =>
      double.tryParse(km.replaceAll(',', '.')) ?? 0;

  bool get precisaTroco => trocoPara > aReceber && aReceber > 0;
  double get troco => trocoPara - aReceber;
}

String _reais(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';
String reais(double v) => _reais(v);

/// Um pedido que já foi aceito e está em andamento
class EntregaAtiva {
  final Pedido pedido;

  /// false = aceito, aguardando sair. true = já saiu para entrega
  bool emRota;

  EntregaAtiva(this.pedido, {this.emRota = false});
}

/// Uma entrega já concluída (usada no histórico)
class EntregaFeita {
  final String id;
  final String endereco;
  final String hora;
  final String km;
  final String pagamento;
  final double valor;
  final DateTime data;

  const EntregaFeita({
    required this.id,
    required this.endereco,
    required this.hora,
    required this.km,
    required this.pagamento,
    required this.valor,
    required this.data,
  });
}

/* ---- pedidos de exemplo usados pelo botão "Simular novo pedido" ---- */
const pedidosExemplo = [
  Pedido(
    id: 'P1042',
    endereco: 'Rua Padre Valdevino, 800',
    bairro: 'Aldeota',
    km: '3,2',
    itens: 3,
    pagamento: 'Dinheiro',
    valor: 8,
    cliente: 'Maria Souza',
    complemento: 'apto 302',
    observacao: 'Portão azul, tocar campainha 2x. Apartamento 302.',
    aReceber: 68,
    trocoPara: 100,
  ),
  Pedido(
    id: 'P1043',
    endereco: 'Av. Dom Luís, 1200',
    bairro: 'Meireles',
    km: '5,1',
    itens: 2,
    pagamento: 'PIX',
    valor: 12,
    cliente: 'João Pereira',
    complemento: 'sala 14',
    observacao: 'Entregar na recepção do prédio.',
  ),
  Pedido(
    id: 'P1044',
    endereco: 'Rua Silva Jatahy, 45',
    bairro: 'Centro',
    km: '1,8',
    itens: 5,
    pagamento: 'Cartão',
    valor: 9,
    cliente: 'Ana Lima',
    complemento: 'casa',
    observacao: 'Cachorro no quintal, chamar do portão.',
  ),
];
