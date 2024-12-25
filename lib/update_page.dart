import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UpdatePage extends StatefulWidget {
  final Map item;

  UpdatePage({required this.item});

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();
  String? _originalImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item['name']);
    _descriptionController = TextEditingController(text: widget.item['description']);
    _originalImageUrl = widget.item['image']; // Charger l'URL de l'image d'origine
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FocusScope.of(context).unfocus();

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = pickedFile;
        _selectedImageBytes = bytes;
        _originalImageUrl = null; // Supprimer l'image d'origine
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aucune image sélectionnée.')),
      );
    }
  }

  Future<void> updateItem() async {
    FocusScope.of(context).unfocus();

    // Validation des champs
    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty) {
      _showSnackBar('Veuillez remplir tous les champs.');
      return;
    }

    try {
      // Préparer les données JSON
      final data = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        if (_selectedImageBytes != null)
          'image': base64Encode(_selectedImageBytes!), // Convertir l'image en Base64
      };

      // Envoyer la requête PUT
      final response = await http.put(
        Uri.parse('http://127.0.0.1:5001/api/update/${widget.item['id']}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      // Vérifier la réponse
      if (response.statusCode == 200) {
        _showSnackBar('Mise à jour réussie.');
        bool updated = true;
        Navigator.pop(context, updated);
      } else {
        print("Erreur du serveur : ${response.body}");
        _showSnackBar('Erreur lors de la mise à jour.');
      }
    } catch (e) {
      print("Erreur : $e");
      _showSnackBar('Erreur de connexion au serveur.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier un Item'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _selectedImageBytes != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      _selectedImageBytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                      : _originalImageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      _originalImageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                      : Center(
                    child: Text(
                      'Cliquez pour sélectionner une image',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateItem,
                child: Text('Mettre à jour'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
