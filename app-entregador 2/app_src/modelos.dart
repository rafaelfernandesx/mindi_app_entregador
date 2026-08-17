/* ================================================================== *
 *  MODELOS — traduzem o JSON da API para o app
 * ================================================================== */

/// converte "8.00", 8, 8.0 ou null em número
double _num(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0;
  return 0;
}

int _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('$v') ?? 0;
}

String reais(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';
String reaisCurto(double v) => 'R\$ ${v.toStringAsFixed(0)}';

/// nome bonito da forma de pagamento
String formaPagamento(String? p) {
  switch ((p ?? '').toLowerCase()) {
    case 'cash':
    case 'dinheiro':
      return 'Dinheiro';
    case 'pix':
      return 'PIX';
    case 'card':
    case 'credit':
    case 'debit':
    case 'cartao':
      return 'Cartão';
    case 'online':
      return 'Pago online';
    default:
      return p == null || p.isEmpty ? '—' : p;
  }
}

/* ================================================================== *
 *  PEDIDO
 * ================================================================== */
class Pedido {
  final int id;
  final String numero; // "#P0045"
  final String cliente;
  final String endereco;
  final String status;

  /// quanto o entregador ganha
  final double taxa;

  /// valor do pedido (o que o cliente paga)
  final double total;

  final int itens;
  final String pagamento;

  // ---- só vêm no detalhe ----
  final String? telefone;
  final String? observacao;
  final double trocoPara;
  final String? mapsUrl;
  final List<String> produtos;

  const Pedido({
    required this.id,
    required this.numero,
    required this.cliente,
    required this.endereco,
    required this.status,
    required this.taxa,
    required this.total,
    required this.itens,
    required this.pagamento,
    this.telefone,
    this.observacao,
    this.trocoPara = 0,
    this.mapsUrl,
    this.produtos = const [],
  });

  factory Pedido.fromJson(Map<String, dynamic> j) {
    final itensLista = (j['items'] is List) ? (j['items'] as List) : const [];
    return Pedido(
      id: _int(j['id']),
      numero: (j['orderNumber'] ?? '#${j['id']}').toString(),
      cliente: (j['customerName'] ?? '').toString(),
      endereco: (j['customerAddress'] ?? '').toString(),
      status: (j['status'] ?? '').toString(),
      taxa: _num(j['deliveryFee']),
      total: _num(j['total']),
      itens: j['itemCount'] != null ? _int(j['itemCount']) : itensLista.length,
      pagamento: formaPagamento(j['paymentMethod']?.toString()),
      telefone: j['customerPhone']?.toString(),
      observacao: j['notes']?.toString(),
      trocoPara: _num(j['changeAmount']),
      mapsUrl: j['mapsUrl']?.toString(),
      produtos: itensLista
          .whereType<Map>()
          .map((i) => '${_int(i['quantity'])}x ${i['name']}')
          .toList(),
    );
  }

  /// junta o detalhe novo com o que já tínhamos
  Pedido comDetalhe(Pedido d) => Pedido(
        id: d.id,
        numero: d.numero.isNotEmpty ? d.numero : numero,
        cliente: d.cliente.isNotEmpty ? d.cliente : cliente,
        endereco: d.endereco.isNotEmpty ? d.endereco : endereco,
        status: d.status.isNotEmpty ? d.status : status,
        taxa: d.taxa > 0 ? d.taxa : taxa,
        total: d.total > 0 ? d.total : total,
        itens: d.itens > 0 ? d.itens : itens,
        pagamento: d.pagamento != '—' ? d.pagamento : pagamento,
        telefone: d.telefone ?? telefone,
        observacao: d.observacao ?? observacao,
        trocoPara: d.trocoPara > 0 ? d.trocoPara : trocoPara,
        mapsUrl: d.mapsUrl ?? mapsUrl,
        produtos: d.produtos.isNotEmpty ? d.produtos : produtos,
      );

  String get taxaFormatada => reais(taxa);
  String get taxaCurta => reaisCurto(taxa);
  String get totalFormatado => reais(total);

  /// precisa receber dinheiro na entrega?
  bool get recebeNaEntrega =>
      pagamento == 'Dinheiro' || pagamento == 'PIX' || pagamento == 'Cartão';
  bool get precisaTroco => trocoPara > total && total > 0;
  double get troco => trocoPara - total;

  bool get emRota => status == 'out_for_delivery';
}

/// Um pedido aceito que ainda está em andamento
class EntregaAtiva {
  Pedido pedido;

  /// já apertou "cheguei no local"?
  bool chegou;

  EntregaAtiva(this.pedido, {this.chegou = false});

  bool get emRota => pedido.emRota;
}

/* ================================================================== *
 *  ENTREGA CONCLUÍDA (histórico)
 * ================================================================== */
class EntregaFeita {
  final int id;
  final String numero;
  final String cliente;
  final String endereco;
  final double valor;
  final String statusPagamento;
  final DateTime? concluidaEm;

  const EntregaFeita({
    required this.id,
    required this.numero,
    required this.cliente,
    required this.endereco,
    required this.valor,
    required this.statusPagamento,
    this.concluidaEm,
  });

  factory EntregaFeita.fromJson(Map<String, dynamic> j) => EntregaFeita(
        id: _int(j['id']),
        numero: (j['orderNumber'] ?? '#${j['id']}').toString(),
        cliente: (j['customerName'] ?? '').toString(),
        endereco: (j['customerAddress'] ?? '').toString(),
        valor: _num(j['repasseValue'] ?? j['deliveryFee']),
        statusPagamento: (j['paymentStatus'] ?? '').toString(),
        concluidaEm: j['completedAt'] is String
            ? DateTime.tryParse(j['completedAt'])?.toLocal()
            : null,
      );

  String get hora {
    final d = concluidaEm;
    if (d == null) return '';
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  bool get pago => statusPagamento == 'paid';
}
