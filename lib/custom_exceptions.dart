class IncorrectCredentialsException implements Exception {
  String toString() => "Incorrect Username or Password";
}

class NoCredentialsException implements Exception {
  String toString() => "No Username or Password";
}

class NoPasswordException implements Exception {
  String toString() => "No Password";
}

class NoUsernameException implements Exception {
  String toString() => "No Username";
}
