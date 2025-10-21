import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/expenses/data/repositories/expense_repository.dart';
import '../../features/expenses/presentation/bloc/expense_bloc.dart';
import '../../features/payments/data/repositories/payment_repository.dart';
import '../../features/payments/presentation/bloc/payment_bloc.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/teachers/data/repositories/teacher_repository.dart';
import '../../features/teachers/presentation/bloc/teacher_bloc.dart';
import '../../features/students/data/repositories/student_repository.dart';
import '../../features/students/presentation/bloc/student_bloc.dart';
import '../../features/courses/data/repositories/course_repository.dart';
import '../../features/courses/presentation/bloc/course_bloc.dart';
import '../../features/unpaid/data/repositories/unpaid_repository.dart';
import '../../features/unpaid/presentation/bloc/unpaid_bloc.dart';
import '../network/api_client.dart';
import '../storage/storage_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupInjection() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Core services
  getIt.registerLazySingleton<StorageService>(
    () => StorageService(getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.baseUrl = 'https://edunova-production.up.railway.app/api';
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    return dio;
  });

  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(getIt<Dio>(), getIt<StorageService>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(getIt<ApiClient>(), getIt<StorageService>()),
  );

  getIt.registerLazySingleton<TeacherRepositoryImpl>(
    () => TeacherRepositoryImpl(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<StudentRepositoryImpl>(
    () => StudentRepositoryImpl(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<CourseRepositoryImpl>(
    () => CourseRepositoryImpl(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<UnpaidPaymentRepositoryImpl>(
    () => UnpaidPaymentRepositoryImpl(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<PaymentRepositoryImpl>(
    () => PaymentRepositoryImpl(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<ExpenseRepositoryImpl>(
    () => ExpenseRepositoryImpl(getIt<ApiClient>()),
  );

  // BLoCs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(getIt<AuthRepositoryImpl>()),
  );

  getIt.registerFactory<TeacherBloc>(
    () => TeacherBloc(getIt<TeacherRepositoryImpl>()),
  );

  getIt.registerFactory<StudentBloc>(
    () => StudentBloc(getIt<StudentRepositoryImpl>()),
  );

  getIt.registerFactory<CourseBloc>(
    () => CourseBloc(getIt<CourseRepositoryImpl>()),
  );

  getIt.registerFactory<UnpaidBloc>(
    () => UnpaidBloc(getIt<UnpaidPaymentRepositoryImpl>()),
  );

  getIt.registerFactory<PaymentBloc>(
    () => PaymentBloc(getIt<PaymentRepositoryImpl>()),
  );

  getIt.registerFactory<ExpenseBloc>(
    () => ExpenseBloc(getIt<ExpenseRepositoryImpl>()),
  );
}