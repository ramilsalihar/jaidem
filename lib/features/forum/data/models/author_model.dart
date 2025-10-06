class AuthorModel {
  final int id;
  final String fullname;
  final String? avatar;

  const AuthorModel({
    required this.id,
    required this.fullname,
    this.avatar,
  });
}
