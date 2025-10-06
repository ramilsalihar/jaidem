class ResponseModel<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  ResponseModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory ResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ResponseModel(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
