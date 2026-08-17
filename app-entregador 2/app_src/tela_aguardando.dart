import 'dart:async';
import 'package:flutter/material.dart';
import 'tema.dart';
import 'api.dart';
import 'estado.dart';
import 'modelos.dart';
import 'sheet_novo_pedido.dart';
import 'sheet_detalhes.dart';
import 'tela_entrega_concluida.dart';

class TelaAguardando extends StatefulWidget {
  const TelaAguardando({super.key});

  @override
  State<TelaAguardando> createState() => _TelaAguardandoState();
}

class _TelaAguardandoState extends State<TelaAguardando> {
  List<Pedido> _disponiveis = [];
  List<EntregaAtiva> _ativas = [];

  /// ids que o entregador já viu (para não abrir o modal duas vezes)
  final Set<int> _jaMostrados = {};

  Timer? _relogio;
  bool _carregando = false;
  bool _modalAberto = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _atualizar();
    // procura pedidos novos a cada 15 segundos
    _relogio = Timer.periodic(const Duration(seconds: 15), (_) => _atualizar());
  }

  @override
  void dispose() {
    _relogio?.cancel();
    super.dispose();
  }

  void _aviso(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(texto),
      behavior: SnackBarBehavior.floating,
      backgroundColor: T.dark2,
    ));
  }

  /* ================================================================ *
   *  BUSCA OS DADOS NA API
   * ================================================================ */
  Future<void> _atualizar() async {
    if (!apiConfigurada || _carregando) return;
    setState(() => _carregando = true);

    try {
      final resultados = await Future.wait([
        Api.meusPedidos(),
        entregadorAtivo.value
            ? Api.pedidosDisponiveis()
            : Future.value(<Map<String, dynamic>>[]),
        Api.ganhos(de: DateTime.now(), ate: DateTime.now()),
      ]);

      final meus = (resultados[0] as List<Map<String, dynamic>>)
          .map(Pedido.fromJson)
          .toList();
      final livres = (resultados[1] as List<Map<String, dynamic>>)
          .map(Pedido.fromJson)
          .toList();
      final g = resultados[2] as Map<String, dynamic>;

      // mantém o "cheguei" que já foi marcado
      final chegaram = {
        for (final a in _ativas)
          if (a.chegou) a.pedido.id
      };

      if (!mounted) return;
      setState(() {
        _ativas = meus
            .map((p) => EntregaAtiva(p, chegou: chegaram.contains(p.id)))
            .toList();
        _disponiveis = livres;
        _erro = null;
        _carregando = false;
      });

      // atualiza os números do topo
      atualizarResumo(
        entregas: g['totalDeliveries'],
        ganhos: g['totalEarnings'],
        media: g['averagePerDelivery'],
      );

      _talvezAbrirModal();
    } on ApiErro catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _carregando = false);
    }
  }

  /// abre o modal automaticamente quando chega um pedido novo
  Future<void> _talvezAbrirModal() async {
    if (_modalAberto || !mounted || !entregadorAtivo.value) return;

    final novo = _disponiveis.where((p) => !_jaMostrados.contains(p.id));
    if (novo.isEmpty) return;

    await _abrirPedido(novo.first);
  }

  /* ================================================================ *
   *  AÇÕES
   * ================================================================ */

  Future<void> _abrirPedido(Pedido p) async {
    _jaMostrados.add(p.id);
    _modalAberto = true;

    final aceitou = await mostrarNovoPedido(context, p);
    _modalAberto = false;
    if (aceitou != true || !mounted) return;

    try {
      await Api.aceitarPedido(p.id);
      _aviso('Pedido ${p.numero} aceito');
      await _atualizar();
    } on ApiErro catch (e) {
      _aviso(e.mensagem);
      await _atualizar();
    }
  }

  Future<void> _sair(EntregaAtiva e) async {
    try {
      await Api.sairParaEntrega(e.pedido.id);
      if (!mounted) return;
      await mostrarClienteNotificado(context, e.pedido);
      await _atualizar();
    } on ApiErro catch (erro) {
      _aviso(erro.mensagem);
    }
  }

  Future<void> _detalhes(EntregaAtiva e) async {
    Pedido p = e.pedido;

    // busca o detalhe completo (itens, observação, troco, telefone)
    try {
      final d = await Api.detalhePedido(p.id);
      p = p.comDetalhe(Pedido.fromJson(d));
      if (mounted) setState(() => e.pedido = p);
    } catch (_) {
      // sem internet: mostra o que já tem
    }

    if (!mounted) return;
    final acao =
        await mostrarDetalhesPedido(context, p, jaChegou: e.chegou);
    if (!mounted || acao == null) return;

    switch (acao) {
      case 'chegou':
        try {
          await Api.cheguei(p.id);
          if (!mounted) return;
          setState(() => e.chegou = true);
          await mostrarClienteNotificado(
            context,
            p,
            titulo: 'Cliente avisado!',
            texto:
                'Mandamos uma mensagem dizendo que você chegou no local de entrega.',
          );
        } on ApiErro catch (erro) {
          _aviso(erro.mensagem);
        }
        break;

      case 'entregue':
        await _concluir(e);
        break;

      case 'problema':
        await _problema(e);
        break;
    }
  }

  Future<void> _concluir(EntregaAtiva e) async {
    try {
      await Api.entregar(e.pedido.id);
    } on ApiErro catch (erro) {
      _aviso(erro.mensagem);
      return;
    }

    final agora = TimeOfDay.now();
    final hora =
        '${agora.hour.toString().padLeft(2, '0')}:${agora.minute.toString().padLeft(2, '0')}';

    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TelaEntregaConcluida(pedido: e.pedido, hora: hora),
    ));
    await _atualizar();
  }

  Future<void> _problema(EntregaAtiva e) async {
    final r = await mostrarProblema(context);
    if (r == null || !mounted) return;
    try {
      await Api.relatarProblema(e.pedido.id,
          tipo: r['tipo']!, descricao: r['descricao']);
      _aviso('Problema enviado para o restaurante');
    } on ApiErro catch (erro) {
      _aviso(erro.mensagem);
    }
  }

  /* ================================================================ *
   *  TELA
   * ================================================================ */
  @override
  Widget build(BuildContext context) {
    final margem = MediaQuery.of(context).padding.bottom;
    final temAlgo = _ativas.isNotEmpty || _disponiveis.isNotEmpty;

    return Column(
      children: [
        const HeaderVermelho(child: BarraBoasVindas()),
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSide),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _cartaoResumo(),
                  Expanded(
                    child: RefreshIndicator(
                      color: T.redDark,
                      onRefresh: _atualizar,
                      child: temAlgo
                          ? _comPedidos(margem)
                          : _semPedidos(margem),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /* ---------------- resumo do dia ---------------- */
  Widget _cartaoResumo() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: sombraCard(opacidade: .09, blur: 22, y: 8),
      ),
      child: Row(
        children: [
          ValueListenableBuilder<int>(
            valueListenable: entregasHoje,
            builder: (_, v, __) => _Resumo(valor: '$v', label: 'entregas hoje'),
          ),
          ValueListenableBuilder<double>(
            valueListenable: ganhosHoje,
            builder: (_, v, __) => _Resumo(
                valor: reaisCurto(v),
                label: 'ganhos',
                cor: T.green,
                divisor: true),
          ),
          ValueListenableBuilder<double>(
            valueListenable: mediaHoje,
            builder: (_, v, __) =>
                _Resumo(valor: reaisCurto(v), label: 'média', divisor: true),
          ),
        ],
      ),
    );
  }

  /* ---------------- com pedidos ---------------- */
  Widget _comPedidos(double margem) {
    return ListView(
      padding: EdgeInsets.only(top: 18, bottom: 82 + margem),
      children: [
        if (_ativas.isNotEmpty) ...[
          _tituloSecao('Entregas ativas',
              '${_ativas.length} ${_ativas.length == 1 ? 'entrega' : 'entregas'}'),
          const SizedBox(height: 10),
          for (final e in _ativas) ...[
            _CardAtiva(
              entrega: e,
              onDetalhes: () => _detalhes(e),
              onSair: () => _sair(e),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
        ],
        if (_disponiveis.isNotEmpty) ...[
          _tituloSecao('Pedidos disponíveis', '${_disponiveis.length}'),
          const SizedBox(height: 10),
          for (final p in _disponiveis) ...[
            _CardDisponivel(pedido: p, onTap: () => _abrirPedido(p)),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
        ],
        _rodapeEspera(),
      ],
    );
  }

  Widget _tituloSecao(String titulo, String direita) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(titulo,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: T.ink,
                    letterSpacing: -.3)),
            Text(direita,
                style: const TextStyle(fontSize: 13, color: T.inkSoft)),
          ],
        ),
      );

  /* ---------------- sem pedidos ---------------- */
  Widget _semPedidos(double margem) {
    return LayoutBuilder(
      builder: (context, cons) {
        final livre = cons.maxHeight - 82 - margem;
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 82 + margem),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: livre > 0 ? livre : 0),
            child: ValueListenableBuilder<bool>(
              valueListenable: entregadorAtivo,
              builder: (context, ativo, _) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radar(ativo: ativo, tamanho: 168, nucleo: 68, icone: 31),
                  const SizedBox(height: 18),
                  _TituloEspera(
                    texto: ativo ? 'Aguardando pedidos' : 'Você está pausado',
                    comSpinner: ativo,
                    tamanho: 19,
                  ),
                  if (ativo) ...[
                    const SizedBox(height: 6),
                    const SizedBox(
                      width: 260,
                      child: Text(
                        'Assim que o restaurante liberar um pedido, ele aparece aqui.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13.5, color: T.inkSoft, height: 1.45),
                      ),
                    ),
                  ],
                  if (_erro != null) ...[
                    const SizedBox(height: 16),
                    _CaixaErro(texto: _erro!, onTentar: _atualizar),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// linha de espera que fica no fim da lista
  Widget _rodapeEspera() {
    return ValueListenableBuilder<bool>(
      valueListenable: entregadorAtivo,
      builder: (context, ativo, _) => Column(
        children: [
          if (_erro != null) ...[
            _CaixaErro(texto: _erro!, onTentar: _atualizar),
            const SizedBox(height: 12),
          ],
          _TituloEspera(
            texto: ativo ? 'Aguardando novos pedidos' : 'Você está pausado',
            comSpinner: ativo,
            tamanho: 15,
          ),
        ],
      ),
    );
  }
}

/* ================================================================== *
 *  CARD DE PEDIDO DISPONÍVEL
 * ================================================================== */
class _CardDisponivel extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onTap;
  const _CardDisponivel({required this.pedido, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = pedido;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: T.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFAD9D9), width: 1.5),
          boxShadow: sombraCard(),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.receipt_long_rounded,
                  size: 21, color: T.redDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(p.numero,
                          style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: T.ink,
                              letterSpacing: -.3)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F7EE),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Text('DISPONÍVEL',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .5,
                                color: Color(0xFF15803D))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(p.endereco,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13.5, color: T.inkSoft, height: 1.3)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(p.taxaFormatada,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: T.green,
                        letterSpacing: -.3)),
                const SizedBox(height: 2),
                Text('${p.itens} ${p.itens == 1 ? 'item' : 'itens'}',
                    style: const TextStyle(fontSize: 12, color: T.inkSoft)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ================================================================== *
 *  CARD DE ENTREGA ATIVA
 * ================================================================== */
class _CardAtiva extends StatelessWidget {
  final EntregaAtiva entrega;
  final VoidCallback onDetalhes;
  final VoidCallback onSair;

  const _CardAtiva({
    required this.entrega,
    required this.onDetalhes,
    required this.onSair,
  });

  @override
  Widget build(BuildContext context) {
    final p = entrega.pedido;
    final selo = entrega.chegou
        ? 'NO LOCAL'
        : (entrega.emRota ? 'EM ROTA' : 'A CAMINHO');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDEEF2)),
        boxShadow: sombraCard(),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_shipping_rounded,
                    size: 21, color: T.redDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(p.numero,
                            style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: T.ink,
                                letterSpacing: -.3)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCF0C8),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(selo,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .5,
                                  color: Color(0xFF8A6B10))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(p.endereco,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13.5, color: T.inkSoft, height: 1.3)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(p.taxaFormatada,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: T.green,
                      letterSpacing: -.3)),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onDetalhes,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE7E9EE)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.visibility_outlined, size: 17, color: T.ink),
                        SizedBox(width: 7),
                        Text('Detalhes',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: T.ink)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 6,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: entrega.emRota ? onDetalhes : onSair,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      gradient: kGradRed,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                            entrega.emRota
                                ? Icons.navigation_rounded
                                : Icons.arrow_forward_rounded,
                            size: 17,
                            color: Colors.white),
                        const SizedBox(width: 8),
                        Text(entrega.emRota ? 'Em rota' : 'Sair para entrega',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ---------------- pedaços da tela ---------------- */
class _CaixaErro extends StatelessWidget {
  final String texto;
  final VoidCallback onTentar;
  const _CaixaErro({required this.texto, required this.onTentar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 18, color: T.redDark),
          const SizedBox(width: 9),
          Expanded(
            child: Text(texto,
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: T.redDark)),
          ),
          GestureDetector(
            onTap: onTentar,
            child: const Text('Tentar',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: T.redDark)),
          ),
        ],
      ),
    );
  }
}

