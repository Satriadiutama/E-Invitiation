import 'dart:convert';


List<Undangan> undanganFromJson(String str) =>
    List<Undangan>.from(json.decode(str).map((x) => Undangan.fromJson(x)));

class Undangan {
  String undanganID;
  String email;
  String nama;
  String statusDatang;
  String foto;

  Undangan({
    required this.undanganID,
    required this.email,
    required this.nama,
    required this.statusDatang,
    required this.foto,
  });

  factory Undangan.fromJson(Map<String, dynamic> json) => Undangan(
    undanganID: json["id_undangan"],
    email: json["email"],
    nama: json["nama"],
    statusDatang: json["status_datang"],
    foto: json["foto"],
  );
  Map<String, dynamic> toJson() =>{
    "id_undangan" : undanganID,
    "email" : email,
    "nama" : nama,
    "status_datang" : statusDatang,
    "foto" : foto,
  };
}
