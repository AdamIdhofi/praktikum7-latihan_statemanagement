import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universitas ASEAN',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => UniversitasCubit(), // Membuat UniversitasCubit
        child: UniversitasList(), // Menampilkan UniversitasList
      ),
    );
  }
}

class UniversitasCubit extends Cubit<List<dynamic>> {
  UniversitasCubit() : super([]);

  // Method untuk mengambil data universitas dari API
  Future<void> fetchData(String country) async {
    final response = await http.get(Uri.parse('http://universities.hipolabs.com/search?country=$country'));

    if (response.statusCode == 200) {
      emit(json.decode(response.body)); // Mengeluarkan data universitas
    } else {
      throw Exception('Failed to load universities');
    }
  }
}

class UniversitasList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final universitasCubit = BlocProvider.of<UniversitasCubit>(context); // Mendapatkan instance dari UniversitasCubit

    return Scaffold(
      appBar: AppBar(
        title: Text('Universitas ASEAN'),
      ),
      body: Column(
        children: [
          // Dropdown untuk memilih negara
          DropdownButton<String>(
            value: 'Indonesia',
            items: <String>['Indonesia', 'Singapore', 'Malaysia', 'Myanmar'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if(newValue != null) {
                universitasCubit.fetchData(newValue); // Panggil method fetchData dari Cubit
              }
            },
          ),
          // Widget untuk menampilkan data universitas
          BlocBuilder<UniversitasCubit, List<dynamic>>(
            builder: (context, universitasList) {
              return universitasList.isEmpty
                  ? Center(child: CircularProgressIndicator()) // Tampilkan loading spinner jika data belum tersedia
                  : Expanded(
                      child: ListView.builder(
                        itemCount: universitasList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(universitasList[index]['name']), // Tampilkan nama universitas
                            subtitle: Text(universitasList[index]['web_pages'][0]), // Tampilkan situs web universitas
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
