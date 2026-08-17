import 'package:flutter/foundation.dart';

/* ================================================================== *
 *  ESTADO GLOBAL — informações que várias telas precisam ver
 *  (quando o valor muda, quem estiver "ouvindo" se atualiza sozinho)
 * ================================================================== */

/// Aba aberta na barra de baixo (0 Início, 1 Ganhos, 2 Perfil)
final abaSelecionada = ValueNotifier<int>(0);

/// Entregador está aceitando pedidos? (o toggle do header controla isso)
final entregadorAtivo = ValueNotifier<bool>(true);

/// Números do dia, mostrados no card de resumo da tela Início
final ganhosHoje = ValueNotifier<double>(0);
final entregasHoje = ValueNotifier<int>(0);
final mediaHoje = ValueNotifier<double>(0);

/// Id do pedido que veio de uma notificação tocada pelo entregador.
/// A tela Início "ouve" isso e abre o pedido sozinha.
final pedidoDaNotificacao = ValueNotifier<int?>(null);

/// Sobe +1 toda vez que chega uma notificação de pedido novo.
/// Serve para a tela Início buscar na API na hora, sem esperar os 15s.
final avisoDePedidoNovo = ValueNotifier<int>(0);

double _paraNumero(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0;
  return 0;
}

/// Atualiza os números do dia com o que veio da API (/earnings)
void atualizarResumo({dynamic entregas, dynamic ganhos, dynamic media}) {
  if (entregas != null) entregasHoje.value = _paraNumero(entregas).toInt();
  if (ganhos != null) ganhosHoje.value = _paraNumero(ganhos);
  if (media != null) mediaHoje.value = _paraNumero(media);
}