class _TituloEspera extends StatelessWidget {
  final String texto;
  final bool comSpinner;
  final double tamanho;
  const _TituloEspera(
      {required this.texto, required this.comSpinner, required this.tamanho});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (comSpinner) ...[
          SizedBox(
            width: tamanho,
            height: tamanho,
            child: const CircularProgressIndicator(
                strokeWidth: 2.6, color: T.redDark),
          ),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Text(texto,
              style: TextStyle(
                  fontSize: tamanho,
                  fontWeight: FontWeight.w800,
                  color: T.ink,
                  letterSpacing: -.3)),
        ),
      ],
    );
  }
}

class _Resumo extends StatelessWidget {
  final String valor, label;
  final Color? cor;
  final bool divisor;
  const _Resumo(
      {required this.valor,
      required this.label,
      this.cor,
      this.divisor = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (divisor)
            Positioned(
              left: 0,
              top: 2,
              bottom: 2,
              child: Container(width: 1, color: T.line),
            ),
          Column(
            children: [
              Text(valor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.4,
                      color: cor ?? T.ink)),
              Text(label,
                  style: const TextStyle(fontSize: 11, color: T.inkSoft)),
            ],
          ),
        ],
      ),
    );
  }
}

/* ---------- anéis pulsando ---------- */
class Radar extends StatefulWidget {
  final double tamanho;
  final double nucleo;
  final double icone;
  final bool ativo;
  const Radar({
    super.key,
    this.tamanho = 190,
    this.nucleo = 74,
    this.icone = 34,
    this.ativo = true,
  });

