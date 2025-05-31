import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/smartphone.dart';

class ApiService {
  static const String baseUrl = 'https://tpm-api-responsi-e-f-872136705893.us-central1.run.app/api/v1';

  Future<List<Smartphone>> getSmartphones() async {
    final response = await http.get(Uri.parse('$baseUrl/phones'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> phones = data['data'];
      return phones.map((json) => Smartphone.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load smartphones');
    }
  }

  Future<Smartphone> getSmartphoneById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/phones/$id'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Smartphone.fromJson(data['data']);
    } else {
      throw Exception('Failed to load smartphone details');
    }
  }

  Future<void> createSmartphone(Smartphone smartphone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/phones'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(smartphone.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create smartphone');
    }
  }

  Future<void> updateSmartphone(int id, Smartphone smartphone) async {
    final response = await http.put(
      Uri.parse('$baseUrl/phones/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(smartphone.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update smartphone');
    }
  }

  Future<void> deleteSmartphone(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/phones/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete smartphone');
    }
  }
} 