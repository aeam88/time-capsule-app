import 'package:equatable/equatable.dart';

class Recipient extends Equatable {
  final String id;
  final String capsuleId;
  final String email;
  final DateTime createdAt;

  const Recipient({
    required this.id,
    required this.capsuleId,
    required this.email,
    required this.createdAt,
  });

  factory Recipient.fromJson(Map<String, dynamic> json) {
    return Recipient(
      id: json['id'] as String,
      capsuleId: json['capsuleId'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, capsuleId, email, createdAt];
}
