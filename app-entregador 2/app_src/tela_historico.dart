import 'package:flutter/material.dart';
import 'tema.dart';
import 'modelos.dart';

/* ---- dados de exemplo: troque pelos dados da sua API ---- */
final _historico = <EntregaFeita>[
  EntregaFeita(
      id: 'P1042',
      endereco: 'Rua Padre Valdevino',
      hora: '14:02',
      km: '3,4',
      pagamento: 'Dinheiro',
      valor: 8,
      data: DateTime(2026, 8, 16)),
  EntregaFeita(
      id: 'P1041',
      endereco: 'Av. Dom Luís',
      hora: '13:10',
      km: '5,1',
      pagamento: 'PIX',
      valor: 8,
      data: DateTime(2026, 8, 16)),
  EntregaFeita(
      id: 'P1040',
      endereco: 'Rua Silva Jatahy',
      hora: '12:35',
      km: '1,8',
      pagamento: 'Cartão',
      valor: 8,
      data: DateTime(2026, 8, 16)),
  EntregaFeita(
      id: 'P1035',
      endereco: 'Av. Santos Dumont',
      hora: '19:45',
      km: '4,0',
      pagamento: 'PIX',
      valor: 8,
      data: DateTime(2026, 8, 15)),
  EntregaFeita(
      id: 'P1034',
      endereco: 'Rua Barão de Aracati',
      hora: '18:20',
      km: '2,3',
      pagamento: 'Dinheiro',
      valor: 8,
      data: DateTime(2026, 8, 15)),
  EntregaFeita(
      id: 'P1030',
      endereco: 'Rua Ana Bilhar',
      hora: '20:05',
      km: '3,1',
      pagamento: 'PIX',
      valor: 8,
      data: DateTime(2026, 8, 14)),
];

class TelaHistorico extends StatefulWidget {
  const TelaHistorico({super.key});

  @override
  State<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {
  DateTime _de = DateTime(2026, 8, 1);
  DateTime _ate = DateTime(2026, 8, 16);

  String _dm(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  String _dma(DateTime d) => '${_dm(d)}/${d.year}';

  Future<void> _escolherData(bool inicio) async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: inicio ? _de : _ate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: T.redDark),
        ),
        child: child!,
      ),
    );
    if (escolhida != null) {
      setState(() {
        if (inicio) {
          _de = escolhida;
          if (_ate.isBefore(_de)) _ate = _de;
        } else {
          _ate = escolhida;
          if (_de.isAfter(_ate)) _de = _ate;
        }
      });
    }
  }

  /// entregas dentro do período escolhido
  List<EntregaFeita> get _filtradas => _historico.where((e) {
        final d = DateTime(e.data.year, e.data.month, e.data.day);
        final ini = DateTime(_de.year, _de.month, _de.day);
        final fim = DateTime(_ate.year, _ate.month, _ate.day);
        return !d.isBefore(ini) && !d.isAfter(fim);
      }).toList();

  /// rótulo do grupo: Hoje / Ontem / data
  String _rotuloDia(DateTime d) {
    final hoje = DateTime(2026, 8, 16); // troque por DateTime.now()
    final dia = DateTime(d.year, d.month, d.day);
    final diff = hoje.difference(dia).inDays;
    if (diff == 0) return 'Hoje — ${_dm(d)}';
    if (diff == 1) return 'Ontem — ${_dm(d)}';
    return _dm(d);
  }

  @override
  Widget build(BuildContext context) {
    final lista = _filtradas;
    final total = lista.fold<double>(0, (s, e) => s + e.valor);
    final media = lista.isEmpty ? 0.0 : total / lista.length;

    // agrupa por dia mantendo a ordem
    final grupos = <String, List<EntregaFeita>>{};
    for (final e in lista) {
      grupos.putIfAbsent(_rotuloDia(e.data), () => []).add(e);
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.arrow_forward_rounded,
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
              _Caixa(valor: '${lista.length}', label: 'entregas'),
              const SizedBox(width: 10),
              _Caixa(
                  valor: 'R\$ ${total.toStringAsFixed(0)}',
                  label: 'total ganho',
                  cor: T.green),
              const SizedBox(width: 10),
              _Caixa(
                  valor: 'R\$ ${media.toStringAsFixed(0)}', label: 'média'),
            ],
          ),
          const SizedBox(height: 16),

          // ---------- lista agrupada ----------
          if (lista.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: T.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: sombraCard(),
              ),
              child: const Text('Nenhuma entrega nesse período',
                  style: TextStyle(fontSize: 13.5, color: T.inkSoft)),
            )
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
                      color: const Color(0xFFF7F8FA),
                      child: Text(grupo.key,
                          style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7180))),
                    ),
                    for (final e in grupo.value) _Linha(entrega: e),
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
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: T.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE7E9EE)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 15, color: T.inkSoft),
            const SizedBox(width: 9),
            Text(texto,
                style: const TextStyle(
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
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: T.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEEF2)),
        ),
        child: Column(
          children: [
            Text(valor,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.4,
                    color: cor ?? T.ink)),
            const SizedBox(height: 1),
            Text(label,
                style: const TextStyle(fontSize: 11, color: T.inkSoft)),
          ],
        ),
      ),
    );
  }
}

/* ---------------- uma entrega do histórico ---------------- */
class _Linha extends StatelessWidget {
  final EntregaFeita entrega;
  const _Linha({required this.entrega});

  @override
  Widget build(BuildContext context) {
    final e = entrega;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: T.line)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F7EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_rounded, size: 18, color: T.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#${e.id} · ${e.endereco}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: T.ink,
                        letterSpacing: -.2)),
                const SizedBox(height: 2),
                Text('${e.hora} · ${e.km} km · ${e.pagamento}',
                    style: const TextStyle(fontSize: 11.5, color: T.inkSoft)),
              ],
            ),
          ),
          Text('R\$ ${e.valor.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: T.green)),
        ],
      ),
    );
  }
}
