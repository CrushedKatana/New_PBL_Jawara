class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? rt;
  final String? rw;
  final String userType; // 'warga', 'admin', 'rt'
  final String? photoUrl;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.rt,
    this.rw,
    this.userType = 'warga',
    this.photoUrl,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      rt: json['rt'],
      rw: json['rw'],
      userType: json['user_type'] ?? 'warga',
      photoUrl: json['photo_url'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'rt': rt,
      'rw': rw,
      'user_type': userType,
      'photo_url': photoUrl,
    };
  }
}
