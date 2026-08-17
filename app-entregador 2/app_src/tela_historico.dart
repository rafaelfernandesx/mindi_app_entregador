import 'package:flutter/material.dart';
import 'tema.dart';
import 'icones.dart';
import 'api.dart';
import 'modelos.dart';
import 'sheet_entrega_feita.dart';

class TelaHistorico extends StatefulWidget {
  const TelaHistorico({super.key});

  @override
  State<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {
  late DateTime _de;
  late DateTime _ate;

  List<EntregaFeita> _entregas = [];
  Map<String, dynamic> _resumo = {};
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final hoje = DateTime.now();
    _ate = hoje;
    _de = hoje.subtract(const Duration(days: 15));
    _buscar();
  }

  /* ---------------- API ---------------- */
  Future<void> _buscar() async {
    if (!apiConfigurada) {
      setState(() => _carregando = false);
      return;
    }
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final r = await Future.wait([
        Api.historico(de: _de, ate: _ate),
        Api.ganhos(de: _de, ate: _ate),
      ]);
      if (!mounted) return;
      setState(() {
        _entregas = (r[0] as List<Map<String, dynamic>>)
            .map(EntregaFeita.fromJson)
            .toList();
        _resumo = r[1] as Map<String, dynamic>;
        _carregando = false;
      });
    } on ApiErro catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar o histórico.';
        _carregando = false;
      });
    }
  }

  /* ---------------- datas ---------------- */
  String _dm(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  String _dma(DateTime d) => '${_dm(d)}/${d.year}';

  Future<void> _escolherData(bool inicio) async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: inicio ? _de : _ate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: T.redDark),
        ),
        child: child!,
      ),
    );
    if (escolhida == null) return;
    setState(() {
      if (inicio) {
        _de = escolhida;
        if (_ate.isBefore(_de)) _ate = _de;
      } else {
        _ate = escolhida;
        if (_de.isAfter(_ate)) _de = _ate;
      }
    });
    _buscar();
  }

  /// Hoje / Ontem / data
  String _rotuloDia(DateTime d) {
    final hoje = DateTime.now();
    final dia = DateTime(d.year, d.month, d.day);
    final ref = DateTime(hoje.year, hoje.month, hoje.day);
    final diff = ref.difference(dia).inDays;
    if (diff == 0) return 'Hoje — ${_dm(d)}';
    if (diff == 1) return 'Ontem — ${_dm(d)}';
    return _dm(d);
  }

  String _valor(dynamic v) {
    if (v == null) return '—';
    final n = v is num ? v.toDouble() : double.tryParse('$v'.replaceAll(',', '.'));
    return n == null ? '—' : reaisCurto(n);
  }

  @override
  Widget build(BuildContext context) {
    // agrupa por dia mantendo a ordem que veio da API
    final grupos = <String, List<EntregaFeita>>{};
    for (final e in _entregas) {
      final d = e.concluidaEm;
      final chave = d == null ? 'Sem data' : _rotuloDia(d);
      grupos.putIfAbsent(chave, () => []).add(e);
    }

    return TelaInterna(
      titulo: 'Histórico de entregas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---------- período ----------
          Row(
            children: [
              Expanded(
                  child: _CampoData(
                      texto: _dma(_de), onTap: () => _escolherData(true))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Ico.seta,
                    size: 18, color: T.inkSoft),
              ),
              Expanded(
                  child: _CampoData(
                      texto: _dma(_ate), onTap: () => _escolherData(false))),
            ],
          ),
          const SizedBox(height: 14),

          // ---------- totais do período ----------
          Row(
            children: [
              _Caixa(
                  valor: '${_resumo['totalDeliveries'] ?? _entregas.length}',
                  label: 'entregas'),
              const SizedBox(width: 10),
              _Caixa(
                  valor: _valor(_resumo['totalEarnings']),
                  label: 'total ganho',
                  cor: T.green),
              const SizedBox(width: 10),
              _Caixa(
                  valor: _valor(_resumo['averagePerDelivery']),
                  label: 'média'),
            ],
          ),

          // ---------- a receber ----------
          if (_resumo['pendingPayment'] != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: T.amareloSuave,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: T.amareloBorda),
              ),
              child: Row(
                children: [
                  Icon(Ico.relogio,
                      size: 17, color: T.amarelo),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text('Ainda a receber',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: T.amarelo)),
                  ),
                  Text(_valor(_resumo['pendingPayment']),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: T.amarelo)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // ---------- lista ----------
          if (_carregando)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                  child: CircularProgressIndicator(color: T.redDark)),
            )
          else if (_erro != null)
            _Vazio(texto: _erro!, onTentar: _buscar)
          else if (_entregas.isEmpty)
            _Vazio(texto: 'Nenhuma entrega nesse período')
          else
            Container(
              decoration: BoxDecoration(
                color: T.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: sombraCard(),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final grupo in grupos.entries) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 11),
                      color: T.campo,
                      child: Text(grupo.key,
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: T.rotulo)),
                    ),
                    for (final e in grupo.value)
                      _Linha(
                          entrega: e,
                          aoTocar: () => mostrarEntregaFeita(context, e)),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/* ---------------- campo de data ---------------- */
class _CampoData extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;
  const _CampoData({required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: T.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: T.borda),
        ),
        child: Row(
          children: [
            Icon(Ico.calendario,
                size: 15, color: T.inkSoft),
            const SizedBox(width: 9),
            Text(texto,
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: T.ink)),
          ],
        ),
      ),
    );
  }
}

/* ---------------- caixinha de total ---------------- */
class _Caixa extends StatelessWidget {
  final String valor, label;
  final Color? cor;
  const _Caixa({required this.valor, required this.label, this.cor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
        decoration: BoxDecoration(
          color: T.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: T.borda),
        ),
        child: Column(
          children: [
            Text(valor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.4,
                    color: cor ?? T.ink)),
            const SizedBox(height: 1),
            Text(label,
                style: TextStyle(fontSize: 11, color: T.inkSoft)),
          ],
        ),
      ),
    );
  }
}

/* ---------------- lista vazia / erro ---------------- */
class _Vazio extends StatelessWidget {
  final String texto;
  final VoidCallback? onTentar;
  const _Vazio({required this.texto, this.onTentar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: sombraCard(),
      ),
      child: Column(
        children: [
          Text(texto,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: T.inkSoft)),
          if (onTentar != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onTentar,
              child: Text('Tentar de novo',
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: T.redDark)),
            ),
          ],
        ],
      ),
    );
  }
}

/* ---------------- uma entrega do histórico ---------------- */
class _Linha extends StatelessWidget {
  final EntregaFeita entrega;
  final VoidCallback? aoTocar;
  const _Linha({required this.entrega, this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final e = entrega;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: aoTocar,
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: T.line)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: T.greenSuave,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Ico.check, size: 18, color: T.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${e.numero} · ${e.cliente}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: T.ink,
                        letterSpacing: -.2)),
                const SizedBox(height: 2),
                Text(
                    [
                      if (e.hora.isNotEmpty) e.hora,
                      if (e.endereco.isNotEmpty) e.endereco,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.5, color: T.inkSoft)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(reaisCurto(e.valor),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: T.green)),
              if (!e.pago)
                Text('a receber',
                    style: TextStyle(fontSize: 10, color: T.amarelo)),
            ],
          ),
          const SizedBox(width: 2),
          Icon(Ico.avancar,
              size: 19, color: T.fraco),
        ],
      ),
      ),
    );
  }
}
