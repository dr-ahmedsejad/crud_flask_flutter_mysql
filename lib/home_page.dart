import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'create_page.dart';
import 'update_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List items = [];

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5001/api/items'));
    if (response.statusCode == 200) {
      setState(() {
        items = json.decode(response.body);
      });
    } else {
      print('Erreur lors de la récupération des items : ${response.statusCode}');
    }
  }

  Future<void> deleteItem(int id) async {
    final response = await http.delete(Uri.parse('http://127.0.0.1:5001/api/delete/$id'));
    if (response.statusCode == 200) {
      fetchItems(); // Actualiser la liste
    } else {
      print('Erreur lors de la suppression de l\'item : ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Items', style: TextStyle(fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: items.isEmpty
          ? Center(
        child: Text(
          'Aucun item disponible',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: items[index]['image'] != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  items[index]['image'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
                  : CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey,
                child: Icon(Icons.image_not_supported, color: Colors.white),
              ),
              title: Text(
                items[index]['name'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                items[index]['description'],
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async{
                      bool updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdatePage(item: items[index]),
                        ),
                      ) ;
                      if (updated == true){
                        fetchItems();
                      }
                      },
                  ),
                  // Suppression item
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final bool? confirm = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirmation'),
                            content: Text('Êtes-vous sûr de vouloir supprimer cet élément ?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false), // Annuler
                                child: Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true), // Confirmer
                                child: Text('Supprimer'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        deleteItem(items[index]['id']); // Appeler la fonction de suppression
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
        child: Icon(Icons.add, size: 28),
        backgroundColor: Colors.teal,
        onPressed: () async {
          bool inserted = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreatePage()),
        );
          if (inserted ==true){
            fetchItems();
          }
          },
      ),
    );
  }
}
