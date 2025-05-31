import 'package:flutter/material.dart';
import '../models/smartphone.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  List<Smartphone> _smartphones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSmartphones();
  }

  Future<void> _loadSmartphones() async {
    try {
      final smartphones = await _apiService.getSmartphones();
      setState(() {
        _smartphones = smartphones;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSmartphone(int id) async {
    try {
      await _apiService.deleteSmartphone(id);
      await _loadSmartphones();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Smartphone deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smartphones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _smartphones.length,
              itemBuilder: (context, index) {
                final smartphone = _smartphones[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: smartphone.imageUrl?.isNotEmpty == true
                        ? Image.network(
                            smartphone.imageUrl!,
                            width: 50,
                            height: 75,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(
                                width: 50,
                                height: 75,
                                child: Icon(Icons.smartphone, size: 30),
                              );
                            },
                          )
                        : const SizedBox(
                            width: 50,
                            height: 75,
                            child: Icon(Icons.smartphone, size: 30),
                          ),
                    title: Text(
                      smartphone.model,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${smartphone.brand}\n\$${smartphone.price.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    isThreeLine: true,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/detail',
                        arguments: smartphone.id,
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/edit',
                              arguments: smartphone.id,
                            ).then((_) => _loadSmartphones());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: const Text(
                                  'Are you sure you want to delete this smartphone?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await _deleteSmartphone(smartphone.id!);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create')
              .then((_) => _loadSmartphones());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 