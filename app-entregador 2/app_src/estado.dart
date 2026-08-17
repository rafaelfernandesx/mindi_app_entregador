import 'package:flutter/foundation.dart';

/* ================================================================== *
 *  ESTADO GLOBAL — informações que várias telas precisam ver
 *  (quando o valor muda, quem estiver "ouvindo" se atualiza sozinho)
 * ================================================================== */

/// Entregador está aceitando pedidos? (o toggle do header controla isso)
final entregadorAtivo = ValueNotifier<bool>(true);

/// Números do dia, mostrados no card de resumo da tela Início
final ganhosHoje = ValueNotifier<double>(84);
final entregasHoje = ValueNotifier<int>(7);
final kmHoje = ValueNotifier<double>(31);

/// Soma uma entrega concluída aos números do dia
void registrarEntrega({required double valor, required double km}) {
  ganhosHoje.value += valor;
  entregasHoje.value += 1;
  kmHoje.value += km;
}
