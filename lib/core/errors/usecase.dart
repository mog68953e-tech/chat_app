import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Base use case interface
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// For use cases with no parameters
class NoParams {}