  @override
  State<Radar> createState() => _RadarState();
}

class _RadarState extends State<Radar> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.ativo) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant Radar old) {
    super.didUpdateWidget(old);
    if (widget.ativo && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.ativo && _c.isAnimating) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _anel(double fase) {
    final escala = 0.45 + 0.55 * fase;
    final opacidade =
        fase < 0.15 ? (fase / 0.15) * 0.55 : 0.55 * (1 - (fase - 0.15) / 0.85);
    return Opacity(
      opacity: opacidade.clamp(0.0, 1.0).toDouble(),
      child: Transform.scale(
        scale: escala,
        child: Container(
          width: widget.tamanho,
          height: widget.tamanho,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: T.redDark.withOpacity(.06),
            border: Border.all(color: T.redDark.withOpacity(.35), width: 1.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = widget.ativo
        ? [T.red, T.redDark]
        : [const Color(0xFFC9CCD4), const Color(0xFFAAAEB8)];

    return SizedBox(
      width: widget.tamanho,
      height: widget.tamanho,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              if (widget.ativo) ...[
                _anel(t),
                _anel((t + 1 / 3) % 1),
                _anel((t + 2 / 3) % 1),
              ],
              Container(
                width: widget.nucleo,
                height: widget.nucleo,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: cores,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.ativo ? T.redDark : Colors.black)
                          .withOpacity(widget.ativo ? .4 : .12),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                    widget.ativo
                        ? Icons.two_wheeler_rounded
                        : Icons.pause_rounded,
                    size: widget.icone,
                    color: Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }
}
