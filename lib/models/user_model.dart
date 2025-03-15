import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userEmail;
  final String userName;
  final String? userImage;
  final DateTime userDate;

  UserModel({
    required this.userEmail,
    required this.userName,
    this.userImage,
    DateTime? userDate,
  }) : userDate = userDate ?? DateTime.now();

  Map<String, dynamic> toFirestore() {
    return {
      'userEmail': userEmail,
      'userName': userName,
      'userImage': userImage,
      'userDate': Timestamp.fromDate(userDate),
    };
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      userEmail: data['userEmail'],
      userName: data['userName'],
      userImage: data['userImage'],
      userDate: (data['userDate'] as Timestamp).toDate(),
    );
  }
}
