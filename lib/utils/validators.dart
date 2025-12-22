bool isValidEmail(String email) {
  final RegExp emailRegExp = RegExp(
    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
  );
  return emailRegExp.hasMatch(email);
}
