import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfo {
  final String? id;
  final String name;
  final String profileImg;
  final String contactInfo;
  final List<Map<String, dynamic>>? userCourses;

  UserInfo({
    this.id,
    required this.name,
    required this.profileImg,
    required this.contactInfo,
    this.userCourses,
  });

   Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profileImg': profileImg,
      'contactInfo': contactInfo,
      'userCourses': userCourses ?? []
    };
  }

  static UserInfo fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return UserInfo(
      id: doc.id,
      name: map['name'] ?? '',
      profileImg: map['profileImg'] ?? '',
      contactInfo: map['contactInfo'] ?? '',
      userCourses: map['userCourses'].cast<Map<String, dynamic>>() ?? [],
    );
  }
}
