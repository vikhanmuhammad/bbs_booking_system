import 'package:cloud_firestore/cloud_firestore.dart';

class Paket {
  late  String namaPaket;
  final String rincianPaket;
  final int durasiPaket;
  final int hargaPaket;
  final String urlImage;
  final Timestamp createdAt;

  Paket({
    required this.namaPaket,
    required this.rincianPaket,
    required this.durasiPaket,
    required this.hargaPaket,
    required this.urlImage,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'namaPaket': namaPaket,
      'rincianPaket': rincianPaket,
      'durasiPaket': durasiPaket,
      'hargaPaket': hargaPaket,
      'urlImage': urlImage,
      'createdAt': createdAt,
    };
  }

  // Menambahkan metode fromMap
  factory Paket.fromMap(Map<String, dynamic> map) {
    return Paket(
      namaPaket: map['namaPaket'] ?? '',
      rincianPaket: map['rincianPaket'] ?? '',
      durasiPaket: map['durasiPaket'] ?? 0,
      hargaPaket: map['hargaPaket'] ?? 0,
      urlImage: map['urlImage'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
