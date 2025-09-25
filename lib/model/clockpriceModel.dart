import 'package:cloud_firestore/cloud_firestore.dart';

class ClockPrice {
  String nama;
  Timestamp start;
  Timestamp end;
  int durasi;
  int price;

  ClockPrice({
    required this.nama,
    required this.start,
    required this.end,
    required this.durasi,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'start': start,
      'end': end,
      'durasi': durasi,
      'price': price,
    };
  }

  factory ClockPrice.fromMap(Map<String, dynamic> data) {
    return ClockPrice(
      nama: data['nama'] ?? '',
      start: data['start'] as Timestamp,
      end: data['end'] as Timestamp,
      durasi: data['durasi'] ?? 0,
      price: data['price'] ?? 0,
    );
  }

}
