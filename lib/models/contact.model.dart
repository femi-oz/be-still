class ContactModel {
  final String? id;
  final String? email;
  final String? phoneNumber;
  final String? displayName;

  const ContactModel({
    this.id,
    this.email,
    this.phoneNumber,
    this.displayName,
  });

  factory ContactModel.fromData(Map<String, dynamic> data, String did) {
    final id = did;
    final email = data['Email'] ?? '';
    final phoneNumber = data['PhoneNumber'] ?? '';
    final displayName = data['DisplayName'] ?? '';
    return ContactModel(
        id: id,
        email: email,
        phoneNumber: phoneNumber,
        displayName: displayName);
  }

  Map<String, dynamic> toJson() {
    return {
      'Email': email,
      'PhoneNumber': phoneNumber,
      'DisplayName': displayName,
    };
  }
}
