class AuthorEntity {
  final int id;
  final String fullname;
  final String? avatar;

  const AuthorEntity({
    required this.id,
    required this.fullname,
    this.avatar,
  });
}
