import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sessao.dart';

/* ================================================================== *
 *  CONEXÃO COM A API
 *
 *  >>> TROQUE O ENDEREÇO ABAIXO PELO DA SUA API <<<
 *  Ex.: 'https://api.seudominio.com'  (sem barra no final)
 *
 *  Enquanto estiver vazio, o app funciona em MODO DEMONSTRAÇÃO
 *  (dados de exemplo, sem internet).
 * ================================================================== */
const String kApiBase = 'https://dev.mindi.com.br/api/driver';

bool get apiConfigurada => kApiBase.trim().isNotEmpty;

/// Erro vindo da API, já com mensagem pronta para mostrar na tela
class ApiErro implements Exception {
  final int status;
  final String mensagem;
  ApiErro(this.status, this.mensagem);
  @override
  String toString() => mensagem;
}

class Api {
  static const _timeout = Duration(seconds: 20);

  static Uri _url(String caminho, [Map<String, String>? query]) {
    final u = Uri.parse('$kApiBase$caminho');
    return query == null ? u : u.replace(queryParameters: query);
  }

  static Map<String, String> _cabecalhos({bool comToken = true}) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (comToken && Sessao.token != null)
          'Authorization': 'Bearer ${Sessao.token}',
      };

  /* ---------------- tratamento das respostas ---------------- */
  static dynamic _tratar(http.Response r) {
    if (r.statusCode == 204 || r.body.isEmpty) return null;

    dynamic corpo;
    try {
      corpo = jsonDecode(utf8.decode(r.bodyBytes));
    } catch (_) {
      corpo = null;
    }

    if (r.statusCode >= 200 && r.statusCode < 300) return corpo;

    final msg = (corpo is Map && corpo['message'] is String)
        ? corpo['message'] as String
        : _mensagemPadrao(r.statusCode);
    throw ApiErro(r.statusCode, msg);
  }

  static String _mensagemPadrao(int s) {
    switch (s) {
      case 401:
        return 'Telefone ou senha incorretos.';
      case 403:
        return 'Seu acesso está desativado. Fale com o restaurante.';
      case 404:
        return 'Não encontrado.';
      case 409:
        return 'Esse pedido já foi aceito por outro entregador.';
      case 422:
        return 'Dados inválidos.';
      case 429:
        return 'Muitas tentativas. Espere um minuto e tente de novo.';
      default:
        return s >= 500
            ? 'O servidor está fora do ar. Tente de novo em instantes.'
            : 'Não foi possível completar a ação.';
    }
  }

  /* ---------------- chamadas base ---------------- */
  static Future<dynamic> _enviar(
    String metodo,
    String caminho, {
    Object? corpo,
    Map<String, String>? query,
    bool comToken = true,
    bool jaTentouRenovar = false,
  }) async {
    if (!apiConfigurada) {
      throw ApiErro(0, 'API não configurada (modo demonstração).');
    }

    final url = _url(caminho, query);
    final cab = _cabecalhos(comToken: comToken);
    final body = corpo == null ? null : jsonEncode(corpo);

    late http.Response r;
    try {
      switch (metodo) {
        case 'GET':
          r = await http.get(url, headers: cab).timeout(_timeout);
          break;
        case 'POST':
          r = await http.post(url, headers: cab, body: body).timeout(_timeout);
          break;
        case 'PUT':
          r = await http.put(url, headers: cab, body: body).timeout(_timeout);
          break;
        default:
          throw ApiErro(0, 'Método não suportado.');
      }
    } catch (e) {
      if (e is ApiErro) rethrow;
      throw ApiErro(0, 'Sem conexão com o servidor. Verifique a internet.');
    }

    // token expirou: tenta renovar uma vez e repete a chamada
    if (r.statusCode == 401 &&
        comToken &&
        !jaTentouRenovar &&
        Sessao.refreshToken != null) {
      final renovou = await renovarToken();
      if (renovou) {
        return _enviar(metodo, caminho,
            corpo: corpo,
            query: query,
            comToken: comToken,
            jaTentouRenovar: true);
      }
    }

    return _tratar(r);
  }

  /* ================================================================ *
   *  1. SESSÃO
   * ================================================================ */

  /// POST /api/driver/auth/login
  static Future<void> login(String telefone, String senha) async {
    final so = telefone.replaceAll(RegExp(r'\D'), '');
    final r = await _enviar('POST', '/api/driver/auth/login',
        corpo: {'phone': so, 'password': senha}, comToken: false);

    await Sessao.salvar(
      token: r['token'] as String,
      refreshToken: r['refreshToken'] as String?,
      driver: (r['driver'] as Map?)?.cast<String, dynamic>(),
    );
  }

  /// POST /api/driver/auth/refresh
  static Future<bool> renovarToken() async {
    if (Sessao.refreshToken == null) return false;
    try {
      final r = await http
          .post(_url('/api/driver/auth/refresh'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'refreshToken': Sessao.refreshToken}))
          .timeout(_timeout);
      if (r.statusCode != 200) return false;
      final c = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
      await Sessao.atualizarToken(
        token: c['token'] as String,
        refreshToken: c['refreshToken'] as String?,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// POST /api/driver/auth/logout
  static Future<void> logout() async {
    try {
      await _enviar('POST', '/api/driver/auth/logout');
    } catch (_) {
      // mesmo se falhar, limpa a sessão local
    }
    await Sessao.limpar();
  }

  /// PUT /api/driver/auth/password
  static Future<String> trocarSenha(String atual, String nova) async {
    final r = await _enviar('PUT', '/api/driver/auth/password',
        corpo: {'currentPassword': atual, 'newPassword': nova});
    return (r is Map && r['message'] is String)
        ? r['message'] as String
        : 'Senha alterada com sucesso';
  }

  /* ================================================================ *
   *  2. PERFIL
   * ================================================================ */

  /// GET /api/driver/me
  static Future<Map<String, dynamic>> meuPerfil() async {
    final r = await _enviar('GET', '/api/driver/me');
    return (r as Map).cast<String, dynamic>();
  }

  /// PUT /api/driver/me
  static Future<void> editarPerfil({String? nome, String? email}) async {
    await _enviar('PUT', '/api/driver/me', corpo: {
      if (nome != null) 'name': nome,
      if (email != null) 'email': email,
    });
  }

  /* ================================================================ *
   *  3. TURNO
   * ================================================================ */

  /// PUT /api/driver/shift/status
  static Future<bool> definirOnline(bool online) async {
    final r = await _enviar('PUT', '/api/driver/shift/status',
        corpo: {'isOnline': online});
    return (r is Map && r['isOnline'] is bool)
        ? r['isOnline'] as bool
        : online;
  }

  /* ================================================================ *
   *  5. GANHOS (usado no perfil para contar as entregas)
   * ================================================================ */

  /// GET /api/driver/earnings?from=&to=
  static Future<Map<String, dynamic>> ganhos({
    required DateTime de,
    required DateTime ate,
  }) async {
    final r = await _enviar('GET', '/api/driver/earnings', query: {
      'from': _data(de),
      'to': _data(ate),
    });
    return (r as Map).cast<String, dynamic>();
  }

  static String _data(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
