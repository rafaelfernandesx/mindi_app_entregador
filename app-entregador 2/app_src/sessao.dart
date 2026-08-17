import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/* ================================================================== *
 *  SESSÃO — guarda o token e os dados do entregador logado
 *  Fica salvo no celular, então o app não pede login toda hora.
 * ================================================================== */
class Sessao {
  static String? token;
  static String? refreshToken;
  static Map<String, dynamic> driver = {};

  static const _kToken = 'token';
  static const _kRefresh = 'refreshToken';
  static const _kDriver = 'driver';

  static bool get logado => token != null && token!.isNotEmpty;

  /// nome do entregador (ou vazio)
  static String get nome => (driver['name'] ?? '').toString();

  /// telefone só com números
  static String get telefone => (driver['phone'] ?? '').toString();

  /// nome do restaurante
  static String get empresa => (driver['establishmentName'] ?? '').toString();

  /// telefone formatado: (85) 9 9998-7766
  static String get telefoneFormatado {
    final d = telefone.replaceAll(RegExp(r'\D'), '');
    if (d.length != 11) return telefone;
    return '(${d.substring(0, 2)}) ${d.substring(2, 3)} ${d.substring(3, 7)}-${d.substring(7)}';
  }

  /// iniciais para o avatar: "João Silva" -> "JS"
  static String get iniciais {
    final partes =
        nome.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes.first.substring(0, 1) + partes.last.substring(0, 1))
        .toUpperCase();
  }

  /* ---------------- gravar e ler do celular ---------------- */

  static Future<void> carregar() async {
    final p = await SharedPreferences.getInstance();
    token = p.getString(_kToken);
    refreshToken = p.getString(_kRefresh);
    final d = p.getString(_kDriver);
    if (d != null && d.isNotEmpty) {
      try {
        driver = (jsonDecode(d) as Map).cast<String, dynamic>();
      } catch (_) {
        driver = {};
      }
    }
  }

  static Future<void> salvar({
    required String token,
    String? refreshToken,
    Map<String, dynamic>? driver,
  }) async {
    Sessao.token = token;
    if (refreshToken != null) Sessao.refreshToken = refreshToken;
    if (driver != null) Sessao.driver = driver;

    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken, token);
    if (refreshToken != null) await p.setString(_kRefresh, refreshToken);
    if (driver != null) await p.setString(_kDriver, jsonEncode(driver));
  }

  static Future<void> atualizarToken({
    required String token,
    String? refreshToken,
  }) async {
    Sessao.token = token;
    if (refreshToken != null) Sessao.refreshToken = refreshToken;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken, token);
    if (refreshToken != null) await p.setString(_kRefresh, refreshToken);
  }

  /// mistura os dados novos do /me com os que já existem
  static Future<void> atualizarDriver(Map<String, dynamic> novo) async {
    driver = {...driver, ...novo};
    final p = await SharedPreferences.getInstance();
    await p.setString(_kDriver, jsonEncode(driver));
  }

  static Future<void> limpar() async {
    token = null;
    refreshToken = null;
    driver = {};
    final p = await SharedPreferences.getInstance();
    await p.remove(_kToken);
    await p.remove(_kRefresh);
    await p.remove(_kDriver);
  }
}
