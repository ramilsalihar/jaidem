class AuthorModel {
  final int id;
  final String fullname;
  final String? avatar;
  final String? flowName;

  const AuthorModel({
    required this.id,
    required this.fullname,
    this.avatar,
    this.flowName,
  });
}
