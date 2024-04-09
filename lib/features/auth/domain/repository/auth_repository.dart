import 'package:blog_app/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/user.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> loginWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String name,
    required String password,
  });
  Future<Either<Failure, User>> currentUser();
}
