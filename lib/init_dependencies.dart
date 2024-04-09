import 'package:blog_app/core/common/cubit/app_user/app_user_cubit.dart';
import 'package:blog_app/core/network/connection_checker.dart';
import 'package:blog_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blog_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:blog_app/features/auth/domain/repository/auth_repository.dart';
import 'package:blog_app/features/auth/domain/usecases/current_user.dart';
import 'package:blog_app/features/auth/domain/usecases/user_sign_in.dart';
import 'package:blog_app/features/auth/domain/usecases/user_sign_up.dart';
import 'package:blog_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_app/features/blog/data/datasources/blod_remote_datasource.dart';
import 'package:blog_app/features/blog/data/datasources/blog_local_data_source.dart';
import 'package:blog_app/features/blog/data/repositories/blog_repository_impl.dart';
import 'package:blog_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:blog_app/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:blog_app/features/blog/domain/usecases/upload_blog.dart';
import 'package:blog_app/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/secrets/app_secrets.dart';

final sl = GetIt.instance;
Future<void> initDependencies() async {
  initAuth();
  initBLog();
  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );
  Hive.defaultDirectory = (await getApplicationDocumentsDirectory()).path;
  sl.registerLazySingleton(() => Hive.box(name: 'blogs'));
  sl.registerLazySingleton(() => supabase.client);
  sl.registerLazySingleton(() => AppUserCubit());
  sl.registerFactory(() => InternetConnection());
  sl.registerFactory<ConnectionChecker>(() => ConnectionCheckerImpl(sl()));
}

void initAuth() {
  // Remote Datasource
  sl.registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl<SupabaseClient>()));
  sl.registerFactory<AuthRepository>(() => AuthRepositoryImpl(sl(), sl()));
  // Usecase
  sl.registerFactory(() => UserSignUp(sl()));
  sl.registerFactory(() => UserSignIn(sl()));
  sl.registerFactory(() => CurrentUser(sl()));
  // Bloc
  sl.registerLazySingleton<AuthBloc>(() => AuthBloc(
        userSignUp: sl<UserSignUp>(),
        userSignIn: sl<UserSignIn>(),
        currentUser: sl<CurrentUser>(),
        appUserCubit: sl<AppUserCubit>(),
      ));
}

void initBLog() {
  // Remote Datasource
  sl.registerFactory<BlogRemoteDataSource>(
      () => BlogRemoteDataSourceImpl(sl<SupabaseClient>()));
  sl.registerFactory<BlogLocalDataSource>(() => BlogLocalDataSourceImpl(sl()));
  sl.registerFactory<BlogRepository>(() => BlogRepositoryImpl(
        blogRemoteDataSource: sl(),
        blogLocalDataSource: sl(),
        connectionChecker: sl(),
      ));
  // Usecase
  sl.registerFactory(() => UploadBlog(sl()));
  sl.registerFactory(() => GetAllBlogs(repository: sl()));

  // Bloc
  sl.registerLazySingleton<BlogBloc>(
      () => BlogBloc(uploadBlog: sl(), getAllBlogs: sl()));
}
