import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://empowerlearn-ofc-production.up.railway.app';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Email ou senha inválidos');
    }
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> dados) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dados),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erro no cadastro');
    }
  }

  static Future<List<dynamic>> getForumPosts() async {
    final headers = await _headers();
    final response = await http.get(Uri.parse('$baseUrl/forum'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  static Future<void> createForumPost(String conteudo) async {
    final headers = await _headers();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    await http.post(
      Uri.parse('$baseUrl/forum'),
      headers: headers,
      body: jsonEncode({
        'conteudo': conteudo,
        'titulo': conteudo.length > 50 ? conteudo.substring(0, 50) : conteudo,
        'usuarioId': int.tryParse(userId ?? '0') ?? 0,
      }),
    );
  }
}