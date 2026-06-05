import 'dart:convert';
import 'dart:io';

class GeminiService {
  // Configure com: flutter run --dart-define=GEMINI_API_KEY=SUA_CHAVE
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _model = 'gemini-1.5-flash-latest';

  static final Uri _endpoint = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey',
  );

  Future<String> gerarResposta(String prompt) async {
    _validarApiKey();

    final response = await _postJson(_endpoint, {
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {'temperature': 0.4, 'maxOutputTokens': 500},
    });

    return _extrairTexto(response);
  }

  Future<String> gerarSugestaoParaChamado({
    required String titulo,
    required String descricao,
    required String categoria,
    required String bairro,
  }) async {
    final prompt =
        '''
Voce e um analista de chamados urbanos.

Titulo: $titulo
Descricao: $descricao
Categoria: $categoria
Bairro: $bairro

Retorne:
Retorne EXATAMENTE neste formato (sem markdown):
Prioridade sugerida: <baixa|media|alta|critica>
Acao recomendada: <texto em ate 4 linhas>
Prazo estimado: <texto curto>
''';

    return gerarResposta(prompt);
  }

  void _validarApiKey() {
    if (_apiKey.trim().isEmpty) {
      throw StateError(
        'API key da Gemini nao configurada. Execute com --dart-define=GEMINI_API_KEY=SUA_CHAVE.',
      );
    }
  }

  Future<Map<String, dynamic>> _postJson(
    Uri url,
    Map<String, dynamic> payload,
  ) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(url);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.add(utf8.encode(jsonEncode(payload)));

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final decoded = (jsonDecode(body) as Map<String, dynamic>);

      if (response.statusCode >= 400) {
        final apiMessage =
            (decoded['error'] as Map<String, dynamic>?)?['message'] as String?;
        throw HttpException(
          'Erro Gemini (${response.statusCode}): ${apiMessage ?? body}',
        );
      }

      return decoded;
    } finally {
      client.close(force: true);
    }
  }

  String _extrairTexto(Map<String, dynamic> response) {
    final candidates = response['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      return 'Sem resposta da Gemini.';
    }

    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    final text = parts != null && parts.isNotEmpty
        ? parts.first['text'] as String?
        : null;

    if (text == null || text.trim().isEmpty) {
      return 'Sem resposta da Gemini.';
    }

    return text.trim();
  }
}
