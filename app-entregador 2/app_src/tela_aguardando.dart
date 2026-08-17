import 'package:flutter/material.dart';
import 'tema.dart';
import 'estado.dart';
import 'modelos.dart';
import 'sheet_novo_pedido.dart';
import 'sheet_detalhes.dart';
import 'tela_entrega_concluida.dart';

/* ---- dados de exemplo: troque pelos dados da sua API ---- */
const _ultima = {
  'quando': 'há 12 min',
  'endereco': 'Av. Santos Dumont · Aldeota',
  'valor': 'R\$ 13',
};

class TelaAguardando extends StatefulWidget {
  const TelaAguardando({super.key});

  @override
  State<TelaAguardando> createState() => _TelaAguardandoState();
}

class _TelaAguardandoState extends State<TelaAguardando> {
  /// entregas aceitas e ainda não concluídas
  final List<EntregaAtiva> _ativas = [];

  /// controla qual pedido de exemplo aparece a cada toque no botão de teste
  int _proximo = 0;

  void _aviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        behavior: SnackBarBehavior.floating,
        backgroundColor: T.dark2,
      ),
    );
  }

  /* ---------------- fluxo do pedido ---------------- */

  Future<void> _simularPedido() async {
    if (!entregadorAtivo.value) {
      _aviso('Você está pausado. Ative o botão no topo para receber pedidos.');
      return;
    }

    final pedido = pedidosExemplo[_proximo % pedidosExemplo.length];
    _proximo++;

    final aceitou = await mostrarNovoPedido(context, pedido);
    if (aceitou == true && mounted) {
      setState(() => _ativas.insert(0, EntregaAtiva(pedido)));
    }
  }

  Future<void> _sairParaEntrega(EntregaAtiva e) async {
    await mostrarClienteNotificado(context, e.pedido);
    if (!mounted) return;
    setState(() => e.emRota = true);
  }

  Future<void> _abrirDetalhes(EntregaAtiva e) async {
    final resultado = await mostrarDetalhesPedido(context, e.pedido);
    if (resultado == 'entregue' && mounted) {
      await _concluir(e);
    }
  }

  Future<void> _concluir(EntregaAtiva e) async {
    final agora = TimeOfDay.now();
    final hora =
        '${agora.hour.toString().padLeft(2, '0')}:${agora.minute.toString().padLeft(2, '0')}';

    // soma nos números do dia e tira da lista de ativas
    registrarEntrega(valor: e.pedido.valor, km: e.pedido.kmNumero);
    setState(() => _ativas.remove(e));

    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TelaEntregaConcluida(pedido: e.pedido, hora: hora),
    ));
  }

  /* ---------------- construção da tela ---------------- */

  @override
  Widget build(BuildContext context) {
    final temAtivas = _ativas.isNotEmpty;
    final margem = MediaQuery.of(context).padding.bottom;

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
                    child: temAtivas
                        ? _comEntregas(margem)
                        : LayoutBuilder(
                            builder: (context, cons) {
                              // centraliza quando cabe; rola quando nao cabe.
                              // sem isso o conteudo "vaza" e o botao para de
                              // aceitar toque mesmo aparecendo na tela.
                              final livre = cons.maxHeight - 96 - margem;
                              return SingleChildScrollView(
                                padding: EdgeInsets.only(bottom: 82 + margem),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      minHeight: livre > 0 ? livre : 0),
                                  child: _esperaGrande(),
                                ),
                              );
                            },
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

  /* ---------------- resumo do dia (números ao vivo) ---------------- */
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
            builder: (_, v, __) =>
                _Resumo(valor: '$v', label: 'entregas hoje'),
          ),
          ValueListenableBuilder<double>(
            valueListenable: ganhosHoje,
            builder: (_, v, __) => _Resumo(
                valor: 'R\$ ${v.toStringAsFixed(0)}',
                label: 'ganhos',
                cor: T.green,
                divisor: true),
          ),
          ValueListenableBuilder<double>(
            valueListenable: kmHoje,
            builder: (_, v, __) => _Resumo(
                valor: '${v.toStringAsFixed(0)} km',
                label: 'rodados',
                divisor: true),
          ),
        ],
      ),
    );
  }

  /* ---------------- com entregas ativas ---------------- */
  Widget _comEntregas(double margem) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 18, bottom: 82 + margem),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Entregas ativas',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: T.ink,
                        letterSpacing: -.3)),
                Text(
                    _ativas.length == 1
                        ? '1 entrega'
                        : '${_ativas.length} entregas',
                    style: const TextStyle(fontSize: 13, color: T.inkSoft)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          for (final e in _ativas) ...[
            _CardEntregaAtiva(
              entrega: e,
              onDetalhes: () => _abrirDetalhes(e),
              onSair: () => _sairParaEntrega(e),
            ),
            const SizedBox(height: 10),
          ],

          const SizedBox(height: 8),
          _esperaCompacta(),
        ],
      ),
    );
  }

  /* ---------------- espera (sem entregas ativas) ---------------- */
  Widget _esperaGrande() {
    return ValueListenableBuilder<bool>(
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
          const SizedBox(height: 6),
          SizedBox(
            width: 260,
            child: Text(
              ativo
                  ? 'Assim que chegar um pedido, ele aparece aqui e o celular vai tocar.'
                  : 'Você não vai receber novos pedidos. Toque no botão lá em cima para voltar a ficar ativo.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13.5, color: T.inkSoft, height: 1.45),
            ),
          ),
          const SizedBox(height: 14),
          _selo(ativo),
          const SizedBox(height: 20),
          _cartaoUltimaEntrega(),
          const SizedBox(height: 14),
          _botaoTeste(ativo),
        ],
      ),
    );
  }

  /* ---------------- espera (com entregas ativas) ---------------- */
  Widget _esperaCompacta() {
    return ValueListenableBuilder<bool>(
      valueListenable: entregadorAtivo,
      builder: (context, ativo, _) => Column(
        children: [
          Radar(ativo: ativo, tamanho: 104, nucleo: 48, icone: 22),
          const SizedBox(height: 12),
          _TituloEspera(
            texto: ativo ? 'Aguardando novos pedidos' : 'Você está pausado',
            comSpinner: ativo,
            tamanho: 15,
          ),
          const SizedBox(height: 10),
          _selo(ativo),
          const SizedBox(height: 14),
          _botaoTeste(ativo),
        ],
      ),
    );
  }

  Widget _selo(bool ativo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: ativo ? const Color(0xFFE8F7EE) : const Color(0xFFF1F2F5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: ativo ? const Color(0xFF22C55E) : T.tabOff,
                shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(ativo ? 'Você está online' : 'Você está offline',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ativo ? const Color(0xFF15803D) : T.inkSoft)),
        ],
      ),
    );
  }

  Widget _cartaoUltimaEntrega() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: sombraCard(),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2F5),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.access_time_rounded,
                size: 16, color: T.inkSoft),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Última entrega ${_ultima['quando']}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: T.ink,
                        letterSpacing: -.2)),
                const SizedBox(height: 2),
                Text(_ultima['endereco']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, color: T.inkSoft)),
              ],
            ),
          ),
          Text(_ultima['valor']!,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: T.green)),
        ],
      ),
    );
  }

  /// botão de teste — APAGUE antes de publicar na loja
  Widget _botaoTeste(bool ativo) {
    return Opacity(
      opacity: ativo ? 1 : .45,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _simularPedido,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD3D6DE), width: 1.5),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 16, color: Color(0xFF9CA1AE)),
              SizedBox(width: 8),
              Text('Simular novo pedido (teste)',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9CA1AE))),
            ],
          ),
        ),
      ),
    );
  }
}

