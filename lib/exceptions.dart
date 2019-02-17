class IncorrectCredentialsException implements Exception {
  String toString() {
    return "Incorrect Username or Password";
  }
}

class NoUsernameException implements Exception {
  String toString() {
    return "No Username";
  }
}

class NoPasswordException implements Exception {
  String toString() {
    return "No Password";
  }
}

class NoCredentialsException implements Exception {
  String toString() {
    return "No Username or Password";
  }
}
