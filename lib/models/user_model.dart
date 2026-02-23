class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String role; // Student, Worker, etc.
  final String securityQuestion;
  final String securityAnswer;
  final int studyTime; // Cumulative seconds spent in app

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.securityQuestion,
    required this.securityAnswer,
    this.studyTime = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'securityQuestion': securityQuestion,
      'securityAnswer': securityAnswer,
      'studyTime': studyTime,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
      securityQuestion: map['securityQuestion'] ?? '',
      securityAnswer: map['securityAnswer'] ?? '',
      studyTime: map['studyTime'] ?? 0,
    );
  }
}
