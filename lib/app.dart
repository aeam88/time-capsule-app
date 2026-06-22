import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/config/theme.dart';
import 'core/config/theme_cubit.dart';
import 'core/navigation/app_transitions.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/ui/screens/login_screen.dart';
import 'features/auth/ui/screens/register_screen.dart';
import 'features/auth/ui/screens/forgot_password_screen.dart';
import 'features/auth/ui/screens/profile_screen.dart';
import 'features/capsules/bloc/capsules_bloc.dart';
import 'features/capsules/bloc/capsules_event.dart';
import 'features/capsules/bloc/capsules_state.dart';
import 'features/capsules/data/repositories/capsules_repository.dart';
import 'features/capsules/ui/screens/capsules_list_screen.dart';
import 'features/capsules/ui/screens/capsule_detail_screen.dart';
import 'features/capsules/ui/screens/create_edit_capsule_screen.dart';
import 'features/capsules/ui/screens/shared_capsules_screen.dart';
import 'features/files/ui/screens/file_preview_screen.dart';
import 'features/onboarding/ui/screens/onboarding_screen.dart';
import 'injection_container.dart';
import 'package:go_router/go_router.dart';

import 'dart:async';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<Route> routeObserver = RouteObserver<Route>();

class TimeCapsuleApp extends StatefulWidget {
  const TimeCapsuleApp({super.key});

  @override
  State<TimeCapsuleApp> createState() => _TimeCapsuleAppState();
}

class _TimeCapsuleAppState extends State<TimeCapsuleApp> {
  late final AuthBloc _authBloc;
  late final CapsulesBloc _capsulesBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(
      authRepository: AuthRepository(
        dio: InjectionContainer().apiClient.dio,
      ),
    )..add(const CheckAuthStatus());

    _capsulesBloc = CapsulesBloc(
      repository: CapsulesRepository(
        dio: InjectionContainer().apiClient.dio,
      ),
    )..add(const LoadCapsules());

    _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      observers: [routeObserver],
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/onboarding',
          pageBuilder: (context, state) => AppTransitions.fadeTransition(
            context, state, const OnboardingScreen(),
          ),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => AppTransitions.fadeTransition(
            context, state, const LoginScreen(),
          ),
        ),
        GoRoute(
          path: '/register',
          pageBuilder: (context, state) => AppTransitions.slideTransition(
            context, state, const RegisterScreen(),
          ),
        ),
        GoRoute(
          path: '/forgot-password',
          pageBuilder: (context, state) => AppTransitions.slideTransition(
            context, state, const ForgotPasswordScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => AppTransitions.slideFromBottom(
            context, state, const ProfileScreen(),
          ),
        ),
        GoRoute(
          path: '/capsules',
          pageBuilder: (context, state) => AppTransitions.fadeTransition(
            context, state, const CapsulesListScreen(),
          ),
        ),
        GoRoute(
          path: '/capsules/shared',
          pageBuilder: (context, state) => AppTransitions.slideTransition(
            context, state, const SharedCapsulesScreen(),
          ),
        ),
        GoRoute(
          path: '/capsules/create',
          pageBuilder: (context, state) => AppTransitions.slideFromBottom(
            context, state, const CreateEditCapsuleScreen(),
          ),
        ),
        GoRoute(
          path: '/capsules/preview',
          pageBuilder: (context, state) {
            final file = state.extra as dynamic;
            return AppTransitions.slideTransition(
              context, state, FilePreviewScreen(file: file),
            );
          },
        ),
        GoRoute(
          path: '/capsules/:id',
          pageBuilder: (context, state) {
            final capsuleId = state.pathParameters['id']!;
            return AppTransitions.slideTransition(
              context, state, CapsuleDetailScreen(capsuleId: capsuleId),
            );
          },
        ),
        GoRoute(
          path: '/capsules/:id/edit',
          pageBuilder: (context, state) {
            final capsuleId = state.pathParameters['id']!;
            return AppTransitions.slideFromBottom(
              context, state, _EditCapsuleWrapper(capsuleId: capsuleId),
            );
          },
        ),
      ],
      redirect: (context, state) async {
        final authState = _authBloc.state;
        final isAuthenticated = authState is Authenticated;
        final isLoading = authState is AuthLoading || authState is AuthInitial;
        final isOnboardingRoute = state.matchedLocation == '/onboarding';
        final isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/forgot-password';

        if (isLoading) return null;

        // Always check onboarding status from storage
        const storage = FlutterSecureStorage();
        final completed = await storage.read(key: 'onboarding_completed');
        final showOnboarding = completed != 'true';

        // Show onboarding if not completed
        if (showOnboarding && !isOnboardingRoute && !isAuthenticated) {
          return '/onboarding';
        }

        if (!isAuthenticated && !isAuthRoute && !isOnboardingRoute) {
          return '/login';
        }
        if (isAuthenticated && (isAuthRoute || isOnboardingRoute)) {
          return '/capsules';
        }
        return null;
      },
      refreshListenable: GoRouterRefreshStream(_authBloc.stream),
    );
  }

  @override
  void dispose() {
    _authBloc.close();
    _capsulesBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocProvider.value(
        value: _authBloc,
        child: BlocProvider.value(
          value: _capsulesBloc,
          child: Builder(
            builder: (context) {
              return BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  return MaterialApp.router(
                    title: 'Time Capsule',
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeMode,
                    routerConfig: _router,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EditCapsuleWrapper extends StatefulWidget {
  final String capsuleId;

  const _EditCapsuleWrapper({required this.capsuleId});

  @override
  State<_EditCapsuleWrapper> createState() => _EditCapsuleWrapperState();
}

class _EditCapsuleWrapperState extends State<_EditCapsuleWrapper> {
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      context.read<CapsulesBloc>().add(LoadCapsuleDetail(capsuleId: widget.capsuleId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CapsulesBloc, CapsulesState>(
      builder: (context, state) {
        if (state is CapsuleDetailLoaded) {
          return CreateEditCapsuleScreen(capsule: state.capsule);
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
