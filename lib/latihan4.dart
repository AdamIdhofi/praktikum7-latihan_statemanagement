import 'dart:convert'; // Mengimpor library dart:convert untuk bekerja dengan data JSON.
import 'package:flutter/material.dart'; // Mengimpor material.dart untuk komponen UI Flutter.
import 'package:http/http.dart' as http; // Mengimpor http.dart untuk membuat permintaan HTTP.
import 'package:provider/provider.dart'; // Mengimpor provider.dart untuk manajemen state.

void main() {
  runApp(MyApp()); // Titik masuk aplikasi, memulai aplikasi Flutter.
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universitas ASEAN',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
        create: (context) => UniversitasProvider(), // Membuat provider untuk mengelola data universitas.
        child: UniversitasList(), // Menampilkan daftar universitas.
      ),
    );
  }
}

class UniversitasProvider extends ChangeNotifier {
  List<dynamic> universitas = []; // List untuk menyimpan data universitas yang diambil.

  Future<void> fetchData(String country) async {
    final response = await http.get(Uri.parse('http://universities.hipolabs.com/search?country=$country')); // Mengambil data universitas dari API.

    if (response.statusCode == 200) {
      universitas = json.decode(response.body); // Mem-parsing respon JSON menjadi list universitas.
      notifyListeners(); // Memberi tahu pendengar tentang perubahan data.
    } else {
      throw Exception('Gagal memuat universitas'); // Menangani kegagalan memuat universitas.
    }
  }
}

class UniversitasList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final universitasProvider = Provider.of<UniversitasProvider>(context); // Mengakses UniversitasProvider.

    return Scaffold(
      appBar: AppBar(
        title: Text('Universitas ASEAN'),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: 'Indonesia',
            items: <String>['Indonesia', 'Singapore', 'Malaysia', 'Myanmar'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) { // Menangani perubahan nilai dropdown.
              if(newValue != null) {
                universitasProvider.fetchData(newValue); // Mengambil data universitas berdasarkan negara yang dipilih.
              }
            },
          ),
          Consumer<UniversitasProvider>(
            builder: (context, provider, child) {
              return provider.universitas.isEmpty
                  ? Center(child: CircularProgressIndicator()) // Menampilkan indikator loading jika data sedang diambil.
                  : Expanded(
                      child: ListView.builder(
                        itemCount: provider.universitas.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(provider.universitas[index]['name']), // Menampilkan nama universitas.
                            subtitle: Text(provider.universitas[index]['web_pages'][0]), // Menampilkan situs web universitas.
                          );
                        },
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }
}
