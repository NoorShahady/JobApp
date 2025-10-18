import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String uid;
  String accountType;
  String firstName;
  String lastName;
  String email;
  String phone;
  String location;
  String desiredRole;
  String workType;
  int yearsOfExperience;
  List<String> skills;
  String bio;
  String companyName;
  String companyAbout;
  UserProfile({
    this.uid = '',
    this.accountType = 'candidate',
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.desiredRole = '',
    this.workType = 'Hybrid',
    this.yearsOfExperience = 0,
    List<String>? skills,
    this.bio = '',
    this.companyName = '',
    this.companyAbout = '',
  }) : skills = skills ?? <String>[];

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'accountType': accountType,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'location': location,
    'desiredRole': desiredRole,
    'workType': workType,
    'yearsOfExperience': yearsOfExperience,
    'skills': skills,
    'bio': bio,
    'companyName': companyName,
    'companyAbout': companyAbout,
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    uid: json['uid'] ?? '',
    accountType: json['accountType'] ?? 'candidate',
    firstName: json['firstName'] ?? '',
    lastName: json['lastName'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    location: json['location'] ?? '',
    desiredRole: json['desiredRole'] ?? '',
    workType: json['workType'] ?? 'Hybrid',
    yearsOfExperience: json['yearsOfExperience'] ?? 0,
    skills: List<String>.from(json['skills'] ?? []),
    bio: json['bio'] ?? '',
    companyName: json['companyName'] ?? '',
    companyAbout: json['companyAbout'] ?? '',
  );
}
