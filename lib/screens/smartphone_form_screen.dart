import 'package:flutter/material.dart';
import '../models/smartphone.dart';
import '../services/api_service.dart';

class SmartphoneFormScreen extends StatefulWidget {
  final bool isEditing;
  final int? smartphoneId;

  const SmartphoneFormScreen({
    super.key,
    this.isEditing = false,
    this.smartphoneId,
  });

  @override
  State<SmartphoneFormScreen> createState() => _SmartphoneFormScreenState();
}

class _SmartphoneFormScreenState extends State<SmartphoneFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _isLoading = false;
  late final TextEditingController _modelController;
  late final TextEditingController _brandController;
  late final TextEditingController _priceController;
  late final TextEditingController _ramController;
  int _storage = 128;

  final List<int> _storageOptions = [128, 256, 512];

  @override
  void initState() {
    super.initState();
    _modelController = TextEditingController();
    _brandController = TextEditingController();
    _priceController = TextEditingController();
    _ramController = TextEditingController(text: '2');
    if (widget.isEditing) {
      _loadSmartphone();
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _ramController.dispose();
    super.dispose();
  }

  Future<void> _loadSmartphone() async {
    if (widget.smartphoneId == null) return;
    setState(() => _isLoading = true);
    try {
      final smartphone = await _apiService.getSmartphoneById(widget.smartphoneId!);
      _modelController.text = smartphone.model;
      _brandController.text = smartphone.brand;
      _priceController.text = smartphone.price.toString();
      _ramController.text = smartphone.ram.toString();
      setState(() {
        _storage = smartphone.storage;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
        Navigator.pop(context);
      }
    }
  }

  bool _isValidRam(String value) {
    final ram = int.tryParse(value);
    if (ram == null) return false;
    return ram > 0 && ram % 2 == 0; // Must be positive and multiple of 2
  }

  Future<void> _saveSmartphone() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final smartphone = Smartphone(
        model: _modelController.text,
        brand: _brandController.text,
        ram: int.parse(_ramController.text),
        storage: _storage,
        price: double.parse(_priceController.text),
      );

      if (widget.isEditing) {
        await _apiService.updateSmartphone(widget.smartphoneId!, smartphone);
      } else {
        await _apiService.createSmartphone(smartphone);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Smartphone updated successfully'
                  : 'Smartphone created successfully',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Smartphone' : 'Create Smartphone'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: 'Model',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the model';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        labelText: 'Brand',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the brand';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ramController,
                      decoration: const InputDecoration(
                        labelText: 'RAM (GB)',
                        border: OutlineInputBorder(),
                        hintText: 'Enter RAM (must be multiple of 2)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the RAM';
                        }
                        if (!_isValidRam(value)) {
                          return 'RAM must be a positive multiple of 2';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _storage,
                      decoration: const InputDecoration(
                        labelText: 'Storage (GB)',
                        border: OutlineInputBorder(),
                      ),
                      items: _storageOptions
                          .map((storage) => DropdownMenuItem(
                                value: storage,
                                child: Text('$storage GB'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _storage = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveSmartphone,
                      child: Text(widget.isEditing ? 'Update' : 'Create'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 