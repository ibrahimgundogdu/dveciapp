class LoginResult {
  String? token;
  bool? isSuccess;
  String? message;

  LoginResult(this.token, this.isSuccess, this.message);

  LoginResult.fromMap(Map<String, dynamic> m)
      : this(m['token'] as String?, m['isSuccess'] as bool,
            m['message'] as String?);
}
