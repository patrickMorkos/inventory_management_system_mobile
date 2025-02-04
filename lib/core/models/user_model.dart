//! This is the user model class
import 'dart:convert';

class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String password;
  final dynamic dateOfBirth;
  final dynamic dateOfJoin;
  final String bloodType;
  final int userTypeId;
  final double usdLbpRate;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.dateOfBirth,
    required this.dateOfJoin,
    required this.bloodType,
    required this.userTypeId,
    required this.usdLbpRate,
  });

  UserModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? password,
    dynamic dateOfBirth,
    dynamic dateOfJoin,
    String? bloodType,
    int? userTypeId,
    double? usdLbpRate,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      password: password ?? this.password,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      dateOfJoin: dateOfJoin ?? this.dateOfJoin,
      bloodType: bloodType ?? this.bloodType,
      userTypeId: userTypeId ?? this.userTypeId,
      usdLbpRate: usdLbpRate ?? this.usdLbpRate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'email': email,
      'password': password,
      'date_of_birth': dateOfBirth,
      'date_of_join': dateOfJoin,
      'blood_type': bloodType,
      'user_type_id': userTypeId,
      'usd_lbp_rate': usdLbpRate,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toInt() ?? 0,
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      dateOfBirth: map['date_of_birth'],
      dateOfJoin: map['date_of_join'],
      bloodType: map['blood_type'] ?? '',
      userTypeId: map['user_type_id']?.toInt() ?? 0,
      usdLbpRate: map['usd_lbp_rate']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserModel(id: $id, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, email: $email, password: $password, dateOfBirth: $dateOfBirth, dateOfJoin: $dateOfJoin, bloodType: $bloodType, userTypeId: $userTypeId, usdLbpRate: $usdLbpRate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.password == password &&
        other.dateOfBirth == dateOfBirth &&
        other.dateOfJoin == dateOfJoin &&
        other.bloodType == bloodType &&
        other.userTypeId == userTypeId &&
        other.usdLbpRate == usdLbpRate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        phoneNumber.hashCode ^
        email.hashCode ^
        password.hashCode ^
        dateOfBirth.hashCode ^
        dateOfJoin.hashCode ^
        bloodType.hashCode ^
        userTypeId.hashCode ^
        usdLbpRate.hashCode;
  }
}