/* ================================================================== *
 *  CARD DE UMA ENTREGA ATIVA
 * ================================================================== */
class _CardEntregaAtiva extends StatelessWidget {
  final EntregaAtiva entrega;
  final VoidCallback onDetalhes;
  final VoidCallback onSair;

  const _CardEntregaAtiva({
    required this.entrega,
    required this.onDetalhes,
    required this.onSair,
  });

  @override
  Widget build(BuildContext context) {
    final p = entrega.pedido;

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
                        Text('#${p.id}',
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
                          child: Text(
                              entrega.emRota ? 'EM ROTA' : 'A CAMINHO',
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .5,
                                  color: Color(0xFF8A6B10))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text('${p.endereco} — ${p.bairro}',
                        style: const TextStyle(
                            fontSize: 13.5, color: T.inkSoft, height: 1.3)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(p.valorFormatado,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: T.green,
                          letterSpacing: -.3)),
                  const SizedBox(height: 2),
                  Text('${p.km} km',
                      style: const TextStyle(fontSize: 12, color: T.inkSoft)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              // ---- Detalhes ----
              Expanded(
                flex: 4,
                child: GestureDetector(
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

              // ---- Sair para entrega / Em rota ----
              Expanded(
                flex: 6,
                child: GestureDetector(
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
