import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  Uint8List? _selectedImageBytes;
  String? _originalFileName; // Variable pour stocker le nom du fichier

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final imageBytes = await pickedImage.readAsBytes();
      setState(() {
        _selectedImageBytes = imageBytes;
        _originalFileName = pickedImage.name; // Extraire le nom original du fichier
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aucune image sélectionnée.')),
      );
    }
  }

  Future<void> createItem() async {
    final url = Uri.parse('http://127.0.0.1:5001/api/create');

    // Convertir l'image en Base64
    final imageBase64 = base64Encode(_selectedImageBytes!);

    // Préparer les données
    final data = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'image': imageBase64,
    };

    try {
      // Envoyer la requête POST
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      // Vérifier la réponse
      if (response.statusCode == 201) {

        _showSnackBar('Article créé avec succès.');
        bool inserted = true;
        Navigator.pop(context,inserted);
      } else {
        print('Erreur : ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur lors de la création de l\'article.')),
                );
      }
    } catch (e) {
      print('Erreur : $e');
    }
  }


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un Article', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nom de l\'Article',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Entrez le nom de l\'article',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Entrez une description pour l\'article',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Image de l\'Article',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                    image: _selectedImageBytes != null
                        ? DecorationImage(
                      image: MemoryImage(_selectedImageBytes!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: _selectedImageBytes == null
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 40, color: Colors.grey[600]),
                        SizedBox(height: 8),
                        Text(
                          'Parcourir',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                      : null,
                ),
              ),
              if (_originalFileName != null) // Afficher le nom de l'image sélectionnée
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Image sélectionnée : $_originalFileName',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: createItem,
                  icon: Icon(Icons.save),
                  label: Text('Créer l\'Article'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
