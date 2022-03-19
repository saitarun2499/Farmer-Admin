import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final Timestamp userName;
  final bool isExpert;
  final bool isRemoved;

  UserModel(
      {required this.userId,
      required this.userName,
      required this.isExpert,
      required this.isRemoved});

  factory UserModel.fromJson(QueryDocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
    return UserModel(
        userId: data['userId'] as String,
        userName: data['dateTime'] as Timestamp,
        isExpert: data['isExpert'] ?? false,
        isRemoved: data['isRemoved'] ?? false);
  }
}
