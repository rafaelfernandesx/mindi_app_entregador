import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/* ================================================================== *
 *  ESTADO GLOBAL — informações que várias telas precisam ver
 *  (quando o valor muda, quem estiver "ouvindo" se atualiza sozinho)
 * ================================================================== */

/// Tema escuro ligado? (fica salvo no celular)
final modoEscuro = ValueNotifier<bool>(false);

const _kTema = 'modoEscuro';

/// lê a preferência salva no celular (chamado quando o app abre)
Future<void> carregarTema() async {
  final p = await SharedPreferences.getInstance();
  modoEscuro.value = p.getBool(_kTema) ?? false;
}

/// troca o tema e guarda a escolha
Future<void> salvarTema(bool escuro) async {
  modoEscuro.value = escuro;
  final p = await SharedPreferences.getInstance();
  await p.setBool(_kTema, escuro);
}

/* ---------- "Lembrar" da tela de login ---------- */
const _kLembrar = 'loginLembrar';
const _kLoginTel = 'loginTelefone';
const _kLoginSenha = 'loginSenha';

/// devolve telefone e senha salvos (vazio se o entregador não marcou "Lembrar")
Future<Map<String, String>> lerLoginSalvo() async {
  final p = await SharedPreferences.getInstance();
  if (p.getBool(_kLembrar) != true) return {};
  return {
    'telefone': p.getString(_kLoginTel) ?? '',
    'senha': p.getString(_kLoginSenha) ?? '',
  };
}

/// guarda (ou apaga) os dados de login conforme a caixinha "Lembrar"
Future<void> salvarLoginSalvo({
  required bool lembrar,
  required String telefone,
  required String senha,
}) async {
  final p = await SharedPreferences.getInstance();
  await p.setBool(_kLembrar, lembrar);
  if (lembrar) {
    await p.setString(_kLoginTel, telefone);
    await p.setString(_kLoginSenha, senha);
  } else {
    await p.remove(_kLoginTel);
    await p.remove(_kLoginSenha);
  }
}

/* ---------- pedidos em que o entregador já avisou "cheguei" ----------
   Fica salvo no celular: se o app for fechado no meio da entrega, o
   botão "Cheguei no local" não volta a aparecer e o cliente não
   recebe a mensagem duas vezes. */
const _kChegou = 'pedidosQueCheguei';

Future<Set<int>> lerChegadas() async {
  final p = await SharedPreferences.getInstance();
  final lista = p.getStringList(_kChegou) ?? const [];
  return lista.map(int.tryParse).whereType<int>().toSet();
}

Future<void> salvarChegadas(Set<int> ids) async {
  final p = await SharedPreferences.getInstance();
  await p.setStringList(_kChegou, ids.map((e) => '$e').toList());
}

/// Quando o servidor diz que a conta foi removida ou desativada,
/// guarda a mensagem aqui. O app fecha a sessão e volta para o login.
final sessaoEncerrada = ValueNotifier<String?>(null);

/// Aba aberta na barra de baixo (0 Início, 1 Ganhos, 2 Perfil)
final abaSelecionada = ValueNotifier<int>(0);

/// Entregador está aceitando pedidos? (o toggle do header controla isso)
/// Começa PAUSADO: quem decide entrar em serviço é o entregador.
final entregadorAtivo = ValueNotifier<bool>(false);

/// Números do dia, mostrados no card de resumo da tela Início
final ganhosHoje = ValueNotifier<double>(0);
final entregasHoje = ValueNotifier<int>(0);
final mediaHoje = ValueNotifier<double>(0);

/// Sobe +1 sempre que os dados do entregador mudam (nome, e-mail...).
/// Quem mostra o nome na tela "ouve" isso e se redesenha na hora.
final versaoDoPerfil = ValueNotifier<int>(0);
void avisarPerfilMudou() => versaoDoPerfil.value = versaoDoPerfil.value + 1;

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
