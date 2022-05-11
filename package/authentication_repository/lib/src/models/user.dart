import 'package:equatable/equatable.dart';

/// {@template user}
/// User model.
/// [User.empty] represents an unauthenticated user.
/// {@endtemplate}
class User extends Equatable {
  /// {@macro user}
  const User({
    required this.uid,
    this.email,
    this.name,
    this.photo,
  });

  /// Empty user which represents an unauthenticated user.
  static const empty = User(uid: '');

  /// The current user's unique identifier.
  final String uid;

  /// The current user's email address.
  final String? email;

  /// The current user's name (display name).
  final String? name;

  /// Url for the current user's photo.
  final String? photo;

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == User.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != User.empty;

  @override
  List<Object?> get props => [uid, email, name, photo];
}
