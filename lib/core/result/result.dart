import 'package:equatable/equatable.dart';

import 'status.dart';

/// Common response envelope returned by both `ApiClient` and `LocalDbService`
/// (ADR-0001 §4), so the presentation layer handles a remote-backed or
/// local-backed repository call identically.
class Result<T> extends Equatable {
  final Status status;
  final T? data;
  final String? message;

  const Result._({required this.status, this.data, this.message});

  factory Result.success(T data) => Result._(status: Status.success, data: data);

  factory Result.error(String message) =>
      Result._(status: Status.error, message: message);

  const Result.inProgress() : this._(status: Status.inProgress);

  bool get isSuccess => status == Status.success;
  bool get isError => status == Status.error;
  bool get isInProgress => status == Status.inProgress;

  @override
  List<Object?> get props => [status, data, message];
}
